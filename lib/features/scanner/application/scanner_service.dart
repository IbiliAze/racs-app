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
import 'package:reader/features/scanner/domain/steps/broadcast_step.dart';
import 'package:reader/features/scanner/domain/steps/card_lookup_step.dart';
import 'package:reader/features/scanner/domain/steps/invalidation_step.dart';
import 'package:reader/features/scanner/domain/steps/mark_used_step.dart';
import 'package:reader/features/scanner/domain/steps/parse_step.dart';
import 'package:reader/features/scanner/domain/steps/submit_remote_step.dart';
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
    final outcome = await _runPipeline(rawValue);
    final context = outcome.context;
    final flag = outcome.flag;

    await _persistLocal(rawValue, flag, context);

    if (outcome.failure != null) throw outcome.failure!;

    return context;
  }

  Future<_PipelineOutcome> _runPipeline(String rawValue) async {
    final steps = <ScanStep>[
      ParseStep(_loggerService),
      CardLookupStep(_localRepository, _loggerService),
      ValidityStep(_loggerService),
      InvalidationStep(_loggerService),
      UsedStep(_loggerService),
      SubmitRemoteStep(_scanRemoteRepository, _dlqService, _loggerService),
      MarkUsedStep(_localRepository, _loggerService),
      BroadcastStep(_peerSyncService, _loggerService),
    ];

    var context = ScanContext(rawValue: rawValue);

    try {
      for (final step in steps) {
        context = await step.execute(context);
      }
    } on ScanException catch (e) {
      return _PipelineOutcome(context: e.context, flag: e.flag, failure: e);
    }

    return _PipelineOutcome(context: context, flag: ScanFlag.passedOk);
  }

  Future<void> _persistLocal(
    String rawValue,
    ScanFlag flag,
    ScanContext context,
  ) async {
    final profile = await _secureStorage.getProfile();
    final readerId = profile?['id'] as String? ?? '';

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
  }
}

class _PipelineOutcome {
  final ScanContext context;
  final ScanFlag flag;
  final ScanException? failure;

  const _PipelineOutcome({
    required this.context,
    required this.flag,
    this.failure,
  });
}
