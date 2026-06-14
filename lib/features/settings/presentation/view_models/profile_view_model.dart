import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:reader/core/storage/secure_storage.dart';
import 'package:reader/features/auth/application/auth_notifier.dart';
import 'package:reader/features/auth/data/reader_dto.dart';
import 'package:reader/features/auth/domain/reader.dart';

@injectable
class ProfileViewModel extends ChangeNotifier {
  final SecureStorage _secureStorage;
  final AuthNotifier _authNotifier;

  ProfileViewModel(this._secureStorage, this._authNotifier);

  Reader? _reader;
  bool _isLoading = false;
  bool _isLoggingOut = false;

  Reader? get reader => _reader;
  bool get isLoading => _isLoading;
  bool get isLoggingOut => _isLoggingOut;

  Future<void> loadProfile() async {
    _isLoading = true;
    notifyListeners();
    try {
      final profile = await _secureStorage.getProfile();
      if (profile != null) {
        _reader = ReaderDto.fromJson(profile).toDomain();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isLoggingOut = true;
    notifyListeners();
    try {
      await _secureStorage.clearTokens();
      _authNotifier.setAuthenticated(false);
    } finally {
      _isLoggingOut = false;
      notifyListeners();
    }
  }
}