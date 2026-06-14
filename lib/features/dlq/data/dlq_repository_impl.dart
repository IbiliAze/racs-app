import 'package:injectable/injectable.dart';
import 'package:reader/core/storage/local_database.dart';
import 'package:reader/features/dlq/data/dlq_item_dto.dart';
import 'package:reader/features/dlq/domain/dlq_item.dart';
import 'package:reader/features/dlq/domain/dlq_repository.dart';

@Injectable(as: DlqRepository)
class DlqRepositoryImpl implements DlqRepository{
  static const _table = 'dlq';

  final LocalDatabase _db;

  DlqRepositoryImpl(this._db);

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
  Future<List<DlqItem>> getAll() async {
    final db = await _db.database;
    final rows = await db.query(_table, orderBy: 'createdAt DESC');
    return rows.map((r) => DlqItemDto.fromMap(r).toDomain()).toList();
  }

  @override
  Future<void> insert(DlqItem dlqItem) async {
    final db = await _db.database;
    await db.insert(_table, DlqItemDto.fromDomain(dlqItem).toMap());
  }
}