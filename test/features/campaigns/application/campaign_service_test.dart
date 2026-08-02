import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:racs_reader/features/campaigns/application/campaign_service.dart';
import 'package:racs_reader/features/campaigns/domain/campaign.dart';
import 'package:racs_reader/features/campaigns/domain/campaign_params.dart';
import 'package:racs_reader/features/campaigns/domain/campaign_repository.dart';
import 'package:racs_reader/features/logger/application/logger_service.dart';

import 'campaign_service_test.mocks.dart';

@GenerateMocks([CampaignRepository, LoggerService])
void main() {
  late MockCampaignRepository repository;
  late MockLoggerService logger;
  late CampaignService service;

  final campaign = Campaign(
    id: 'card-1',
    name: 'ABC123',
    validFrom: DateTime.utc(2026),
    validUntil: DateTime.utc(2026),
    createdAt: DateTime.utc(2026),
    updatedAt: DateTime.utc(2026),
  );

  setUp(() {
    repository = MockCampaignRepository();
    logger = MockLoggerService();
    service = CampaignService(repository, logger);

    when(
      logger.debug(any, className: anyNamed('className')),
    ).thenAnswer((_) async {});

    when(
      logger.info(any, className: anyNamed('className')),
    ).thenAnswer((_) async {});

    when(
      logger.error(any, className: anyNamed('className')),
    ).thenAnswer((_) async {});
  });

  group('getCampaigns', () {
    test('gets from the repository', () async {
      final campaigns = [campaign];

      when(repository.getCampaigns(any)).thenAnswer((_) async => campaigns);

      final result = await service.getCampaigns(
        CampaignParams(page: 0, size: 5),
      );
      final params =
          verify(repository.getCampaigns(captureAny)).captured.single
              as CampaignParams;

      expect(params.page, 0);
      expect(params.size, 5);
      expect(result, contains(campaign));
    });

    test('logs before reading from the repository', () async {
      when(repository.getCampaigns(any)).thenAnswer((_) async => [campaign]);

      await service.getCampaigns(CampaignParams(page: 0, size: 5));

      verify(
        logger.debug('Loading campaigns', className: 'CampaignService'),
      ).called(1);
    });

    test(
      'returns an empty list when the repository has no campaigns',
      () async {
        when(repository.getCampaigns(any)).thenAnswer((_) async => []);

        final result = await service.getCampaigns(
          CampaignParams(page: 0, size: 5),
        );

        expect(result, isEmpty);
      },
    );

    test('passes paging params through unchanged', () async {
      when(repository.getCampaigns(any)).thenAnswer((_) async => []);

      await service.getCampaigns(CampaignParams(page: 3, size: 25));

      final params =
          verify(repository.getCampaigns(captureAny)).captured.single
              as CampaignParams;

      expect(params.page, 3);
      expect(params.size, 25);
    });

    test('propagates repository failures', () async {
      when(
        repository.getCampaigns(any),
      ).thenThrow(StateError('network unavailable'));

      await expectLater(
        () => service.getCampaigns(CampaignParams(page: 0, size: 5)),
        throwsStateError,
      );
    });
  });

  group('countCampaigns', () {
    test('returns the count from the repository', () async {
      when(repository.countCampaigns()).thenAnswer((_) async => 7);

      final result = await service.countCampaigns();

      expect(result, 7);
      verify(repository.countCampaigns()).called(1);
    });

    test('returns zero when the repository has no campaigns', () async {
      when(repository.countCampaigns()).thenAnswer((_) async => 0);

      expect(await service.countCampaigns(), 0);
    });

    test('propagates repository failures', () async {
      when(
        repository.countCampaigns(),
      ).thenThrow(StateError('network unavailable'));

      await expectLater(service.countCampaigns, throwsStateError);
    });
  });
}
