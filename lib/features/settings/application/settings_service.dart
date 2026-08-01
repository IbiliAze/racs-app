import 'package:injectable/injectable.dart';
import 'package:racs_reader/features/settings/domain/settings_repository.dart';

@lazySingleton
class SettingsService {
  final SettingsRepository _settingsRepository;

  SettingsService(this._settingsRepository);

  Future<void> saveHost(String host) => _settingsRepository.saveHost(host);
  Future<String?> getHost() => _settingsRepository.getHost();
  Future<void> saveCampaignId(String campaignId) =>
      _settingsRepository.saveCampaignId(campaignId);
  Future<String?> getCampaignId() => _settingsRepository.getCampaignId();
  Future<bool> testHttp() => _settingsRepository.testHttp();
  Future<bool> testWebSocket() => _settingsRepository.testWebSocket();
  Future<bool> testStun() => _settingsRepository.testStun();
}
