import 'package:injectable/injectable.dart';
import 'package:reader/core/storage/secure_storage.dart';
import 'package:reader/features/cards/domain/card_local_repository.dart';
import 'package:reader/features/dlq/application/dlq_service.dart';
import 'package:reader/features/dlq/domain/dlq_item.dart';
import 'package:reader/features/logger/application/logger_service.dart';
import 'package:reader/features/scanner/application/peer_sync_service.dart';
import 'package:reader/features/scanner/domain/scan_context.dart';
import 'package:reader/features/scanner/domain/scan_exception.dart';
import 'package:reader/features/scanner/domain/scan_flag.dart';
import 'package:reader/features/scanner/domain/scan_local_repository.dart';
import 'package:reader/features/scanner/domain/scan_record.dart';
import 'package:reader/features/scanner/domain/scan_remote_repository.dart';
import 'package:reader/features/scanner/domain/scan_step.dart';
import 'package:reader/features/scanner/domain/scan_submit_exception.dart';
import 'package:reader/features/scanner/domain/steps/card_lookup_step.dart';
import 'package:reader/features/scanner/domain/steps/invalidation_step.dart';
import 'package:reader/features/scanner/domain/steps/mark_used_step.dart';
import 'package:reader/features/scanner/domain/steps/parse_step.dart';
import 'package:reader/features/scanner/domain/steps/used_step.dart';
import 'package:reader/features/scanner/domain/steps/validity_step.dart';

@lazySingleton
class ScannerService {
  final CardLocalRepository _localRepository;
  final LoggerService _loggerService;
  final PeerSyncService _peerSyncService;
  final DlqService _dlqService;
  final ScanRemoteRepository _scanRemoteRepository;
  final ScanLocalRepository _scanLocalRepository;
  final SecureStorage _secureStorage;

  ScannerService(
    this._localRepository,
    this._loggerService,
    this._dlqService,
    this._peerSyncService,
    this._scanRemoteRepository,
    this._scanLocalRepository,
    this._secureStorage,
  );

  Future<void> upsert(ScanRecord scan) => _scanLocalRepository.upsert(scan);
  Future<void> upsertFromMap(Map<String, dynamic> map) => _scanLocalRepository.upsertFromMap(map);
  Future<void> delete(String id) => _scanLocalRepository.delete(id);

  Future<ScanContext> scan(String rawValue) async {
    final steps = <ScanStep>[
      ParseStep(_loggerService),
      CardLookupStep(_localRepository, _loggerService),
      ValidityStep(_loggerService),
      InvalidationStep(_loggerService),
      UsedStep(_loggerService),
      MarkUsedStep(_localRepository, _loggerService),
    ];

    var context = ScanContext(rawValue: rawValue);
    ScanException? failure;
    ScanFlag flag = ScanFlag.passedOk;

    try {
      for (final step in steps) {
        context = await step.execute(context);
      }
    } on ScanException catch (e) {
      failure = e;
      context = e.context;
      flag = e.flag;
    }

    final profile = await _secureStorage.getProfile();
    final readerId = profile?['id'] as String? ?? '';

    ScanSubmitException? rejection;

    try {
      await _scanRemoteRepository.submit(
        scannedValue: rawValue,
        flag: flag,
        cardId: context.card?.id,
      );
    } on ScanSubmitException catch (e) {
      if (e.isRejected) {
        // 4xx — the server responded and denied the scan (e.g. duplicate).
        // This is a definitive result, so surface it instead of retrying.
        _loggerService.error(
          'Scan rejected by server: $e',
          className: 'ScannerService',
        );
        rejection = e;
      } else {
        // 5xx — the server could not process the scan. Queue it for retry and
        // continue the workflow.
        _loggerService.error(
          'Server could not process scan, queuing to DLQ: $e',
          className: 'ScannerService',
        );
        await _dlqService.insertItem(
          DlqItem(scannedValue: rawValue, flag: flag, cardId: context.card?.id),
        );
      }
    } catch (e) {
      // Server unreachable / network error — queue for retry and continue.
      _loggerService.error(
        'Failed to submit scan to server: $e',
        className: 'ScannerService',
      );

      await _dlqService.insertItem(
        DlqItem(scannedValue: rawValue, flag: flag, cardId: context.card?.id),
      );
    }

    try {
      await _scanLocalRepository.insert(
        ScanRecord(
          readerId: readerId,
          scannedValue: rawValue,
          flag: flag.serverValue,
          cardLabel: context.card?.label,
          createdAt: DateTime.now(),
        ),
      );
    } catch (e) {
      _loggerService.error(
        'Failed to save scan locally: $e',
        className: 'ScannerService',
      );
    }

    if (failure != null) throw failure;
    if (rejection != null) throw rejection;

    _peerSyncService.broadcastCardUsed(context.card!.id);
    return context;
  }
}
