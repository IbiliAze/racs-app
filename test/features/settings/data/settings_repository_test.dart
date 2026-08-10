import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:racs_reader/core/network/http_client.dart';
import 'package:racs_reader/core/network/websocket_client.dart';
import 'package:racs_reader/core/network/webrtc_client.dart';
import 'package:racs_reader/core/storage/settings_storage.dart';
import 'package:racs_reader/features/settings/data/settings_repository_impl.dart';

import 'settings_repository_test.mocks.dart';

/// The repository only reads the status off a health response, so the fake
/// covers that and lets [noSuchMethod] absorb the rest of the interface.
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

@GenerateMocks([SettingsStorage, HttpClient, WebSocketClient, WebRtcClient])
void main() {
  late MockSettingsStorage settingsStorage;
  late MockHttpClient httpClient;
  late MockWebSocketClient webSocketClient;
  late MockWebRtcClient webRtcClient;
  late SettingsRepositoryImpl repository;

  void stubGet({int statusCode = 200}) {
    when(
      httpClient.get(any, queryParameters: anyNamed('queryParameters')),
    ).thenAnswer(
      (_) async => FakeHttpClientResponse('{}', statusCode: statusCode),
    );
  }

  setUp(() {
    settingsStorage = MockSettingsStorage();
    httpClient = MockHttpClient();
    webSocketClient = MockWebSocketClient();
    webRtcClient = MockWebRtcClient();
    repository = SettingsRepositoryImpl(
      settingsStorage,
      httpClient,
      webSocketClient,
      webRtcClient,
    );
  });

  group('saveHost', () {
    test('saves the host and resets the clients', () async {
      await repository.saveHost('host-1');
      final savedHost =
          verify(settingsStorage.saveHost(captureAny)).captured.single
              as String;

      expect(savedHost, equals('host-1'));
      verify(httpClient.resetHost()).called(1);
      verify(webSocketClient.resetHost()).called(1);
    });
  });

  group('getHost', () {
    test('gets the host from storage', () async {
      when(settingsStorage.getHost()).thenAnswer((_) async => 'host-1');

      expect(await repository.getHost(), equals('host-1'));
    });

    test('returns null when no host is saved', () async {
      when(settingsStorage.getHost()).thenAnswer((_) async => null);

      expect(await repository.getHost(), isNull);
    });
  });

  group('saveCampaignId', () {
    test('saves the campaign id to storage', () async {
      await repository.saveCampaignId('campaign-1');
      final savedCampaignId =
          verify(settingsStorage.saveCampaignId(captureAny)).captured.single
              as String;

      expect(savedCampaignId, equals('campaign-1'));
    });
  });

  group('getCampaignId', () {
    test('gets the campaign id from storage', () async {
      when(
        settingsStorage.getCampaignId(),
      ).thenAnswer((_) async => 'campaign-1');

      expect(await repository.getCampaignId(), equals('campaign-1'));
    });

    test('returns null when no campaign id is saved', () async {
      when(settingsStorage.getCampaignId()).thenAnswer((_) async => null);

      expect(await repository.getCampaignId(), isNull);
    });
  });

  group('testHttp', () {
    test('returns true when the health endpoint returns 200', () async {
      stubGet();

      expect(await repository.testHttp(), isTrue);
      final path =
          verify(
                httpClient.get(
                  captureAny,
                  queryParameters: anyNamed('queryParameters'),
                ),
              ).captured.single
              as String;

      expect(path, equals('/api/health'));
    });

    test('returns false when the health endpoint fails', () async {
      stubGet(statusCode: 500);

      expect(await repository.testHttp(), isFalse);
    });

    test('returns false when the request throws', () async {
      when(
        httpClient.get(any, queryParameters: anyNamed('queryParameters')),
      ).thenThrow(const io.SocketException('no route to host'));

      expect(await repository.testHttp(), isFalse);
    });
  });

  group('testWebSocket', () {
    test('returns true when the health socket connects', () async {
      when(webSocketClient.connect(any)).thenAnswer((_) async {});
      when(webSocketClient.disconnect()).thenAnswer((_) async {});

      expect(await repository.testWebSocket(), isTrue);
      final path =
          verify(webSocketClient.connect(captureAny)).captured.single as String;

      expect(path, equals('/ws/health'));
      verify(webSocketClient.disconnect()).called(1);
    });

    test('returns false when the connection throws', () async {
      when(
        webSocketClient.connect(any),
      ).thenThrow(const io.SocketException('connection refused'));

      expect(await repository.testWebSocket(), isFalse);
    });
  });

  group('testStun', () {
    test('returns true when the offer carries an sdp', () async {
      when(
        webRtcClient.createOffer(),
      ).thenAnswer((_) async => RTCSessionDescription('v=0 candidate', 'offer'));
      when(webRtcClient.close()).thenAnswer((_) async {});

      expect(await repository.testStun(), isTrue);
      verify(webRtcClient.close()).called(1);
    });

    test('returns false when the offer has no sdp', () async {
      when(
        webRtcClient.createOffer(),
      ).thenAnswer((_) async => RTCSessionDescription(null, 'offer'));
      when(webRtcClient.close()).thenAnswer((_) async {});

      expect(await repository.testStun(), isFalse);
    });

    test('returns false when the sdp is empty', () async {
      when(
        webRtcClient.createOffer(),
      ).thenAnswer((_) async => RTCSessionDescription('', 'offer'));
      when(webRtcClient.close()).thenAnswer((_) async {});

      expect(await repository.testStun(), isFalse);
    });

    test('closes the client when the offer throws', () async {
      when(webRtcClient.createOffer()).thenThrow(Exception('no stun server'));
      when(webRtcClient.close()).thenAnswer((_) async {});

      expect(await repository.testStun(), isFalse);
      verify(webRtcClient.close()).called(1);
    });
  });
}
