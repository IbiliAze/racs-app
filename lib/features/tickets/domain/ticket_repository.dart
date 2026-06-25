import 'package:reader/features/tickets/domain/ticket.dart';
import 'package:reader/features/tickets/domain/ticket_params.dart';

abstract class TicketRepository {
  Future<Ticket?> getTicketById(String id);
  Future<Ticket?> getTicketByLabel(String name);
  Future<Ticket?> getTicketByValue(String value);
  Future<List<Ticket>> getTickets(TicketParams params);
  Future<Ticket?> markUsed(String id);
}