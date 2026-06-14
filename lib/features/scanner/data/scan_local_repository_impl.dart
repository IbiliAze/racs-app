import 'package:injectable/injectable.dart';
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
}