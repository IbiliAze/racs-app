import 'package:reader/features/scanner/domain/scan_record.dart';

class ScanDto {
  final int? id;
  final String readerId;
  final String scannedValue;
  final String flag;
  final String? cardLabel;
  final String createdAt;

  const ScanDto({
    this.id,
    required this.readerId,
    required this.scannedValue,
    required this.flag,
    this.cardLabel,
    required this.createdAt,
  });

  factory ScanDto.fromMap(Map<String, dynamic> map) => ScanDto(
        id: map['id'] as int?,
        readerId: map['readerId'] as String,
        scannedValue: map['scannedValue'] as String,
        flag: map['flag'] as String,
        cardLabel: map['cardLabel'] as String?,
        createdAt: map['createdAt'] as String,
      );

  factory ScanDto.fromDomain(ScanRecord record) => ScanDto(
        id: record.id,
        readerId: record.readerId,
        scannedValue: record.scannedValue,
        flag: record.flag,
        cardLabel: record.cardLabel,
        createdAt: record.createdAt.toIso8601String(),
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'readerId': readerId,
        'scannedValue': scannedValue,
        'flag': flag,
        'cardLabel': cardLabel,
        'createdAt': createdAt,
      };

  ScanRecord toDomain() => ScanRecord(
        id: id,
        readerId: readerId,
        scannedValue: scannedValue,
        flag: flag,
        cardLabel: cardLabel,
        createdAt: DateTime.parse(createdAt),
      );
}