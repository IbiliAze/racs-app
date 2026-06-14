import 'dart:async';
import 'dart:convert';

import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:injectable/injectable.dart';
import 'package:reader/core/network/webrtc_mesh_client.dart';
import 'package:reader/core/network/websocket_client.dart';
import 'package:reader/core/storage/secure_storage.dart';
import 'package:reader/features/logger/application/logger_service.dart';

@lazySingleton
class MeshService {
  final WebSocketClient _wsClient;
  final WebRtcMeshClient _meshClient;
  final SecureStorage _secureStorage;
  final LoggerService _loggerService;

  StreamSubscription<String>? _wsSubscription;
  StreamSubscription<IceCandidateEvent>? _iceSubscription;
  String? _readerId;

  MeshService(
    this._wsClient,
    this._meshClient,
    this._secureStorage,
    this._loggerService,
  );

  Future<void> connect() async {
    final profile = await _secureStorage.getProfile();
    if (profile == null) return;

    _readerId = profile['id'] as String?;
    final locationId = profile['locationId'] as String?;

    try {
      await _wsClient.connect('/ws/mesh');

      _wsClient.send(
        jsonEncode({
          'type': 'join',
          'readerId': _readerId,
          'locationId': locationId,
        }),
      );

      _wsSubscription = _wsClient.messages.listen(_onSignalingMessage);

      _iceSubscription = _meshClient.iceCandidates.listen((event) {
        _wsClient.send(
          jsonEncode({
            'type': 'ice_candidate',
            'from': _readerId,
            'to': event.peerId,
            'candidate': event.candidate.toMap(),
          }),
        );
      });

      _loggerService.info(
        'Mesh joined as $_readerId at $locationId',
        className: 'MeshService',
      );
    } catch (e) {
      _loggerService.error('Mesh connect failed: $e', className: 'MeshService');
    }
  }

  Future<void> _onSignalingMessage(String raw) async {
    try {
      final data = jsonDecode(raw) as Map<String, dynamic>;

      switch (data['type'] as String?) {
        case 'peer_list':
          final peers = (data['peers'] as List).cast<String>();
          _loggerService.info(
            'Mesh peers at location: $peers',
            className: 'MeshService',
          );
          for (final peerId in peers) {
            await _sendOffer(peerId);
          }

        case 'peer_joined':
          _loggerService.info(
            'New peer joined: ${data['peerId']}',
            className: 'MeshService',
          );
        // New peer sends the offer; we wait

        case 'offer':
          final from = data['from'] as String;
          final sdp = RTCSessionDescription(data['sdp'] as String, 'offer');
          final answer = await _meshClient.createAnswer(from, sdp);
          _wsClient.send(
            jsonEncode({
              'type': 'answer',
              'from': _readerId,
              'to': from,
              'sdp': answer.sdp,
            }),
          );
          _loggerService.info('Answer sent to $from', className: 'MeshService');

        case 'answer':
          final from = data['from'] as String;
          final sdp = RTCSessionDescription(data['sdp'] as String, 'answer');
          await _meshClient.setRemoteDescription(from, sdp);
          _loggerService.info(
            'Connected to peer $from',
            className: 'MeshService',
          );

        case 'ice_candidate':
          final from = data['from'] as String;
          final c = data['candidate'] as Map<String, dynamic>;
          await _meshClient.addIceCandidate(
            from,
            RTCIceCandidate(
              c['candidate'] as String,
              c['sdpMid'] as String?,
              c['sdpMLineIndex'] as int?,
            ),
          );
      }
    } catch (e) {
      _loggerService.error(
        'Signaling error: $e | raw: $raw',
        className: 'MeshService',
      );
    }
  }

  Future<void> _sendOffer(String peerId) async {
    try {
      final offer = await _meshClient.createOffer(peerId);
      _wsClient.send(
        jsonEncode({
          'type': 'offer',
          'from': _readerId,
          'to': peerId,
          'sdp': offer.sdp,
        }),
      );
      _loggerService.info('Offer sent to $peerId', className: 'MeshService');
    } catch (e) {
      _loggerService.error(
        'Failed to offer to $peerId: $e',
        className: 'MeshService',
      );
    }
  }

  Future<void> disconnect() async {
    await _wsSubscription?.cancel();
    await _iceSubscription?.cancel();
    await _wsClient.disconnect();
  }
}
