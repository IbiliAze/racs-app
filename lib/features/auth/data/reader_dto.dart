import 'package:reader/features/auth/domain/reader.dart';

class ReaderDto {
  final String id;
  final String username;
  final bool inactive;
  final String locationId;
  final String createdAt;
  final String updatedAt;

  const ReaderDto({
    required this.id,
    required this.username,
    required this.inactive,
    required this.locationId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ReaderDto.fromJson(Map<String, dynamic> json) {
    return ReaderDto(
      id: json['id'] as String,
      username: json['username'] as String,
      inactive: json['inactive'] as bool,
      locationId: json['locationId'] as String,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );
  }

  Reader toDomain() {
    return Reader(
      id: id,
      username: username,
      inactive: inactive,
      locationId: locationId,
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
    );
  }
}