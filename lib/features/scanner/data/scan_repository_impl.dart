import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:racs_reader/core/network/http_client.dart';
import 'package:racs_reader/core/storage/secure_storage.dart';
import 'package:racs_reader/features/scanner/domain/scan_flag.dart';
import 'package:racs_reader/features/scanner/domain/scan_remote_repository.dart';
import 'package:racs_reader/features/scanner/domain/scan_submit_exception.dart';

@Injectable(as: ScanRemoteRepository)
class ScanRepositoryImpl implements ScanRemoteRepository {
  final HttpClient _httpClient;
  final SecureStorage _secureStorage;

  ScanRepositoryImpl(this._httpClient, this._secureStorage);

  @override
  Future<void> submit({
    required String scannedValue,
    required ScanFlag flag,
    String? cardId,
  }) async {
    final profile = await _secureStorage.getProfile();
    final readerId = profile?['id'] as String?;
    if (readerId == null) return;

    final body = <String, dynamic>{
      'readerId': readerId,
      'scannedValue': scannedValue,
      'flag': flag.serverValue,
      'cardId': ?cardId,
    };

    final response = await _httpClient.post(
      '/api/scan',
      body: jsonEncode(body),
    );
    final status = response.statusCode;

    if (status >= 200 && status < 300) return;

    final responseBody = await response.transform(utf8.decoder).join();
    throw ScanSubmitException(responseBody, statusCode: status);
  }
}
