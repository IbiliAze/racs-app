import 'package:injectable/injectable.dart';
import 'package:reader/features/auth/domain/auth_repository.dart';
import 'package:reader/features/auth/domain/reader.dart';

@lazySingleton
class AuthService {
  final AuthRepository _authRepository;

  AuthService(this._authRepository);

  Future<void> login(String username, String password) async {
    await _authRepository.login(username, password);
  }

  Future<Reader> getAuthReader() async {
    return _authRepository.getAuthReader();
  }
}