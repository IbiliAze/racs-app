import 'package:reader/features/scanner/domain/scan_flag.dart';

class DlqItem {
  final int? id;
  final String scannedValue;
  final ScanFlag flag;
  final String? ticketId;
  final DateTime? createdAt;

  DlqItem({
    this.id,
    required this.scannedValue,
    required this.flag,
    this.ticketId,
    this.createdAt,
  });
}
