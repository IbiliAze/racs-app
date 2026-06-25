import 'dart:async';
import 'dart:convert';

import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:injectable/injectable.dart';
import 'package:reader/core/network/webrtc_mesh_client.dart';
import 'package:reader/core/network/websocket_client.dart';
import 'package:reader/core/storage/secure_storage.dart';
import 'package:reader/features/tickets/application/ticket_service.dart';
import 'package:reader/features/logger/application/logger_service.dart';
import 'package:reader/features/scanner/application/scanner_service.dart';

enum Action { created, updated, deleted }

@lazySingleton
class MeshService {
  final WebSocketClient _wsClient;
  final WebRtcMeshClient _meshClient;
  final SecureStorage _secureStorage;
  final LoggerService _loggerService;
  final TicketService _ticketService;
  final ScannerService _scannerService;

  StreamSubscription<String>? _wsSubscription;
  StreamSubscription<IceCandidateEvent>? _iceSubscription;
  StreamSubscription<bool>? _connectionSubscription;
  String? _readerId;
  String? _eventId;

  MeshService(
    this._wsClient,
    this._meshClient,
    this._secureStorage,
    this._loggerService,
    this._ticketService,
    this._scannerService,
  );

  Future<void> connect() async {
    try {
      _loggerService.debug('Connecting to mesh', className: 'MeshService');

      final profile = await _secureStorage.getProfile();
      if (profile == null) return;

      _readerId = profile['id'] as String?;
      _eventId = profile['eventId'] as String?;

      _wsSubscription ??= _wsClient.messages.listen(_onSignalingMessage);
      _iceSubscription ??= _meshClient.iceCandidates.listen(_onLocalIce);
      _connectionSubscription ??= _wsClient.connectionState.listen((connected) {
        if (connected) {
          _sendJoin();
        }
      });

      await _wsClient.connect('/ws/mesh');
    } catch (e) {
      _loggerService.error('Mesh connect failed: $e', className: 'MeshService');
    }
  }

  void _sendJoin() {
    _wsClient.send(
      jsonEncode({'type': 'join', 'readerId': _readerId, 'eventId': _eventId}),
    );
    _loggerService.info(
      'Join (re)sent as $_readerId at $_eventId',
      className: 'MeshService',
    );
  }

  void _onLocalIce(IceCandidateEvent event) {
    _wsClient.send(
      jsonEncode({
        'type': 'ice_candidate',
        'from': _readerId,
        'to': event.peerId,
        'candidate': event.candidate.toMap(),
      }),
    );
  }

  Future<void> _onSignalingMessage(String raw) async {
    try {
      final data = jsonDecode(raw) as Map<String, dynamic>;

      switch (data['type'] as String?) {
        case 'peer_list':
          final peers = (data['peers'] as List).cast<String>();
          _loggerService.info(
            'Mesh peers at events: $peers',
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

        case 'ticket_update':
          _loggerService.debug(
            'Received ticket_update message from control plane',
            className: 'MeshService',
          );
          final action = Action.values.byName(data['action'] as String);
          final ticket = data['ticket'] as Map<String, dynamic>;
          switch (action) {
            case Action.created || Action.updated:
              await _ticketService.upsertFromMap(ticket);
            case Action.deleted:
              await _ticketService.delete(ticket['id'] as String);
          }

        case 'scan_update':
          _loggerService.debug(
            'Received scan_update message from control plane',
            className: 'MeshService',
          );
          final action = Action.values.byName(data['action'] as String);
          final scan = data['scan'] as Map<String, dynamic>;
          switch (action) {
            case Action.created || Action.updated:
              await _scannerService.upsertFromMap(scan);
            case Action.deleted:
              await _scannerService.delete(scan['id'] as String);
          }
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
    await _connectionSubscription?.cancel();
    await _wsSubscription?.cancel();
    await _iceSubscription?.cancel();
    _connectionSubscription = null;
    _wsSubscription = null;
    _iceSubscription = null;
    await _wsClient.disconnect();
  }
}
