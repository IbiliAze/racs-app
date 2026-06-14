import 'package:reader/features/logger/application/logger_service.dart';
import 'package:reader/features/scanner/domain/scan_context.dart';
import 'package:reader/features/scanner/domain/scan_exception.dart';
import 'package:reader/features/scanner/domain/scan_flag.dart';
import 'package:reader/features/scanner/domain/scan_step.dart';

class InvalidationStep extends ScanStep {
  InvalidationStep(LoggerService logger) : super(logger);

  @override
  Future<ScanContext> execute(ScanContext context) async {
    final card = context.card!;
    await logger.debug('Checking invalidation for card: ${card.id}', className: 'InvalidationStep');

    if (card.invalidated) {
      await logger.warning('Card is invalidated: ${card.id}', className: 'InvalidationStep');
      throw ScanException('Card has been invalidated', context, flag: ScanFlag.rejected);
    }

    await logger.info('Invalidation check passed for card: ${card.id}', className: 'InvalidationStep');
    return context;
  }
}