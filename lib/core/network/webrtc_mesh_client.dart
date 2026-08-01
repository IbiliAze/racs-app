import 'dart:async';

import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:injectable/injectable.dart';

typedef IceCandidateSignal = ({String peerId, RTCIceCandidate candidate});

@lazySingleton
class WebRtcMeshClient {
  final Map<String, RTCPeerConnection> _connections = {};
  final Map<String, RTCDataChannel> _channels = {};

  final _messageController = StreamController<String>.broadcast();
  final _iceCandidateController =
      StreamController<IceCandidateSignal>.broadcast();

  Stream<String> get messages => _messageController.stream;
  Stream<IceCandidateSignal> get iceCandidates =>
      _iceCandidateController.stream;

  static const _iceConfig = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
    ],
  };

  Future<RTCSessionDescription> createOffer(String peerId) async {
    final pc = await _getOrCreateConnection(peerId);

    final channel = await pc.createDataChannel('data', RTCDataChannelInit());
    _registerChannel(peerId, channel);

    final offer = await pc.createOffer();
    await pc.setLocalDescription(offer);
    return offer;
  }

  Future<RTCSessionDescription> createAnswer(
    String peerId,
    RTCSessionDescription offer,
  ) async {
    final pc = await _getOrCreateConnection(peerId);

    pc.onDataChannel = (channel) => _registerChannel(peerId, channel);

    await pc.setRemoteDescription(offer);
    final answer = await pc.createAnswer();
    await pc.setLocalDescription(answer);
    return answer;
  }

  Future<void> setRemoteDescription(
    String peerId,
    RTCSessionDescription description,
  ) async {
    await _connections[peerId]?.setRemoteDescription(description);
  }

  Future<void> addIceCandidate(String peerId, RTCIceCandidate candidate) async {
    await _connections[peerId]?.addCandidate(candidate);
  }

  void send(String message) {
    for (final entry in _channels.entries) {
      if (entry.value.state == RTCDataChannelState.RTCDataChannelOpen) {
        entry.value.send(RTCDataChannelMessage(message));
      }
    }
  }

  int get peerCount => _connections.length;

  Future<void> closePeer(String peerId) async {
    await _channels[peerId]?.close();
    await _connections[peerId]?.close();
    _channels.remove(peerId);
    _connections.remove(peerId);
  }

  Future<void> dispose() async {
    for (final peerId in _connections.keys.toList()) {
      await closePeer(peerId);
    }
    await _messageController.close();
    await _iceCandidateController.close();
  }

  Future<RTCPeerConnection> _getOrCreateConnection(String peerId) async {
    if (_connections.containsKey(peerId)) return _connections[peerId]!;

    final pc = await createPeerConnection(_iceConfig);
    _connections[peerId] = pc;

    pc.onIceCandidate = (candidate) {
      _iceCandidateController.add((peerId: peerId, candidate: candidate));
    };

    pc.onConnectionState = (state) {
      if (state == RTCPeerConnectionState.RTCPeerConnectionStateFailed ||
          state == RTCPeerConnectionState.RTCPeerConnectionStateDisconnected) {
        closePeer(peerId);
      }
    };

    return pc;
  }

  void _registerChannel(String peerId, RTCDataChannel channel) {
    _channels[peerId] = channel;
    channel.onMessage = (msg) => _messageController.add(msg.text);
  }
}
