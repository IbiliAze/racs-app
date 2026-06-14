import 'package:injectable/injectable.dart';
import 'package:reader/core/storage/local_database.dart';
import 'package:reader/features/logger/data/log_dto.dart';
import 'package:reader/features/logger/domain/log.dart';
import 'package:reader/features/logger/domain/log_repository.dart';

@Injectable(as: LogRepository)
class LogRepositoryImpl implements LogRepository {
  static const _table = 'logs';

  final LocalDatabase _db;

  LogRepositoryImpl(this._db);

  @override
  Future<void> insert(Log log) async {
    final db = await _db.database;
    await db.insert(_table, LogDto.fromDomain(log).toMap());
  }

  @override
  Future<List<Log>> getAll() async {
    final db = await _db.database;
    final rows = await db.query(_table, orderBy: 'timestamp DESC');
    return rows.map((r) => LogDto.fromMap(r).toDomain()).toList();
  }

  @override
  Future<void> clearAll() async {
    final db = await _db.database;
    await db.delete(_table);
  }
}