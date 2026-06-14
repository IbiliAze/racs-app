import 'package:reader/features/scanner/domain/scan_record.dart';

abstract class ScanLocalRepository {
  Future<void> insert(ScanRecord record);
  Future<List<ScanRecord>> getAll();
}