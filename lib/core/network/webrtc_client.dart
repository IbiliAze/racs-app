import 'dart:async';

import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class WebRtcClient {
  RTCPeerConnection? _peerConnection;
  RTCDataChannel? _dataChannel;

  final _messageController = StreamController<String>.broadcast();
  Stream<String> get messages => _messageController.stream;

  final _connectionStateController = StreamController<RTCPeerConnectionState>.broadcast();
  Stream<RTCPeerConnectionState> get connectionState => _connectionStateController.stream;

  static const _config = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
    ],
  };

  static final _dataChannelInit = RTCDataChannelInit();

  Future<RTCSessionDescription> createOffer() async {
    await _initPeerConnection();
    final offer = await _peerConnection!.createOffer();
    await _peerConnection!.setLocalDescription(offer);
    return offer;
  }

  Future<RTCSessionDescription> createAnswer(RTCSessionDescription offer) async {
    await _initPeerConnection();
    await _peerConnection!.setRemoteDescription(offer);
    final answer = await _peerConnection!.createAnswer();
    await _peerConnection!.setLocalDescription(answer);
    return answer;
  }

  Future<void> setRemoteDescription(RTCSessionDescription description) async {
    await _peerConnection?.setRemoteDescription(description);
  }

  Future<void> addIceCandidate(RTCIceCandidate candidate) async {
    await _peerConnection?.addCandidate(candidate);
  }

  void send(String message) {
    _dataChannel?.send(RTCDataChannelMessage(message));
  }

  Future<void> close() async {
    await _dataChannel?.close();
    await _peerConnection?.close();
    _dataChannel = null;
    _peerConnection = null;
  }

  Future<void> dispose() async {
    await close();
    await _messageController.close();
    await _connectionStateController.close();
  }

  Future<void> _initPeerConnection() async {
    if (_peerConnection != null) return;

    _peerConnection = await createPeerConnection(_config);

    _dataChannel = await _peerConnection!.createDataChannel(
      'data',
      _dataChannelInit,
    );

    _dataChannel!.onMessage = (msg) => _messageController.add(msg.text);

    _peerConnection!.onConnectionState = (state) {
      _connectionStateController.add(state);
    };

    _peerConnection!.onIceCandidate = (candidate) {
      // Forward candidate to remote peer via signaling (WebSocket)
    };
  }
}