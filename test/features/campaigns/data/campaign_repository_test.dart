import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:racs_reader/core/network/http_client.dart';
import 'package:racs_reader/features/campaigns/data/campaign_repository_impl.dart';
import 'package:racs_reader/features/campaigns/domain/campaign_params.dart';

import 'campaign_repository_test.mocks.dart';

/// The repository reads the status and the body off a response, so the fake
/// covers those and lets [noSuchMethod] absorb the rest of the interface.
class FakeHttpClientResponse extends Stream<List<int>>
    implements io.HttpClientResponse {
  final String body;

  @override
  final int statusCode;

  FakeHttpClientResponse(this.body, {this.statusCode = 200});

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
  late CampaignRepositoryImpl repository;

  Map<String, dynamic> campaignJson({
    String id = 'campaign-1',
    String? validFrom = '2026-01-01T00:00:00.000Z',
    String? validUntil = '2026-12-31T00:00:00.000Z',
  }) => {
    'id': id,
    'name': 'campaign one',
    'validFrom': ?validFrom,
    'validUntil': ?validUntil,
    'createdAt': '2026-01-01T00:00:00.000Z',
    'updatedAt': '2026-01-02T00:00:00.000Z',
  };

  void stubGet(Map<String, dynamic> body, {int statusCode = 200}) {
    when(
      httpClient.get(any, queryParameters: anyNamed('queryParameters')),
    ).thenAnswer(
      (_) async =>
          FakeHttpClientResponse(jsonEncode(body), statusCode: statusCode),
    );
  }

  /// The query map the repository handed to the client on its single call.
  Object? capturedQueryParameters() => verify(
    httpClient.get(any, queryParameters: captureAnyNamed('queryParameters')),
  ).captured.single;

  setUp(() {
    httpClient = MockHttpClient();
    repository = CampaignRepositoryImpl(httpClient);
  });

  group('getCampaigns', () {
    test('requests the campaigns and maps them', () async {
      stubGet({
        'campaigns': [campaignJson(), campaignJson(id: 'campaign-2')],
      });

      final campaigns = await repository.getCampaigns(CampaignParams());

      final captured = verify(
        httpClient.get(
          captureAny,
          queryParameters: captureAnyNamed('queryParameters'),
        ),
      ).captured;

      expect(captured.first, '/api/campaign');
      expect(campaigns.map((c) => c.id), ['campaign-1', 'campaign-2']);

      final campaign = campaigns.first;
      expect(campaign.name, 'campaign one');
      expect(campaign.validFrom, DateTime.utc(2026));
      expect(campaign.validUntil, DateTime.utc(2026, 12, 31));
      expect(campaign.createdAt, DateTime.utc(2026));
      expect(campaign.updatedAt, DateTime.utc(2026, 1, 2));
    });

    test('stringifies the paging params', () async {
      stubGet({'campaigns': []});

      await repository.getCampaigns(CampaignParams(page: 2, size: 50));

      expect(capturedQueryParameters(), {'size': '50', 'page': '2'});
    });

    test('sends only the size when the page is not set', () async {
      stubGet({'campaigns': []});

      await repository.getCampaigns(CampaignParams(size: 50));

      expect(capturedQueryParameters(), {'size': '50'});
    });

    test('sends only the page when the size is not set', () async {
      stubGet({'campaigns': []});

      await repository.getCampaigns(CampaignParams(page: 2));

      expect(capturedQueryParameters(), {'page': '2'});
    });

    test('sends a zero page rather than dropping it', () async {
      stubGet({'campaigns': []});

      await repository.getCampaigns(CampaignParams(page: 0, size: 0));

      expect(capturedQueryParameters(), {'size': '0', 'page': '0'});
    });

    test('sends no paging params when none are set', () async {
      stubGet({'campaigns': []});

      await repository.getCampaigns(CampaignParams());

      expect(capturedQueryParameters(), isEmpty);
    });

    test('leaves the validity window null when the response omits it', () async {
      stubGet({
        'campaigns': [campaignJson(validFrom: null, validUntil: null)],
      });

      final campaign = (await repository.getCampaigns(
        CampaignParams(),
      )).single;

      expect(campaign.validFrom, isNull);
      expect(campaign.validUntil, isNull);
    });

    test('returns an empty list when there are no campaigns', () async {
      stubGet({'campaigns': []});

      expect(await repository.getCampaigns(CampaignParams()), isEmpty);
    });

    test('throws when the server does not return 200', () async {
      stubGet({'campaigns': []}, statusCode: 500);

      expect(
        () => repository.getCampaigns(CampaignParams()),
        throwsA(
          isA<io.HttpException>().having(
            (e) => e.message,
            'message',
            'GET /api/campaign failed with 500',
          ),
        ),
      );
    });
  });

  group('countCampaigns', () {
    test('requests the count endpoint and returns the count', () async {
      stubGet({'count': 7});

      final count = await repository.countCampaigns();

      verify(
        httpClient.get(
          '/api/campaign/count',
          queryParameters: anyNamed('queryParameters'),
        ),
      ).called(1);
      expect(count, 7);
    });

    test('sends no query parameters', () async {
      stubGet({'count': 0});

      await repository.countCampaigns();

      expect(capturedQueryParameters(), isNull);
    });

    test('returns zero when the server counts none', () async {
      stubGet({'count': 0});

      expect(await repository.countCampaigns(), 0);
    });
  });
}
