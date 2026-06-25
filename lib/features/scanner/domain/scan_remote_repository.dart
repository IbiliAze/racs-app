import 'package:reader/features/scanner/domain/scan_flag.dart';

abstract class ScanRemoteRepository {
  Future<void> submit({
    required String scannedValue,
    required ScanFlag flag,
    String? ticketId,
  });
}