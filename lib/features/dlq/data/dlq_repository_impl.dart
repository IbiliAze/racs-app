import 'package:injectable/injectable.dart';
import 'package:sqflite/sqflite.dart';
import 'package:racs_reader/core/storage/local_database.dart';
import 'package:racs_reader/features/dlq/data/dlq_item_dto.dart';
import 'package:racs_reader/features/dlq/domain/dlq_item.dart';
import 'package:racs_reader/features/dlq/domain/dlq_params.dart';
import 'package:racs_reader/features/dlq/domain/dlq_repository.dart';

@Injectable(as: DlqRepository)
class DlqRepositoryImpl implements DlqRepository {
  static const _table = 'dlq';

  final LocalDatabase _db;

  DlqRepositoryImpl(this._db);

  @override
  Future<List<DlqItem>> getPaged(DlqParams params) async {
    final db = await _db.database;
    final offset = params.page != null && params.size != null
        ? params.page! * params.size!
        : null;
    final rows = await db.query(
      _table,
      orderBy: 'createdAt DESC',
      limit: params.size,
      offset: offset,
    );
    return rows.map((r) => DlqItemDto.fromMap(r).toDomain()).toList();
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

  @override
  Future<void> clearItem(DlqItem dlqItem) async {
    if (dlqItem.id == null) return;
    final db = await _db.database;
    await db.delete(_table, where: 'id = ?', whereArgs: [dlqItem.id]);
  }

  @override
  Future<void> insert(DlqItem dlqItem) async {
    final db = await _db.database;
    await db.insert(_table, DlqItemDto.fromDomain(dlqItem).toMap());
  }
}
