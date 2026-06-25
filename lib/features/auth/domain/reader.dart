class Reader {
  final String id;
  final String username;
  final bool inactive;
  final String venueId;
  final String eventId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Reader({
    required this.id,
    required this.username,
    required this.inactive,
    required this.venueId,
    required this.eventId,
    required this.createdAt,
    required this.updatedAt,
  });
}