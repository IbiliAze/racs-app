import 'package:injectable/injectable.dart';
import 'package:racs_reader/core/network/http_client.dart';
import 'package:racs_reader/core/network/websocket_client.dart';
import 'package:racs_reader/core/network/webrtc_client.dart';
import 'package:racs_reader/core/storage/settings_storage.dart';
import 'package:racs_reader/features/settings/domain/settings_repository.dart';

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
  Future<void> saveCampaignId(String campaignId) async {
    await _settingsStorage.saveCampaignId(campaignId);
  }

  @override
  Future<String?> getCampaignId() => _settingsStorage.getCampaignId();

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
