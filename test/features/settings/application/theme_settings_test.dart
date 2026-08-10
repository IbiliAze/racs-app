import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:racs_reader/core/storage/settings_storage.dart';
import 'package:racs_reader/features/settings/application/theme_settings.dart';

import 'theme_settings_test.mocks.dart';

@GenerateMocks([SettingsStorage])
void main() {
  late MockSettingsStorage storage;

  setUp(() {
    storage = MockSettingsStorage();
  });

  Future<ThemeSettings> buildSettings({String? savedThemeMode}) async {
    when(storage.getThemeMode()).thenAnswer((_) async => savedThemeMode);
    when(storage.saveThemeMode(any)).thenAnswer((_) async {});

    final settings = ThemeSettings(settingsStorage: storage);
    await pumpEventQueue();

    return settings;
  }

  group('initial state', () {
    test('defaults to dark mode before storage loads', () {
      when(storage.getThemeMode()).thenAnswer((_) async => 'light');

      final settings = ThemeSettings(settingsStorage: storage);

      expect(settings.themeMode, equals(ThemeMode.dark));
      expect(settings.isDarkMode, isTrue);
    });

    test('is not loaded before storage returns', () {
      when(storage.getThemeMode()).thenAnswer((_) async => 'dark');

      final settings = ThemeSettings(settingsStorage: storage);

      expect(settings.loaded, isFalse);
    });
  });

  group('load', () {
    test('loads the light theme mode from storage', () async {
      final settings = await buildSettings(savedThemeMode: 'light');

      expect(settings.themeMode, equals(ThemeMode.light));
      expect(settings.isDarkMode, isFalse);
    });

    test('loads the system theme mode from storage', () async {
      final settings = await buildSettings(savedThemeMode: 'system');

      expect(settings.themeMode, equals(ThemeMode.system));
      expect(settings.isDarkMode, isFalse);
    });

    test('loads the dark theme mode from storage', () async {
      final settings = await buildSettings(savedThemeMode: 'dark');

      expect(settings.themeMode, equals(ThemeMode.dark));
      expect(settings.isDarkMode, isTrue);
    });

    test('falls back to dark mode when nothing is saved', () async {
      final settings = await buildSettings(savedThemeMode: null);

      expect(settings.themeMode, equals(ThemeMode.dark));
      expect(settings.isDarkMode, isTrue);
    });

    test('falls back to dark mode when the saved value is unknown', () async {
      final settings = await buildSettings(savedThemeMode: 'sepia');

      expect(settings.themeMode, equals(ThemeMode.dark));
      expect(settings.isDarkMode, isTrue);
    });

    test('is loaded once storage returns', () async {
      final settings = await buildSettings(savedThemeMode: 'light');

      expect(settings.loaded, isTrue);
    });
  });

  group('setThemeMode', () {});

  group('toggleDarkMode', () {});
}