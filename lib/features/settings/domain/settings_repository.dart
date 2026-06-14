abstract class SettingsRepository {
  Future<void> saveHost(String host);
  Future<String?> getHost();
  Future<bool> testHttp();
  Future<bool> testWebSocket();
  Future<bool> testStun();
}