import 'dart:async';
import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:reader/core/network/webrtc_mesh_client.dart';
import 'package:reader/features/tickets/domain/ticket_local_repository.dart';
import 'package:reader/features/logger/application/logger_service.dart';

@lazySingleton
class PeerSyncService {
  final WebRtcMeshClient _webRtcClient;
  final TicketLocalRepository _localRepository;
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

      if (type == 'ticket_used') {
        final ticketId = data['ticketId'] as String;
        _loggerService.debug('Peer ticket_used received: $ticketId', className: 'PeerSyncService');
        await _localRepository.markUsed(ticketId);
        _loggerService.debug('Local DB updated for ticket: $ticketId', className: 'PeerSyncService');
      }
    } catch (e) {
      _loggerService.error('Failed to process peer message: $e', className: 'PeerSyncService');
    }
  }

  void broadcastTicketUsed(String ticketId) {
    final message = jsonEncode({'type': 'ticket_used', 'ticketId': ticketId});
    _loggerService.debug
      ('Broadcasting ticket_used: $ticketId', className: 'PeerSyncService');
    _webRtcClient.send(message);
  }

  void dispose() {
    _subscription?.cancel();
    _subscription = null;
  }
}