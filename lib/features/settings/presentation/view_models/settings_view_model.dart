import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:reader/features/settings/application/connection_notifier.dart';
import 'package:reader/features/settings/application/settings_service.dart';

@injectable
class SettingsViewModel extends ChangeNotifier {
  final SettingsService _settingsService;
  final ConnectionNotifier _connectionNotifier;

  SettingsViewModel(this._settingsService, this._connectionNotifier);

  String? _host;
  bool _isTesting = false;
  bool _isHttpConnected = false;
  bool _isWsConnected = false;
  bool _isStunConnected = false;

  String? get host => _host;
  bool get isTesting => _isTesting;
  bool get isHttpConnected => _isHttpConnected;
  bool get isWsConnected => _isWsConnected;
  bool get isStunConnected => _isStunConnected;

  Future<void> loadHost() async {
    _host = await _settingsService.getHost();
    notifyListeners();
  }

  Future<void> testConnections(String host) async {
    _isTesting = true;
    notifyListeners();

    _host = host;
    await _settingsService.saveHost(host);

    await Future.wait([
      _settingsService.testHttp().then((v) {
        _isHttpConnected = v;
        notifyListeners();
      }),
      _settingsService.testWebSocket().then((v) {
        _isWsConnected = v;
        notifyListeners();
      }),
      _settingsService.testStun().then((v) {
        _isStunConnected = v;
        notifyListeners();
      }),
    ]);

    _isTesting = false;
    _connectionNotifier.setConnected(
      _isHttpConnected && _isWsConnected && _isStunConnected
    );
    notifyListeners();
  }
}