import 'package:racs_reader/features/scanner/domain/scan_flag.dart';

class DlqItem {
  final int? id;
  final String scannedValue;
  final ScanFlag flag;
  final String? cardId;
  final DateTime? createdAt;

  DlqItem({
    this.id,
    required this.scannedValue,
    required this.flag,
    this.cardId,
    this.createdAt,
  });
}
