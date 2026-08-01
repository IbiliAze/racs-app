class Campaign {
  final String id;
  final String name;
  final DateTime? validFrom;
  final DateTime? validUntil;
  final DateTime createdAt;
  final DateTime updatedAt;

  Campaign({
    required this.id,
    required this.name,
    this.validFrom,
    this.validUntil,
    required this.createdAt,
    required this.updatedAt,
  });
}
