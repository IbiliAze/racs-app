import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:racs_reader/features/cards/application/card_service.dart';
import 'package:racs_reader/features/cards/domain/card.dart';
import 'package:racs_reader/features/cards/domain/card_local_repository.dart';
import 'package:racs_reader/features/cards/domain/card_params.dart';
import 'package:racs_reader/features/cards/domain/card_repository.dart';
import 'package:racs_reader/features/logger/application/logger_service.dart';

import 'card_service_test.mocks.dart';

@GenerateMocks([CardRepository, CardLocalRepository, LoggerService])
void main() {
  late MockCardRepository remote;
  late MockCardLocalRepository local;
  late MockLoggerService logger;
  late CardService service;

  final card = Card(
    id: 'card-1',
    value: 'ABC123',
    label: 'VIP',
    type: CardType.pass,
    campaignId: 'campaign-1',
    createdAt: DateTime.utc(2026),
    updatedAt: DateTime.utc(2026),
    used: false,
    invalidated: false,
  );

  setUp(() {
    remote = MockCardRepository();
    local = MockCardLocalRepository();
    logger = MockLoggerService();
    service = CardService(remote, local, logger);

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

  test('getCardById reads from the local repository', () async {
    when(local.getCardById('card-1')).thenAnswer((_) async => card);

    final result = await service.getCardById('card-1');

    expect(result, same(card));
    verify(local.getCardById('card-1')).called(1);
    verifyNever(remote.getCardById(any));
  });

  group('downloadCards', () {
    test('downloads the campaign and persists returned cards', () async {
      final cards = [card];

      when(remote.getCards(any)).thenAnswer((_) async => cards);
      when(local.upsertAll(cards)).thenAnswer((_) async {});

      await service.downloadCards('campaign-1');

      final params =
          verify(remote.getCards(captureAny)).captured.single as CardParams;

      expect(params.campaignId, 'campaign-1');
      verify(local.upsertAll(cards)).called(1);
      verify(
        logger.info('Synced from remote', className: 'CardSyncService'),
      ).called(1);
    });

    test('does not write locally when the download fails', () async {
      when(remote.getCards(any)).thenThrow(StateError('network unavailable'));

      await service.downloadCards('campaign-1');

      verifyNever(local.upsertAll(any));
      verify(
        logger.error(
          'Bad state: network unavailable',
          className: 'CardSyncService',
        ),
      ).called(1);
      verifyNever(logger.info(any, className: anyNamed('className')));
    });

    test('does not report success when local persistence fails', () async {
      final cards = [card];

      when(remote.getCards(any)).thenAnswer((_) async => cards);
      when(local.upsertAll(cards)).thenThrow(StateError('database full'));

      await service.downloadCards('campaign-1');

      verifyNever(logger.info(any, className: anyNamed('className')));
      verify(
        logger.error('Bad state: database full', className: 'CardSyncService'),
      ).called(1);
    });
  });
}
