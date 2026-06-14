import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@lazySingleton
class SettingsStorage {
  // State
  static const String _themeModeKey = 'theme_mode';
  static const String _hostKey = 'host';

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
}