import 'dart:convert';
import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:racs_reader/core/network/http_client.dart';
import 'package:racs_reader/features/campaigns/data/campaign_dto.dart';
import 'package:racs_reader/features/campaigns/domain/campaign.dart';
import 'package:racs_reader/features/campaigns/domain/campaign_params.dart';
import 'package:racs_reader/features/campaigns/domain/campaign_repository.dart';

@Injectable(as: CampaignRepository)
class CampaignRepositoryImpl implements CampaignRepository {
  final HttpClient _httpClient;

  CampaignRepositoryImpl(this._httpClient);

  @override
  Future<List<Campaign>> getCampaigns(CampaignParams params) async {
    // Uri.http(s) only accepts String query values, so stringify the ints.
    final response = await _httpClient.get(
      '/api/campaign',
      queryParameters: {
        if (params.size != null) 'size': '${params.size}',
        if (params.page != null) 'page': '${params.page}',
      },
    );
    if (response.statusCode != 200) {
      throw HttpException(
        'GET /api/campaign failed with ${response.statusCode}',
      );
    }
    final json = await _parseBody(response);
    final campaigns = json['campaigns'] as List<dynamic>;
    return campaigns
        .map((e) => CampaignDto.fromJson(e as Map<String, dynamic>).toDomain())
        .toList();
  }

  @override
  Future<int> countCampaigns() async {
    final response = await _httpClient.get('/api/campaign/count');
    final json = await _parseBody(response);
    final count = json['count'] as int;
    return count;
  }

  Future<Map<String, dynamic>> _parseBody(HttpClientResponse response) async {
    final raw = await response.transform(utf8.decoder).join();
    return jsonDecode(raw) as Map<String, dynamic>;
  }
}
