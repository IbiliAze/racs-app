import 'package:reader/features/tickets/domain/ticket_local_repository.dart';
import 'package:reader/features/logger/application/logger_service.dart';
import 'package:reader/features/scanner/domain/scan_context.dart';
import 'package:reader/features/scanner/domain/scan_exception.dart';
import 'package:reader/features/scanner/domain/scan_step.dart';

class MarkUsedStep extends ScanStep {
  final TicketLocalRepository _localRepository;

  MarkUsedStep(this._localRepository, LoggerService logger) : super(logger);

  @override
  Future<ScanContext> execute(ScanContext context) async {
    final ticket = context.ticket!;
    await logger.info('Marking ticket as used locally: ${ticket.id}', className: 'MarkUsedStep');

    final updated = await _localRepository.markUsed(ticket.id);
    if (updated == null) {
      await logger.error('Failed to mark ticket as used: ${ticket.id}', className: 'MarkUsedStep');
      throw ScanException('Failed to mark ticket as used', context);
    }

    await logger.info('Ticket marked as used: ${ticket.id}', className: 'MarkUsedStep');
    return context.copyWith(ticket: updated);
  }
}