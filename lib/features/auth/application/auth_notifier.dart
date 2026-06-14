import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class AuthNotifier extends ChangeNotifier {
  bool _isAuthenticated = false;
  bool get isAuthenticated => _isAuthenticated;

  void setAuthenticated(bool value) {
    _isAuthenticated = value;
    notifyListeners();
  }
}