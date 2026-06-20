import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:reader/features/logger/application/logger_service.dart';
import 'package:reader/features/logger/domain/log.dart';
import 'package:reader/features/logger/domain/log_params.dart';

@injectable
class LogsViewModel extends ChangeNotifier {
  static const pageSize = 30;

  final LoggerService _loggerService;

  LogsViewModel(this._loggerService);

  List<Log> _logs = [];
  bool _isLoading = false;
  int _page = 0;
  int _totalCount = 0;

  List<Log> get logs => _logs;
  bool get isLoading => _isLoading;
  int get page => _page;
  int get totalPages => (_totalCount / pageSize).ceil();
  bool get canGoPrevious => _page > 0;
  bool get canGoNext => _page < totalPages - 1;

  Future<void> loadLogs() async {
    _page = 0;
    _isLoading = true;
    notifyListeners();
    try {
      _totalCount = await _loggerService.countLogs();
      _logs = await _loggerService.getLogs(LogParams(page: _page, size: pageSize));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> nextPage() async {
    if (!canGoNext) return;
    await _loadPage(_page + 1);
  }

  Future<void> previousPage() async {
    if (!canGoPrevious) return;
    await _loadPage(_page - 1);
  }

  Future<void> _loadPage(int page) async {
    _isLoading = true;
    notifyListeners();
    try {
      _logs = await _loggerService.getLogs(LogParams(page: page, size: pageSize));
      _page = page;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> clearLogs() async {
    await _loggerService.clearLogs();
    _logs = [];
    _totalCount = 0;
    _page = 0;
    notifyListeners();
  }
}