class Reader {
  final String id;
  final String username;
  final bool inactive;
  final String locationId;
  final String ownerId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Reader({
    required this.id,
    required this.username,
    required this.inactive,
    required this.locationId,
    required this.ownerId,
    required this.createdAt,
    required this.updatedAt,
  });
}