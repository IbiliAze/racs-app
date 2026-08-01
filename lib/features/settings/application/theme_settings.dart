import 'package:flutter/material.dart';
import 'package:racs_reader/core/storage/settings_storage.dart';

class ThemeSettings extends ChangeNotifier {
  // Dependencies
  final SettingsStorage settingsStorage;

  // State. Defaults to dark so the first frame (before storage loads) and the
  // very first launch both show dark mode.
  ThemeMode _themeMode = ThemeMode.dark;
  bool _loaded = false;

  // Constructor
  ThemeSettings({required this.settingsStorage}) {
    _load();
  }

  // Getters
  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  bool get loaded => _loaded;

  // Public methods
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();

    await settingsStorage.saveThemeMode(mode.name);
  }

  Future<void> toggleDarkMode(bool enabled) async {
    final mode = enabled ? ThemeMode.dark : ThemeMode.light;
    await setThemeMode(mode);
  }

  // Private methods
  Future<void> _load() async {
    final savedThemeMode = await settingsStorage.getThemeMode();

    switch (savedThemeMode) {
      case 'light':
        _themeMode = ThemeMode.light;
        break;
      case 'system':
        _themeMode = ThemeMode.system;
        break;
      case 'dark':
      default:
        // 'dark' or nothing saved yet (first launch) -> dark mode on.
        _themeMode = ThemeMode.dark;
        break;
    }

    _loaded = true;
    notifyListeners();
  }
}
