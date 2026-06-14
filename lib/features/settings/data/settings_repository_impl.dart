import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:injectable/injectable.dart';
import 'package:reader/core/network/http_client.dart';
import 'package:reader/core/network/websocket_client.dart';
import 'package:reader/core/network/webrtc_client.dart';
import 'package:reader/core/storage/settings_storage.dart';
import 'package:reader/features/settings/domain/settings_repository.dart';

@Injectable(as: SettingsRepository)
class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsStorage _settingsStorage;
  final HttpClient _httpClient;
  final WebSocketClient _webSocketClient;
  final WebRtcClient _webRtcClient;

  SettingsRepositoryImpl(
    this._settingsStorage,
    this._httpClient,
    this._webSocketClient,
    this._webRtcClient,
  );

  @override
  Future<void> saveHost(String host) async {
    await _settingsStorage.saveHost(host);
    _httpClient.resetHost();
    _webSocketClient.resetHost();
  }

  @override
  Future<String?> getHost() => _settingsStorage.getHost();

  @override
  Future<bool> testHttp() async {
    try {
      final response = await _httpClient.get('/api/health');
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> testWebSocket() async {
    try {
      await _webSocketClient.connect('/ws/health');
      await _webSocketClient.disconnect();
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> testStun() async {
    try {
      final offer = await _webRtcClient.createOffer();
      return offer.sdp != null && offer.sdp!.isNotEmpty;
    } catch (_) {
      return false;
    } finally {
      await _webRtcClient.close();
    }
  }
}