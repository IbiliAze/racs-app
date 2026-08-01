import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@lazySingleton
class SettingsStorage {
  // State
  static const String _themeModeKey = 'theme_mode';
  static const String _hostKey = 'host';
  static const String _campaignId = 'campaign_id';

  // Public methods
  Future<void> saveThemeMode(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, value);
  }

  Future<String?> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_themeModeKey);
  }

  Future<void> saveHost(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_hostKey, value);
  }

  Future<String?> getHost() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_hostKey);
  }

  Future<void> saveCampaignId(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_campaignId, value);
  }

  Future<String?> getCampaignId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_campaignId);
  }
}
