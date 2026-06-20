import 'package:injectable/injectable.dart';
import 'package:reader/features/logger/domain/log.dart';
import 'package:reader/features/logger/domain/log_params.dart';
import 'package:reader/features/logger/domain/log_repository.dart';

@lazySingleton
class LoggerService {
  final LogRepository _logRepository;

  LoggerService(this._logRepository);

  Future<void> log(String message, {
    required LogLevel level,
    required String className,
  }) =>
      _logRepository.insert(Log(
        message: message,
        level: level,
        className: className,
        timestamp: DateTime.now(),
      ));

  Future<void> debug(String message, {required String className}) =>
      log(message, level: LogLevel.debug, className: className);

  Future<void> info(String message, {required String className}) =>
      log(message, level: LogLevel.info, className: className);

  Future<void> warning(String message, {required String className}) =>
      log(message, level: LogLevel.warning, className: className);

  Future<void> error(String message, {required String className}) =>
      log(message, level: LogLevel.error, className: className);

  Future<List<Log>> getLogs(LogParams params) => _logRepository.getPaged(params);
  Future<int> countLogs() => _logRepository.count();

  Future<void> clearLogs() => _logRepository.clearAll();
}