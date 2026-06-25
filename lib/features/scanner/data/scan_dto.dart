import 'package:reader/features/scanner/domain/scan_record.dart';

class ScanDto {
  final int? id;
  final String readerId;
  final String scannedValue;
  final String flag;
  final String? ticketLabel;
  final String createdAt;

  const ScanDto({
    this.id,
    required this.readerId,
    required this.scannedValue,
    required this.flag,
    this.ticketLabel,
    required this.createdAt,
  });

  factory ScanDto.fromMap(Map<String, dynamic> map) => ScanDto(
        id: map['id'] as int?,
        readerId: map['readerId'] as String,
        scannedValue: map['scannedValue'] as String,
        flag: map['flag'] as String,
        ticketLabel: map['ticketLabel'] as String?,
        createdAt: map['createdAt'] as String,
      );

  factory ScanDto.fromDomain(ScanRecord record) => ScanDto(
        id: record.id,
        readerId: record.readerId,
        scannedValue: record.scannedValue,
        flag: record.flag,
        ticketLabel: record.ticketLabel,
        createdAt: record.createdAt.toIso8601String(),
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'readerId': readerId,
        'scannedValue': scannedValue,
        'flag': flag,
        'ticketLabel': ticketLabel,
        'createdAt': createdAt,
      };

  ScanRecord toDomain() => ScanRecord(
        id: id,
        readerId: readerId,
        scannedValue: scannedValue,
        flag: flag,
        ticketLabel: ticketLabel,
        createdAt: DateTime.parse(createdAt),
      );
}