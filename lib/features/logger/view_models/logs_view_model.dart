import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:reader/features/logger/application/logger_service.dart';
import 'package:reader/features/logger/domain/log.dart';

@injectable
class LogsViewModel extends ChangeNotifier {
  final LoggerService _loggerService;

  LogsViewModel(this._loggerService);

  List<Log> _logs = [];
  bool _isLoading = false;

  List<Log> get logs => _logs;
  bool get isLoading => _isLoading;

  Future<void> loadLogs() async {
    _isLoading = true;
    notifyListeners();
    _logs = await _loggerService.getLogs();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> clearLogs() async {
    await _loggerService.clearLogs();
    _logs = [];
    notifyListeners();
  }
}