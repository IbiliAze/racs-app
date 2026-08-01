import 'package:racs_reader/features/campaigns/domain/campaign.dart';

class CampaignDto {
  final String id;
  final String name;
  final String? validFrom;
  final String? validUntil;
  final String createdAt;
  final String updatedAt;

  const CampaignDto({
    required this.id,
    required this.name,
    this.validFrom,
    this.validUntil,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CampaignDto.fromJson(Map<String, dynamic> json) {
    return CampaignDto(
      id: json['id'] as String,
      name: json['name'] as String,
      validFrom: json['validFrom'] as String?,
      validUntil: json['validUntil'] as String?,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );
  }

  factory CampaignDto.fromMap(Map<String, dynamic> map) {
    return CampaignDto(
      id: map['id'] as String,
      name: map['name'] as String,
      validFrom: map['validFrom'] as String?,
      validUntil: map['validUntil'] as String?,
      createdAt: map['createdAt'] as String,
      updatedAt: map['updatedAt'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'validFrom': validFrom,
      'validUntil': validUntil,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  Campaign toDomain() {
    return Campaign(
      id: id,
      name: name,
      validFrom: validFrom != null ? DateTime.parse(validFrom!) : null,
      validUntil: validUntil != null ? DateTime.parse(validUntil!) : null,
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
    );
  }
}
