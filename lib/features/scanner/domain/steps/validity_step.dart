import 'package:reader/features/logger/application/logger_service.dart';
import 'package:reader/features/scanner/domain/scan_context.dart';
import 'package:reader/features/scanner/domain/scan_exception.dart';
import 'package:reader/features/scanner/domain/scan_flag.dart';
import 'package:reader/features/scanner/domain/scan_step.dart';

class ValidityStep extends ScanStep {
  ValidityStep(LoggerService logger) : super(logger);

  @override
  Future<ScanContext> execute(ScanContext context) async {
    final card = context.card!;
    final now = DateTime.now();
    await logger.debug('Checking validity for card: ${card.id}', className: 'ValidityStep');

    if (card.validFrom != null && now.isBefore(card.validFrom!)) {
      await logger.warning('Card not yet valid: ${card.id}', className: 'ValidityStep');
      throw ScanException('Card is not yet valid', context, flag: ScanFlag.rejected);
    }
    if (card.validUntil != null && now.isAfter(card.validUntil!)) {
      await logger.warning('Card expired: ${card.id}', className: 'ValidityStep');
      throw ScanException('Card has expired', context, flag: ScanFlag.rejected);
    }

    await logger.info('Validity check passed for card: ${card.id}', className: 'ValidityStep');
    return context;
  }
}