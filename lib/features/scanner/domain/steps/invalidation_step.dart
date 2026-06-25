import 'package:reader/features/logger/application/logger_service.dart';
import 'package:reader/features/scanner/domain/scan_context.dart';
import 'package:reader/features/scanner/domain/scan_exception.dart';
import 'package:reader/features/scanner/domain/scan_flag.dart';
import 'package:reader/features/scanner/domain/scan_step.dart';

class InvalidationStep extends ScanStep {
  InvalidationStep(LoggerService logger) : super(logger);

  @override
  Future<ScanContext> execute(ScanContext context) async {
    final ticket = context.ticket!;
    await logger.debug('Checking invalidation for ticket: ${ticket.id}', className: 'InvalidationStep');

    if (ticket.invalidated) {
      await logger.warning('Ticket is invalidated: ${ticket.id}', className: 'InvalidationStep');
      throw ScanException('Ticket has been invalidated', context, flag: ScanFlag.rejected);
    }

    await logger.info('Invalidation check passed for ticket: ${ticket.id}', className: 'InvalidationStep');
    return context;
  }
}