import 'package:reader/features/dlq/domain/dlq_item.dart';
import 'package:reader/features/scanner/domain/scan_flag.dart';

class DlqItemDto {
  final int? id;
  final String scannedValue;
  final String flag;
  final String? ticketId;
  final String createdAt;

  const DlqItemDto({
    this.id,
    required this.scannedValue,
    required this.flag,
    this.ticketId,
    required this.createdAt,
  });

  factory DlqItemDto.fromMap(Map<String, dynamic> map) => DlqItemDto(
    id: map['id'] as int?,
    scannedValue: map['scannedValue'] as String,
    flag: map['flag'] as String,
    ticketId: map['ticketId'] as String?,
    createdAt: map['createdAt'] as String,
  );

  factory DlqItemDto.fromDomain(DlqItem dlqItem) => DlqItemDto(
    id: dlqItem.id,
    scannedValue: dlqItem.scannedValue,
    flag: dlqItem.flag.serverValue,
    ticketId: dlqItem.ticketId,
    createdAt: (dlqItem.createdAt ?? DateTime.now()).toIso8601String(),
  );

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'scannedValue': scannedValue,
    'flag': flag,
    if (ticketId != null) 'ticketId': ticketId,
    'createdAt': createdAt,
  };

  DlqItem toDomain() => DlqItem(
    id: id,
    scannedValue: scannedValue,
    flag: ScanFlag.values.firstWhere(
      (f) => f.serverValue == flag,
      orElse: () => ScanFlag.unknown,
    ),
    ticketId: ticketId,
    createdAt: DateTime.parse(createdAt),
  );
}