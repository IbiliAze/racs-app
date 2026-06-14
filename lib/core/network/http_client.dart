import 'dart:io' as io;

import 'package:injectable/injectable.dart';
import 'package:reader/core/storage/secure_storage.dart';
import 'package:reader/core/storage/settings_storage.dart';

@lazySingleton
class HttpClient {
  final SettingsStorage _settingsStorage;
  final SecureStorage _secureStorage;

  String? _host;

  HttpClient(this._settingsStorage, this._secureStorage);

  Future<String> get host async {
    _host ??= await _settingsStorage.getHost();
    return _host!;
  }

  void resetHost() => _host = null;

  Future<void> _attachAuth(io.HttpClientRequest request) async {
    final token = await _secureStorage.getAccessToken();
    if (token != null) {
      request.headers.set(io.HttpHeaders.authorizationHeader, 'Bearer $token');
    }
  }

  Future<io.HttpClientResponse> get(String path) async {
    final h = await host;
    final uri = Uri.http(h, path);
    final client = io.HttpClient();
    final request = await client.getUrl(uri);
    await _attachAuth(request);
    return request.close();
  }

  Future<io.HttpClientResponse> post(String path, {Object? body}) async {
    final h = await host;
    final uri = Uri.http(h, path);
    final client = io.HttpClient();
    final request = await client.postUrl(uri);
    await _attachAuth(request);
    if (body != null) {
      request.headers.contentType = io.ContentType.json;
      request.write(body);
    }
    return request.close();
  }

  Future<io.HttpClientResponse> put(String path, {Object? body}) async {
    final h = await host;
    final uri = Uri.http(h, path);
    final client = io.HttpClient();
    final request = await client.putUrl(uri);
    await _attachAuth(request);
    if (body != null) {
      request.headers.contentType = io.ContentType.json;
      request.write(body);
    }
    return request.close();
  }

  Future<io.HttpClientResponse> delete(String path) async {
    final h = await host;
    final uri = Uri.http(h, path);
    final client = io.HttpClient();
    final request = await client.deleteUrl(uri);
    await _attachAuth(request);
    return request.close();
  }
}