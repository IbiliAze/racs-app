import 'dart:async';
import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:reader/core/network/webrtc_mesh_client.dart';
import 'package:reader/features/cards/domain/card_local_repository.dart';
import 'package:reader/features/logger/application/logger_service.dart';

@lazySingleton
class PeerSyncService {
  final WebRtcMeshClient _webRtcClient;
  final CardLocalRepository _localRepository;
  final LoggerService _loggerService;

  StreamSubscription<String>? _subscription;

  PeerSyncService(this._webRtcClient, this._localRepository, this._loggerService);

  void init() {
    _subscription = _webRtcClient.messages.listen(_onMessage);
  }

  Future<void> _onMessage(String raw) async {
    try {
      final data = jsonDecode(raw) as Map<String, dynamic>;
      final type = data['type'] as String?;

      if (type == 'card_used') {
        final cardId = data['cardId'] as String;
        _loggerService.debug('Peer card_used received: $cardId', className: 'PeerSyncService');
        await _localRepository.markUsed(cardId);
        _loggerService.debug('Local DB updated for card: $cardId', className: 'PeerSyncService');
      }
    } catch (e) {
      _loggerService.error('Failed to process peer message: $e', className: 'PeerSyncService');
    }
  }

  void broadcastCardUsed(String cardId) {
    final message = jsonEncode({'type': 'card_used', 'cardId': cardId});
    _loggerService.debug
      ('Broadcasting card_used: $cardId', className: 'PeerSyncService');
    _webRtcClient.send(message);
  }

  void dispose() {
    _subscription?.cancel();
    _subscription = null;
  }
}