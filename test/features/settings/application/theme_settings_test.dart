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

  // ThemeSettings loads from storage in its constructor, so stub getThemeMode
  // before building it and await the pending load.
  Future<ThemeSettings> buildSettings({String? savedThemeMode}) async {
    when(storage.getThemeMode()).thenAnswer((_) async => savedThemeMode);
    when(storage.saveThemeMode(any)).thenAnswer((_) async {});

    final settings = ThemeSettings(settingsStorage: storage);
    await pumpEventQueue();

    return settings;
  }

  group('initial state', () {});

  group('load', () {});

  group('setThemeMode', () {});

  group('toggleDarkMode', () {});
}