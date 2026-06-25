enum TicketType { voucher, ticket, membership, pass }

class Ticket {
  final String id;
  final String value;
  final String label;
  final TicketType type;
  final String eventId;
  final DateTime? validFrom;
  final DateTime? validUntil;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? usedAt;
  final bool used;
  final bool invalidated;

  Ticket({
    required this.id,
    required this.value,
    required this.label,
    required this.type,
    required this.eventId,
    this.validFrom,
    this.validUntil,
    this.metadata,
    this.usedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.used,
    required this.invalidated,
  });
}