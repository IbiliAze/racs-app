import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:racs_reader/features/logger/application/logger_service.dart';
import 'package:racs_reader/features/settings/application/settings_service.dart';
import 'package:racs_reader/features/settings/domain/settings_repository.dart';

import 'settings_service_test.mocks.dart';

@GenerateMocks([SettingsRepository, LoggerService])
void main() {
  late MockSettingsRepository repository;
  late SettingsService service;

  setUp(() {
    repository = MockSettingsRepository();
    service = SettingsService(repository);
  });

  group('saveHost', () {
    test('saves host', () async {
      final hostname = "host-1";

      when(repository.saveHost(any)).thenAnswer((_) async {});

      await service.saveHost(hostname);
      final passedHostname =
          verify(repository.saveHost(captureAny)).captured.single as String;

      expect(passedHostname, equals(hostname));
    });
  });
}
