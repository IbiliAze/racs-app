import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:racs_reader/core/network/http_client.dart';
import 'package:racs_reader/features/cards/data/card_repository_impl.dart';
import 'package:racs_reader/features/cards/domain/card.dart';
import 'package:racs_reader/features/cards/domain/card_params.dart';

import 'card_repository_test.mocks.dart';

/// The repository only ever reads the body off a response, so the fake covers
/// [Stream.listen] and lets [noSuchMethod] absorb the rest of the interface.
class FakeHttpClientResponse extends Stream<List<int>>
    implements io.HttpClientResponse {
  final String body;

  FakeHttpClientResponse(this.body);

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) => Stream<List<int>>.value(utf8.encode(body)).listen(
    onData,
    onError: onError,
    onDone: onDone,
    cancelOnError: cancelOnError,
  );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

@GenerateMocks([HttpClient])
void main() {
  late MockHttpClient httpClient;
  late CardRepositoryImpl repository;

  Map<String, dynamic> cardJson({
    String id = 'card-1',
    String? type = 'pass',
    bool used = false,
    String? usedAt,
  }) => {
    'id': id,
    'value': 'ABC123',
    'label': 'VIP',
    'type': ?type,
    'campaignId': 'campaign-1',
    'validFrom': '2026-01-01T00:00:00.000Z',
    'validUntil': '2026-12-31T00:00:00.000Z',
    'metadata': {'seat': '12A'},
    'createdAt': '2026-01-01T00:00:00.000Z',
    'updatedAt': '2026-01-02T00:00:00.000Z',
    'usedAt': usedAt,
    'used': used,
    'invalidated': false,
  };

  FakeHttpClientResponse response(Map<String, dynamic> body) =>
      FakeHttpClientResponse(jsonEncode(body));

  void stubGet(Map<String, dynamic> body) {
    when(
      httpClient.get(any, queryParameters: anyNamed('queryParameters')),
    ).thenAnswer((_) async => response(body));
  }

  void stubPut(Map<String, dynamic> body) {
    when(
      httpClient.put(any, body: anyNamed('body')),
    ).thenAnswer((_) async => response(body));
  }

  setUp(() {
    httpClient = MockHttpClient();
    repository = CardRepositoryImpl(httpClient);
  });

  group('getCardById', () {
    test('requests the card by id and maps it to the domain', () async {
      stubGet({'card': cardJson()});

      final card = await repository.getCardById('card-1');

      verify(
        httpClient.get(
          '/api/card/card-1',
          queryParameters: anyNamed('queryParameters'),
        ),
      ).called(1);

      expect(card, isNotNull);
      expect(card!.id, 'card-1');
      expect(card.value, 'ABC123');
      expect(card.label, 'VIP');
      expect(card.type, CardType.pass);
      expect(card.campaignId, 'campaign-1');
      expect(card.validFrom, DateTime.utc(2026));
      expect(card.validUntil, DateTime.utc(2026, 12, 31));
      expect(card.metadata, {'seat': '12A'});
      expect(card.createdAt, DateTime.utc(2026));
      expect(card.updatedAt, DateTime.utc(2026, 1, 2));
      expect(card.usedAt, isNull);
      expect(card.used, isFalse);
      expect(card.invalidated, isFalse);
    });

    test('returns null when the response has no card', () async {
      stubGet({'card': null});

      expect(await repository.getCardById('card-1'), isNull);
    });

    test('defaults to a voucher when the type is missing', () async {
      stubGet({
        'card': cardJson(type: null),
      });

      final card = await repository.getCardById('card-1');

      expect(card!.type, CardType.voucher);
    });

    test('falls back to a voucher for an unknown type', () async {
      stubGet({
        'card': cardJson(type: 'wristband'),
      });

      final card = await repository.getCardById('card-1');

      expect(card!.type, CardType.voucher);
    });
  });

  group('getCardByLabel', () {
    test('requests the card by label', () async {
      stubGet({'card': cardJson()});

      final card = await repository.getCardByLabel('VIP');

      verify(
        httpClient.get(
          '/api/card/label/VIP',
          queryParameters: anyNamed('queryParameters'),
        ),
      ).called(1);
      expect(card!.label, 'VIP');
    });

    test('returns null when the response has no card', () async {
      stubGet({'card': null});

      expect(await repository.getCardByLabel('VIP'), isNull);
    });
  });

  group('getCardByValue', () {
    test('requests the card by value', () async {
      stubGet({'card': cardJson()});

      final card = await repository.getCardByValue('ABC123');

      verify(
        httpClient.get(
          '/api/card/value/ABC123',
          queryParameters: anyNamed('queryParameters'),
        ),
      ).called(1);
      expect(card!.value, 'ABC123');
    });

    test('returns null when the response has no card', () async {
      stubGet({'card': null});

      expect(await repository.getCardByValue('ABC123'), isNull);
    });
  });

  group('getCards', () {
    test('requests the campaign cards and maps them', () async {
      stubGet({
        'cards': [cardJson(), cardJson(id: 'card-2')],
      });

      final cards = await repository.getCards(
        CardParams(campaignId: 'campaign-1'),
      );

      final captured = verify(
        httpClient.get(
          captureAny,
          queryParameters: captureAnyNamed('queryParameters'),
        ),
      ).captured;

      expect(captured.first, '/api/card');
      expect(captured.last, {'size': '10000', 'campaignId': 'campaign-1'});
      expect(cards.map((c) => c.id), ['card-1', 'card-2']);
    });

    test('omits the campaign filter when the campaign id is empty', () async {
      stubGet({'cards': []});

      await repository.getCards(CardParams(campaignId: ''));

      final queryParameters = verify(
        httpClient.get(
          any,
          queryParameters: captureAnyNamed('queryParameters'),
        ),
      ).captured.single;

      expect(queryParameters, {'size': '10000'});
    });

    test('returns an empty list when the campaign has no cards', () async {
      stubGet({'cards': []});

      expect(
        await repository.getCards(CardParams(campaignId: 'campaign-1')),
        isEmpty,
      );
    });
  });

  group('markUsed', () {
    test('puts to the use endpoint and maps the returned card', () async {
      stubPut({
        'card': cardJson(used: true, usedAt: '2026-02-01T00:00:00.000Z'),
      });

      final card = await repository.markUsed('card-1');

      verify(
        httpClient.put('/api/card/card-1/use', body: anyNamed('body')),
      ).called(1);
      expect(card!.used, isTrue);
      expect(card.usedAt, DateTime.utc(2026, 2));
    });

    test('returns null when the response has no card', () async {
      stubPut({'card': null});

      expect(await repository.markUsed('card-1'), isNull);
    });
  });
}