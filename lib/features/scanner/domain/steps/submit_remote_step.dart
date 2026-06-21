import 'package:reader/features/dlq/application/dlq_service.dart';
import 'package:reader/features/dlq/domain/dlq_item.dart';
import 'package:reader/features/logger/application/logger_service.dart';
import 'package:reader/features/scanner/domain/scan_context.dart';
import 'package:reader/features/scanner/domain/scan_exception.dart';
import 'package:reader/features/scanner/domain/scan_flag.dart';
import 'package:reader/features/scanner/domain/scan_remote_repository.dart';
import 'package:reader/features/scanner/domain/scan_step.dart';
import 'package:reader/features/scanner/domain/scan_submit_exception.dart';

class SubmitRemoteStep extends ScanStep {
  final ScanRemoteRepository _scanRemoteRepository;
  final DlqService _dlqService;

  SubmitRemoteStep(
    this._scanRemoteRepository,
    this._dlqService,
    LoggerService logger,
  ) : super(logger);

  @override
  Future<ScanContext> execute(ScanContext context) async {
    final card = context.card!;
    await logger.debug(
      'Submitting card in remote: ${card.id}',
      className: 'SubmitRemoteStep',
    );

    try {
      await _scanRemoteRepository.submit(
        scannedValue: context.rawValue,
        flag: ScanFlag.passedOk,
        cardId: context.card?.id,
      );

      await logger.info(
        'Card submitted: ${card.id}',
        className: 'SubmitRemoteStep',
      );
      return context;
    } on ScanSubmitException catch (e) {
      if (e.isRejected) {
        // 4xx — the server responded and denied the scan (e.g. duplicate).
        // Reject the pipeline so the card is never marked used or broadcast.
        // The attempt is recorded locally via the flag on this exception.
        await logger.error(
          'Scan rejected by server: $e',
          className: 'SubmitRemoteStep',
        );
        throw ScanException(
          'Card has already been used',
          context,
          flag: ScanFlag.duplicateAttemptServer,
        );
      }
      // 5xx — the server could not process the scan. Queue it for retry.
      await logger.error(
        'Server could not process scan, queuing to DLQ: $e',
        className: 'SubmitRemoteStep',
      );
      await _queueForRetry(context.rawValue, ScanFlag.passedOk, context);
      return context;
    } catch (e) {
      // Server unreachable / timeout / network error — queue for retry and
      // continue, so a down server never freezes the gate.
      await logger.error(
        'Failed to submit scan to server: $e',
        className: 'SubmitRemoteStep',
      );
      await _queueForRetry(context.rawValue, ScanFlag.passedOk, context);
      return context;
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
}
