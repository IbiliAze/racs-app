abstract class SettingsRepository {
  Future<void> saveHost(String host);
  Future<String?> getHost();
  Future<void> saveCampaignId(String campaignId);
  Future<String?> getCampaignId();
  Future<bool> testHttp();
  Future<bool> testWebSocket();
  Future<bool> testStun();
}
