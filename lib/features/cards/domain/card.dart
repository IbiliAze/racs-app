enum CardType { voucher, ticket, membership, pass }

class Card {
  final String id;
  final String value;
  final String label;
  final CardType type;
  final String ownerId;
  final DateTime? validFrom;
  final DateTime? validUntil;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? usedAt;
  final bool used;
  final bool invalidated;

  Card({
    required this.id,
    required this.value,
    required this.label,
    required this.type,
    required this.ownerId,
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