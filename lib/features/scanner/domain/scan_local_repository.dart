import 'package:racs_reader/features/scanner/domain/scan_record.dart';

abstract class ScanLocalRepository {
  Future<List<ScanRecord>> getAll();
  Future<void> insert(ScanRecord record);
  Future<void> upsert(ScanRecord record);
  Future<void> upsertFromMap(Map<String, dynamic> map);
  Future<void> delete(String id);
}
