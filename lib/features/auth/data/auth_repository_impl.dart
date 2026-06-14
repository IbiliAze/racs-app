import 'dart:convert';
import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:reader/core/network/http_client.dart';
import 'package:reader/core/storage/secure_storage.dart';
import 'package:reader/features/auth/data/reader_dto.dart';
import 'package:reader/features/auth/domain/auth_repository.dart';
import 'package:reader/features/auth/domain/reader.dart';

@Injectable(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final HttpClient _httpClient;
  final SecureStorage _secureStorage;

  AuthRepositoryImpl(this._httpClient, this._secureStorage);

  @override
  Future<String> login(String username, String password) async {
    final response = await _httpClient.post(
      '/api/reader/token',
      body: jsonEncode({'username': username, 'password': password}),
    );

    final json = await _parseBody(response);
    final token = json['token'] as String;
    await _secureStorage.saveAccessToken(token);
    return token;
  }

  @override
  Future<Reader> getAuthReader() async {
    final response = await _httpClient.get('/api/reader/auth');
    final json = await _parseBody(response);
    await _secureStorage.saveProfile(json['reader']);
    return ReaderDto.fromJson(json['reader'] as Map<String, dynamic>).toDomain();
  }

  Future<Map<String, dynamic>> _parseBody(HttpClientResponse response) async {
    final raw = await response.transform(utf8.decoder).join();
    return jsonDecode(raw) as Map<String, dynamic>;
  }
}