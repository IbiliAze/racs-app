class ScanRecord {
  final int? id;
  final String readerId;
  final String scannedValue;
  final String flag;
  final String? cardLabel;
  final DateTime createdAt;

  const ScanRecord({
    this.id,
    required this.readerId,
    required this.scannedValue,
    required this.flag,
    this.cardLabel,
    required this.createdAt,
  });
}
