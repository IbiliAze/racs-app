import 'package:flutter/material.dart';
import 'package:reader/core/storage/settings_storage.dart';

class ThemeSettings extends ChangeNotifier {
  // Dependencies
  final SettingsStorage settingsStorage;

  // State
  ThemeMode _themeMode = ThemeMode.system;
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
      case 'dark':
        _themeMode = ThemeMode.dark;
        break;
      case 'light':
        _themeMode = ThemeMode.light;
        break;
      case 'system':
      default:
        _themeMode = ThemeMode.system;
        break;
    }

    _loaded = true;
    notifyListeners();
  }
}
