import 'package:injectable/injectable.dart';
import 'package:sqflite/sqflite.dart';
import 'package:reader/core/storage/local_database.dart';
import 'package:reader/features/scanner/data/scan_dto.dart';
import 'package:reader/features/scanner/domain/scan_local_repository.dart';
import 'package:reader/features/scanner/domain/scan_record.dart';

@Injectable(as: ScanLocalRepository)
class ScanLocalRepositoryImpl implements ScanLocalRepository {
  static const _table = 'scans';

  final LocalDatabase _db;

  ScanLocalRepositoryImpl(this._db);

  @override
  Future<void> insert(ScanRecord record) async {
    final db = await _db.database;
    await db.insert(_table, ScanDto.fromDomain(record).toMap());
  }

  @override
  Future<List<ScanRecord>> getAll() async {
    final db = await _db.database;
    final rows = await db.query(_table, orderBy: 'createdAt DESC');
    return rows.map((r) => ScanDto.fromMap(r).toDomain()).toList();
  }

  @override
  Future<void> upsert(ScanRecord scan) async {
    final db = await _db.database;
    await db.insert(
      _table,
      ScanDto.fromDomain(scan).toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> upsertFromMap(Map<String, dynamic> map) async {
    final db = await _db.database;
    await db.insert(
      _table,
      ScanDto.fromMap(map).toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> delete(String id) async {
    final db = await _db.database;
    await db.delete(_table, where: 'id = ?', whereArgs: [id]);
  }
}