import 'package:injectable/injectable.dart';
import 'package:sqflite/sqflite.dart';
import 'package:reader/core/storage/local_database.dart';
import 'package:reader/features/logger/data/log_dto.dart';
import 'package:reader/features/logger/domain/log.dart';
import 'package:reader/features/logger/domain/log_params.dart';
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
  Future<List<Log>> getPaged(LogParams params) async {
    final db = await _db.database;
    final offset = params.page != null && params.size != null
        ? params.page! * params.size!
        : null;
    final rows = await db.query(
      _table,
      orderBy: 'timestamp DESC',
      limit: params.size,
      offset: offset,
    );
    return rows.map((r) => LogDto.fromMap(r).toDomain()).toList();
  }

  @override
  Future<int> count() async {
    final db = await _db.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM $_table');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  @override
  Future<void> clearAll() async {
    final db = await _db.database;
    await db.delete(_table);
  }
}