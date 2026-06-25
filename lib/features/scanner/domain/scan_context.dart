import 'package:reader/features/tickets/domain/ticket.dart';

class ScanContext {
  final String rawValue;
  final Ticket? ticket;

  const ScanContext({required this.rawValue, this.ticket});

  ScanContext copyWith({Ticket? ticket}) => ScanContext(
        rawValue: rawValue,
        ticket: ticket ?? this.ticket,
      );
}