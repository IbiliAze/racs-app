import 'package:reader/features/logger/domain/log.dart';
import 'package:reader/features/logger/domain/log_params.dart';

abstract class LogRepository {
  Future<void> insert(Log log);
  Future<List<Log>> getPaged(LogParams params);
  Future<int> count();
  Future<void> clearAll();
}