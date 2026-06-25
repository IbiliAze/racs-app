import 'package:reader/features/logger/application/logger_service.dart';
import 'package:reader/features/scanner/domain/scan_context.dart';
import 'package:reader/features/scanner/domain/scan_exception.dart';
import 'package:reader/features/scanner/domain/scan_flag.dart';
import 'package:reader/features/scanner/domain/scan_step.dart';

class UsedStep extends ScanStep {
  UsedStep(LoggerService logger) : super(logger);

  @override
  Future<ScanContext> execute(ScanContext context) async {
    final ticket = context.ticket!;
    await logger.debug('Checking used status for ticket: ${ticket.id}', className: 'UsedStep');

    if (ticket.used) {
      await logger.warning('Ticket already used: ${ticket.id} at ${ticket.usedAt}', className: 'UsedStep');
      throw ScanException('Ticket has already been used', context, flag: ScanFlag.duplicateAttemptMesh);
    }

    await logger.info('Used check passed for ticket: ${ticket.id}', className: 'UsedStep');
    return context;
  }
}