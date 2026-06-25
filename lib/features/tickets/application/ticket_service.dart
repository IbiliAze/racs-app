import 'package:injectable/injectable.dart';
import 'package:reader/features/tickets/domain/ticket.dart';
import 'package:reader/features/tickets/domain/ticket_local_repository.dart';
import 'package:reader/features/tickets/domain/ticket_params.dart';
import 'package:reader/features/tickets/domain/ticket_repository.dart';
import 'package:reader/features/logger/application/logger_service.dart';

@lazySingleton
class TicketService {
  final TicketRepository _remoteRepository;
  final TicketLocalRepository _localRepository;
  final LoggerService _loggerService;

  TicketService(
      this._remoteRepository,
      this._localRepository,
      this._loggerService);

  Future<Ticket?> getTicketById(String id) => _localRepository.getTicketById(id);
  Future<Ticket?> getTicketByLabel(String label) => _localRepository.getTicketByLabel(label);
  Future<Ticket?> getTicketByValue(String value) => _localRepository.getTicketByValue(value);
  Future<List<Ticket>> getTickets(TicketParams params) => _localRepository.getTickets(params);
  Future<int> countTickets(String eventId) => _localRepository.countTickets(eventId);
  Future<void> upsert(Ticket ticket) => _localRepository.upsert(ticket);
  Future<void> upsertFromMap(Map<String, dynamic> map) => _localRepository.upsertFromMap(map);
  Future<void> delete(String id) => _localRepository.delete(id);

  Future<void> downloadTickets(String eventId) async {
    try {
      _loggerService.debug("Syncing from remote", className: 'TicketSyncService');
      final tickets = await _remoteRepository.getTickets(TicketParams(eventId: eventId));
      _loggerService.debug("Inserting ${tickets.length} tickets from remote", className: 'TicketSyncService');
      await _localRepository.upsertAll(tickets);
      _loggerService.info('Synced from remote', className: 'TicketSyncService');
    } catch (e) {
      _loggerService.error(e.toString(), className: 'TicketSyncService');
    }
  }
}