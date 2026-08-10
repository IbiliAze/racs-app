import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;

import 'package:flutter_test/flutter_test.dart';
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

  group('saveHost', () {});

  group('getHost', () {});

  group('saveCampaignId', () {});

  group('getCampaignId', () {});

  group('testHttp', () {});

  group('testWebSocket', () {});

  group('testStun', () {});
}
