import 'package:reader/features/logger/domain/log.dart';

abstract class LogRepository {
  Future<void> insert(Log log);
  Future<List<Log>> getAll();
  Future<void> clearAll();
}