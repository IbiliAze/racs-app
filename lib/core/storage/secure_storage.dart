import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class SecureStorage {
  static const String _accessTokenKey = 'access_token';
  static const String _profileKey = 'profile';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<String?> getAccessToken() => _storage.read(key: _accessTokenKey);

  Future<void> saveAccessToken(String token) =>
      _storage.write(key: _accessTokenKey, value: token);

  Future<Map<String, dynamic>?> getProfile() async {
    final raw = await _storage.read(key: _profileKey);
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  Future<void> saveProfile(Map<String, dynamic> profile) =>
      _storage.write(key: _profileKey, value: jsonEncode(profile));

  Future<void> clearTokens() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _profileKey);
  }
}