import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:reader/core/network/http_client.dart';
import 'package:reader/core/storage/secure_storage.dart';
import 'package:reader/features/scanner/domain/scan_flag.dart';
import 'package:reader/features/scanner/domain/scan_remote_repository.dart';

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
      if (cardId != null) 'cardId': cardId,
    };

    await _httpClient.post('/api/scan', body: jsonEncode(body));
  }
}