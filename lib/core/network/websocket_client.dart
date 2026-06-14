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

  final _messageController = StreamController<String>.broadcast();
  Stream<String> get messages => _messageController.stream;

  WebSocketClient(this._settingsStorage, this._secureStorage);

  Future<String> get host async {
    _host ??= await _settingsStorage.getHost();
    return _host!;
  }

  void resetHost() => _host = null;

  Future<void> connect(String path) async {
    final h = await host;
    final scheme = Env.apiSecure ? 'wss' : 'ws';
    final uri = '$scheme://$h$path';
    _lastPath = path;

    final token = await _secureStorage.getAccessToken();
    final headers = token != null ? {'Authorization': 'Bearer $token'} : null;

    _intentionalClose = false;
    _socket = await WebSocket.connect(uri, headers: headers);
    _socket!.listen(
      (data) => _messageController.add(data as String),
      onDone: _onDone,
      onError: (e) => _messageController.addError(e),
      cancelOnError: false,
    );
  }

  void send(String message) => _socket?.add(message);

  Future<void> disconnect() async {
    _intentionalClose = true;
    await _socket?.close();
    _socket = null;
  }

  void _onDone() {
    if (!_intentionalClose) {
      Future.delayed(const Duration(seconds: 2), () async {
        if (!_intentionalClose && _lastPath != null) {
          await connect(_lastPath!);
        }
      });
    }
  }

  Future<void> dispose() async {
    _intentionalClose = true;
    await _socket?.close();
    await _messageController.close();
  }
}