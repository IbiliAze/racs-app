import 'package:injectable/injectable.dart';
import 'package:racs_reader/features/campaigns/domain/campaign.dart';
import 'package:racs_reader/features/campaigns/domain/campaign_params.dart';
import 'package:racs_reader/features/campaigns/domain/campaign_repository.dart';
import 'package:racs_reader/features/logger/application/logger_service.dart';

@lazySingleton
class CampaignService {
  final CampaignRepository _campaignRepository;
  final LoggerService _loggerService;

  CampaignService(this._campaignRepository, this._loggerService);

  Future<List<Campaign>> getCampaigns(CampaignParams params) async {
    await _loggerService.debug(
      'Loading campaigns',
      className: 'CampaignService',
    );
    return _campaignRepository.getCampaigns(params);
  }

  Future<int> countCampaigns() => _campaignRepository.countCampaigns();
}
