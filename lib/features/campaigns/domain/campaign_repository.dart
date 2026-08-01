import 'package:racs_reader/features/campaigns/domain/campaign.dart';
import 'package:racs_reader/features/campaigns/domain/campaign_params.dart';

abstract class CampaignRepository {
  Future<List<Campaign>> getCampaigns(CampaignParams params);
  Future<int> countCampaigns();
}
