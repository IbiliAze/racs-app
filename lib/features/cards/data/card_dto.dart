import 'dart:convert';

import 'package:reader/features/cards/domain/card.dart';

class CardDto {
  final String id;
  final String locationId;
  final String value;
  final String label;
  final String type;
  final String ownerId;
  final String? validFrom;
  final String? validUntil;
  final Map<String, dynamic>? metadata;
  final String createdAt;
  final String updatedAt;
  final String? usedAt;
  final bool used;
  final bool invalidated;

  const CardDto({
    required this.id,
    required this.locationId,
    required this.value,
    required this.label,
    required this.type,
    required this.ownerId,
    this.validFrom,
    this.validUntil,
    this.metadata,
    this.usedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.used,
    required this.invalidated,
  });

  factory CardDto.fromJson(Map<String, dynamic> json) {
    return CardDto(
      id: json['id'] as String,
      locationId: json['locationId'] as String,
      value: json['value'] as String,
      label: json['label'] as String,
      type: json['type'] as String? ?? 'voucher',
      ownerId: json['ownerId'] as String,
      validFrom: json['validFrom'] as String?,
      validUntil: json['validUntil'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
      usedAt: json['usedAt'] as String?,
      used: json['used'] as bool,
      invalidated: json['invalidated'] as bool,
    );
  }

  factory CardDto.fromMap(Map<String, dynamic> map) {
    final metaRaw = map['metadata'] as String?;
    return CardDto(
      id: map['id'] as String,
      locationId: map['locationId'] as String,
      value: map['value'] as String,
      label: map['label'] as String,
      type: map['type'] as String,
      ownerId: map['ownerId'] as String,
      validFrom: map['validFrom'] as String?,
      validUntil: map['validUntil'] as String?,
      metadata: metaRaw != null ? jsonDecode(metaRaw) as Map<String, dynamic> : null,
      createdAt: map['createdAt'] as String,
      updatedAt: map['updatedAt'] as String,
      usedAt: map['usedAt'] as String?,
      used: (map['used'] as int) == 1,
      invalidated: (map['invalidated'] as int) == 1,
    );
  }

  factory CardDto.fromDomain(Card card) {
    return CardDto(
      id: card.id,
      locationId: card.locationId,
      value: card.value,
      label: card.label,
      type: card.type.name,
      ownerId: card.ownerId,
      validFrom: card.validFrom?.toIso8601String(),
      validUntil: card.validUntil?.toIso8601String(),
      metadata: card.metadata,
      createdAt: card.createdAt.toIso8601String(),
      updatedAt: card.updatedAt.toIso8601String(),
      usedAt: card.usedAt?.toIso8601String(),
      used: card.used,
      invalidated: card.invalidated,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'locationId': locationId,
      'value': value,
      'label': label,
      'type': type,
      'ownerId': ownerId,
      'validFrom': validFrom,
      'validUntil': validUntil,
      'metadata': metadata != null ? jsonEncode(metadata) : null,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'usedAt': usedAt,
      'used': used ? 1 : 0,
      'invalidated': invalidated ? 1 : 0,
    };
  }

  Card toDomain() {
    return Card(
      id: id,
      locationId: locationId,
      value: value,
      label: label,
      type: CardType.values.firstWhere(
        (e) => e.name == type,
        orElse: () => CardType.voucher,
      ),
      ownerId: ownerId,
      validFrom: validFrom != null ? DateTime.parse(validFrom!) : null,
      validUntil: validUntil != null ? DateTime.parse(validUntil!) : null,
      metadata: metadata,
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
      usedAt: usedAt != null ? DateTime.parse(usedAt!) : null,
      used: used,
      invalidated: invalidated,
    );
  }
}