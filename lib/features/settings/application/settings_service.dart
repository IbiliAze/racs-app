import 'package:injectable/injectable.dart';
import 'package:reader/features/settings/domain/settings_repository.dart';

@lazySingleton
class SettingsService {
  final SettingsRepository _settingsRepository;

  SettingsService(this._settingsRepository);

  Future<void> saveHost(String host) => _settingsRepository.saveHost(host);
  Future<String?> getHost() => _settingsRepository.getHost();
  Future<bool> testHttp() => _settingsRepository.testHttp();
  Future<bool> testWebSocket() => _settingsRepository.testWebSocket();
  Future<bool> testStun() => _settingsRepository.testStun();
}