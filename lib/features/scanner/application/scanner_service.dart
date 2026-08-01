import 'package:injectable/injectable.dart';
import 'package:racs_reader/core/storage/secure_storage.dart';
import 'package:racs_reader/features/cards/domain/card_local_repository.dart';
import 'package:racs_reader/features/dlq/application/dlq_service.dart';
import 'package:racs_reader/features/dlq/domain/dlq_item.dart';
import 'package:racs_reader/features/logger/application/logger_service.dart';
import 'package:racs_reader/features/scanner/application/peer_sync_service.dart';
import 'package:racs_reader/features/scanner/domain/scan_context.dart';
import 'package:racs_reader/features/scanner/domain/scan_exception.dart';
import 'package:racs_reader/features/scanner/domain/scan_flag.dart';
import 'package:racs_reader/features/scanner/domain/scan_local_repository.dart';
import 'package:racs_reader/features/scanner/domain/scan_record.dart';
import 'package:racs_reader/features/scanner/domain/scan_remote_repository.dart';
import 'package:racs_reader/features/scanner/domain/scan_step.dart';
import 'package:racs_reader/features/scanner/domain/scan_submit_exception.dart';
import 'package:racs_reader/features/scanner/domain/steps/broadcast_step.dart';
import 'package:racs_reader/features/scanner/domain/steps/card_lookup_step.dart';
import 'package:racs_reader/features/scanner/domain/steps/invalidation_step.dart';
import 'package:racs_reader/features/scanner/domain/steps/mark_used_step.dart';
import 'package:racs_reader/features/scanner/domain/steps/parse_step.dart';
import 'package:racs_reader/features/scanner/domain/steps/submit_remote_step.dart';
import 'package:racs_reader/features/scanner/domain/steps/used_step.dart';
import 'package:racs_reader/features/scanner/domain/steps/validity_step.dart';

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
  Future<void> upsertFromMap(Map<String, dynamic> map) =>
      _scanLocalRepository.upsertFromMap(map);
  Future<void> delete(String id) => _scanLocalRepository.delete(id);

  Future<ScanContext> scan(String rawValue) async {
    final outcome = await _runPipeline(rawValue);
    final context = outcome.context;
    final flag = outcome.flag;

    await _persistLocal(rawValue, flag, context);

    // Scans rejected before SubmitRemoteStep never reached the server. Record
    // them now with their real flag so every scan attempt is visible
    // server-side, not just the ones that passed local validation.
    if (!context.submitted) {
      await _submitRemote(rawValue, flag, context);
    }

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
      // e.context carries `submitted` — true only if SubmitRemoteStep ran
      // before the failure — so the caller knows whether to still record it.
      return _PipelineOutcome(context: e.context, flag: e.flag, failure: e);
    }

    return _PipelineOutcome(context: context, flag: ScanFlag.passedOk);
  }

  /// Records a scan that was rejected locally (before SubmitRemoteStep) on the
  /// server. Mirrors SubmitRemoteStep's resilience: a transient failure (5xx or
  /// unreachable) is queued to the DLQ for later retry; a 4xx is definitive and
  /// dropped. Never rethrows — recording an already-decided scan must not change
  /// the outcome shown to the reader.
  Future<void> _submitRemote(
    String rawValue,
    ScanFlag flag,
    ScanContext context,
  ) async {
    try {
      await _scanRemoteRepository.submit(
        scannedValue: rawValue,
        flag: flag,
        cardId: context.card?.id,
      );
      await _loggerService.info(
        'Rejected scan recorded on server: ${flag.serverValue}',
        className: 'ScannerService',
      );
    } on ScanSubmitException catch (e) {
      if (e.isRetryable) {
        await _queueForRetry(rawValue, flag, context);
      }
      _loggerService.error(
        'Failed to record rejected scan on server: $e',
        className: 'ScannerService',
      );
    } catch (e) {
      // Unreachable / timeout — queue for retry so the attempt isn't lost.
      await _queueForRetry(rawValue, flag, context);
      _loggerService.error(
        'Failed to record rejected scan, queued to DLQ: $e',
        className: 'ScannerService',
      );
    }
  }

  Future<void> _queueForRetry(
    String rawValue,
    ScanFlag flag,
    ScanContext context,
  ) {
    return _dlqService.insertItem(
      DlqItem(scannedValue: rawValue, flag: flag, cardId: context.card?.id),
    );
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
