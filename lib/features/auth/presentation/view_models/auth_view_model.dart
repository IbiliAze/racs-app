import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:reader/features/auth/application/auth_notifier.dart';
import 'package:reader/features/auth/application/auth_service.dart';
import 'package:reader/features/auth/domain/reader.dart';

enum AuthStatus { idle, loading, success, error }

@injectable
class AuthViewModel extends ChangeNotifier {
  final AuthService _authService;
  final AuthNotifier _authNotifier;

  AuthViewModel(this._authService, this._authNotifier);

  AuthStatus _status = AuthStatus.idle;
  Reader? _reader;
  String? _error;

  AuthStatus get status => _status;
  Reader? get reader => _reader;
  String? get error => _error;
  bool get isLoading => _status == AuthStatus.loading;

  Future<void> login(String username, String password) async {
    _setStatus(AuthStatus.loading);

    try {
      await _authService.login(username, password);
      _reader = await _authService.getAuthReader();
      _error = null;
      _setStatus(AuthStatus.success);
      _authNotifier.setAuthenticated(true);
    } catch (e) {
      _error = e.toString();
      _setStatus(AuthStatus.error);
    }
  }

  void reset() {
    _status = AuthStatus.idle;
    _reader = null;
    _error = null;
    notifyListeners();
  }

  void _setStatus(AuthStatus status) {
    _status = status;
    notifyListeners();
  }
}