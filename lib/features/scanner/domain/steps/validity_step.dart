import 'package:reader/features/logger/application/logger_service.dart';
import 'package:reader/features/scanner/domain/scan_context.dart';
import 'package:reader/features/scanner/domain/scan_exception.dart';
import 'package:reader/features/scanner/domain/scan_flag.dart';
import 'package:reader/features/scanner/domain/scan_step.dart';

class ValidityStep extends ScanStep {
  ValidityStep(LoggerService logger) : super(logger);

  @override
  Future<ScanContext> execute(ScanContext context) async {
    final ticket = context.ticket!;
    final now = DateTime.now();
    await logger.debug('Checking validity for ticket: ${ticket.id}', className: 'ValidityStep');

    if (ticket.validFrom != null && now.isBefore(ticket.validFrom!)) {
      await logger.warning('Ticket not yet valid: ${ticket.id}', className: 'ValidityStep');
      throw ScanException('Ticket is not yet valid', context, flag: ScanFlag.rejected);
    }
    if (ticket.validUntil != null && now.isAfter(ticket.validUntil!)) {
      await logger.warning('Ticket expired: ${ticket.id}', className: 'ValidityStep');
      throw ScanException('Ticket has expired', context, flag: ScanFlag.rejected);
    }

    await logger.info('Validity check passed for ticket: ${ticket.id}', className: 'ValidityStep');
    return context;
  }
}