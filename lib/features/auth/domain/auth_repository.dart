import 'package:racs_reader/features/auth/domain/reader.dart';

abstract class AuthRepository {
  Future<String> login(String username, String password);
  Future<Reader> getAuthReader();
}
