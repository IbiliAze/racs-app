import 'package:reader/features/auth/domain/reader.dart';

class ReaderDto {
  final String id;
  final String username;
  final bool inactive;
  final String venueId;
  final String eventId;
  final String createdAt;
  final String updatedAt;

  const ReaderDto({
    required this.id,
    required this.username,
    required this.inactive,
    required this.venueId,
    required this.eventId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ReaderDto.fromJson(Map<String, dynamic> json) {
    return ReaderDto(
      id: json['id'] as String,
      username: json['username'] as String,
      inactive: json['inactive'] as bool,
      venueId: json['venueId'] as String,
      eventId: json['eventId'] as String,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );
  }

  Reader toDomain() {
    return Reader(
      id: id,
      username: username,
      inactive: inactive,
      venueId: venueId,
      eventId: eventId,
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
    );
  }
}