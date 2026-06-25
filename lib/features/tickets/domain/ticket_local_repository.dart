import 'package:reader/features/tickets/domain/ticket.dart';
import 'package:reader/features/tickets/domain/ticket_params.dart';

abstract class TicketLocalRepository {
  Future<Ticket?> getTicketById(String id);
  Future<Ticket?> getTicketByLabel(String label);
  Future<Ticket?> getTicketByValue(String value);
  Future<List<Ticket>> getTickets(TicketParams params);
  Future<int> countTickets(String eventId);
  Future<Ticket?> markUsed(String id);
  Future<void> upsert(Ticket ticket);
  Future<void> upsertFromMap(Map<String, dynamic> map);
  Future<void> upsertAll(List<Ticket> tickets);
  Future<void> delete(String id);
}
