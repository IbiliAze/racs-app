import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class ConnectionNotifier extends ChangeNotifier {
  bool _isConnected = false;
  bool get isConnected => _isConnected;

  void setConnected(bool state) {
    _isConnected = state;
    notifyListeners();
  }
}