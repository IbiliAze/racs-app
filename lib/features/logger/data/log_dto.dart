import 'package:racs_reader/features/logger/domain/log.dart';

class LogDto {
  final int? id;
  final String message;
  final String level;
  final String className;
  final String timestamp;

  const LogDto({
    this.id,
    required this.message,
    required this.level,
    required this.className,
    required this.timestamp,
  });

  factory LogDto.fromMap(Map<String, dynamic> map) => LogDto(
    id: map['id'] as int?,
    message: map['message'] as String,
    level: map['level'] as String,
    className: map['className'] as String,
    timestamp: map['timestamp'] as String,
  );

  factory LogDto.fromDomain(Log log) => LogDto(
    id: log.id,
    message: log.message,
    level: log.level.name,
    className: log.className,
    timestamp: log.timestamp.toIso8601String(),
  );

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'message': message,
    'level': level,
    'className': className,
    'timestamp': timestamp,
  };

  Log toDomain() => Log(
    id: id,
    message: message,
    level: LogLevel.values.firstWhere(
      (e) => e.name == level,
      orElse: () => LogLevel.info,
    ),
    className: className,
    timestamp: DateTime.parse(timestamp),
  );
}
