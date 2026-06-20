import 'dart:async';
import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:reader/core/constants/env.dart';
import 'package:reader/core/storage/secure_storage.dart';
import 'package:reader/core/storage/settings_storage.dart';

@lazySingleton
class WebSocketClient {
  final SettingsStorage _settingsStorage;
  final SecureStorage _secureStorage;

  WebSocket? _socket;
  String? _host;
  String? _lastPath;
  bool _intentionalClose = false;

  Timer? _reconnectTimer;
  Duration _backoff = const Duration(seconds: 1);
  static const _maxBackoff = Duration(seconds: 30);

  final _messageController = StreamController<String>.broadcast();
  final _connectionController = StreamController<bool>.broadcast();

  Stream<String> get messages => _messageController.stream;
  Stream<bool> get connectionState => _connectionController.stream;

  WebSocketClient(this._settingsStorage, this._secureStorage);

  Future<String> get host async {
    _host ??= await _settingsStorage.getHost();
    return _host!;
  }

  void resetHost() => _host = null;

  Future<void> connect(String path) async {
    _lastPath = path;
    _intentionalClose = false;
    await _connect();
  }

  Future<void> _connect() async {
    _reconnectTimer?.cancel();
    try {
      final h = await host;
      final scheme = Env.apiSecure ? 'wss' : 'ws';
      final uri = '$scheme://$h$_lastPath';

      final token = await _secureStorage.getAccessToken();
      final headers = token != null ? {'Authorization': 'Bearer $token'} : null;

      _socket = await WebSocket.connect(uri, headers: headers);
      _backoff = const Duration(seconds: 1); // reset on success
      _connectionController.add(true);

      _socket!.listen(
            (data) => _messageController.add(data as String),
        onDone: _onDone,
        onError: (e) => _messageController.addError(e),
        cancelOnError: false,
      );
    } catch (_) {
      // Server still down (mid-restart) — back off and keep trying.
      _connectionController.add(false);
      _scheduleReconnect();
    }
  }

  void _onDone() {
    _socket = null;
    _connectionController.add(false);
    if (_intentionalClose) return;
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (_intentionalClose || _lastPath == null) return;
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(_backoff, _connect);
    final next = _backoff * 2;
    _backoff = next > _maxBackoff ? _maxBackoff : next;
  }

  void send(String message) => _socket?.add(message);

  Future<void> disconnect() async {
    _intentionalClose = true;
    _reconnectTimer?.cancel();
    await _socket?.close();
    _socket = null;
    _connectionController.add(false);
  }

  Future<void> dispose() async {
    _intentionalClose = true;
    _reconnectTimer?.cancel();
    await _socket?.close();
    await _messageController.close();
    await _connectionController.close();
  }
}