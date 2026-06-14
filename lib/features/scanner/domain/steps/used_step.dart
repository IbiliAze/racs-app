import 'package:reader/features/logger/application/logger_service.dart';
import 'package:reader/features/scanner/domain/scan_context.dart';
import 'package:reader/features/scanner/domain/scan_exception.dart';
import 'package:reader/features/scanner/domain/scan_flag.dart';
import 'package:reader/features/scanner/domain/scan_step.dart';

class UsedStep extends ScanStep {
  UsedStep(LoggerService logger) : super(logger);

  @override
  Future<ScanContext> execute(ScanContext context) async {
    final card = context.card!;
    await logger.debug('Checking used status for card: ${card.id}', className: 'UsedStep');

    if (card.used) {
      await logger.warning('Card already used: ${card.id} at ${card.usedAt}', className: 'UsedStep');
      throw ScanException('Card has already been used', context, flag: ScanFlag.duplicateAttemptMesh);
    }

    await logger.info('Used check passed for card: ${card.id}', className: 'UsedStep');
    return context;
  }
}