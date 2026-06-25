import 'package:reader/features/tickets/domain/ticket_local_repository.dart';
import 'package:reader/features/logger/application/logger_service.dart';
import 'package:reader/features/scanner/domain/scan_context.dart';
import 'package:reader/features/scanner/domain/scan_exception.dart';
import 'package:reader/features/scanner/domain/scan_flag.dart';
import 'package:reader/features/scanner/domain/scan_step.dart';

class TicketLookupStep extends ScanStep {
  final TicketLocalRepository _localRepository;

  TicketLookupStep(this._localRepository, LoggerService logger) : super(logger);

  @override
  Future<ScanContext> execute(ScanContext context) async {
    await logger.debug('Looking up ticket with value: "${context.rawValue}"', className: 'TicketLookupStep');
    final ticket = await _localRepository.getTicketByValue(context.rawValue);
    if (ticket == null) {
      await logger.warning('Ticket not found for value: "${context.rawValue}"', className: 'TicketLookupStep');
      throw ScanException('Ticket not found', context, flag: ScanFlag.unknownTicket);
    }
    await logger.info('Ticket found: ${ticket.id}', className: 'TicketLookupStep');
    return context.copyWith(ticket: ticket);
  }
}