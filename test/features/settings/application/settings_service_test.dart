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

  group('getHost', () {
    test('gets host', () async {
      final hostname = "host-1";

      when(repository.getHost()).thenAnswer((_) async => hostname);

      final returnedHostname = await service.getHost();

      expect(returnedHostname, equals(hostname));
    });

    test('returns null when no host is saved', () async {
      when(repository.getHost()).thenAnswer((_) async => null);

      final returnedHostname = await service.getHost();

      expect(returnedHostname, isNull);
    });
  });

  group('saveCampaignId', () {
    test('saves campaign id', () async {
      final campaignId = "campaign-1";

      when(repository.saveCampaignId(any)).thenAnswer((_) async {});

      await service.saveCampaignId(campaignId);
      final passedCampaignId =
          verify(repository.saveCampaignId(captureAny)).captured.single
              as String;

      expect(passedCampaignId, equals(campaignId));
    });
  });

  group('getCampaignId', () {
    test('gets campaign id', () async {
      final campaignId = "campaign-1";

      when(repository.getCampaignId()).thenAnswer((_) async => campaignId);

      final returnedCampaignId = await service.getCampaignId();

      expect(returnedCampaignId, equals(campaignId));
    });

    test('returns null when no campaign id is saved', () async {
      when(repository.getCampaignId()).thenAnswer((_) async => null);

      final returnedCampaignId = await service.getCampaignId();

      expect(returnedCampaignId, isNull);
    });
  });

  group('testHttp', () {
    test('returns true when the repository succeeds', () async {
      when(repository.testHttp()).thenAnswer((_) async => true);

      expect(await service.testHttp(), isTrue);
    });

    test('returns false when the repository fails', () async {
      when(repository.testHttp()).thenAnswer((_) async => false);

      expect(await service.testHttp(), isFalse);
    });
  });

  group('testWebSocket', () {
    test('returns true when the repository succeeds', () async {
      when(repository.testWebSocket()).thenAnswer((_) async => true);

      expect(await service.testWebSocket(), isTrue);
    });

    test('returns false when the repository fails', () async {
      when(repository.testWebSocket()).thenAnswer((_) async => false);

      expect(await service.testWebSocket(), isFalse);
    });
  });

  group('testStun', () {
    test('returns true when the repository succeeds', () async {
      when(repository.testStun()).thenAnswer((_) async => true);

      expect(await service.testStun(), isTrue);
    });

    test('returns false when the repository fails', () async {
      when(repository.testStun()).thenAnswer((_) async => false);

      expect(await service.testStun(), isFalse);
    });
  });
}
