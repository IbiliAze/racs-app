enum LogLevel { debug, info, warning, error }

class Log {
  final int? id;
  final String message;
  final LogLevel level;
  final String className;
  final DateTime timestamp;

  const Log({
    this.id,
    required this.message,
    required this.level,
    required this.className,
    required this.timestamp,
  });
}