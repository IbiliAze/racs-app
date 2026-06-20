import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:reader/features/dlq/application/dlq_service.dart';
import 'package:reader/features/dlq/domain/dlq_item.dart';
import 'package:reader/features/dlq/domain/dlq_params.dart';

@injectable
class DlqViewModel extends ChangeNotifier {
  static const pageSize = 30;

  final DlqService _dlqService;

  DlqViewModel(this._dlqService);

  List<DlqItem> _dlq = [];
  bool _isLoading = false;
  bool _inserting = false;
  bool _removingItem = false;
  DlqItem? _retryingItem;
  int _page = 0;
  int _totalCount = 0;

  List<DlqItem> get dlq => _dlq;
  bool get isLoading => _isLoading;
  bool get isInserting => _inserting;
  bool get isRemovingItem => _removingItem;
  bool isRetrying(DlqItem item) => _retryingItem == item;
  int get page => _page;
  int get totalPages => (_totalCount / pageSize).ceil();
  bool get canGoPrevious => _page > 0;
  bool get canGoNext => _page < totalPages - 1;

  Future<void> loadDlq() async {
    _page = 0;
    _isLoading = true;
    notifyListeners();
    try {
      _totalCount = await _dlqService.countDlq();
      _dlq = await _dlqService.getDlq(DlqParams(page: _page, size: pageSize));
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
      _dlq = await _dlqService.getDlq(DlqParams(page: page, size: pageSize));
      _page = page;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _reload() async {
    _totalCount = await _dlqService.countDlq();
    final safePage = totalPages > 0 ? _page.clamp(0, totalPages - 1) : 0;
    _dlq = await _dlqService.getDlq(DlqParams(page: safePage, size: pageSize));
    _page = safePage;
    notifyListeners();
  }

  Future<void> insertDlqItem(DlqItem dlqItem) async {
    _inserting = true;
    notifyListeners();
    try {
      await _dlqService.insertItem(dlqItem);
      _totalCount = await _dlqService.countDlq();
      _dlq = await _dlqService.getDlq(DlqParams(page: 0, size: pageSize));
      _page = 0;
    } finally {
      _inserting = false;
      notifyListeners();
    }
  }

  Future<void> removeDlqItem(DlqItem dlqItem) async {
    _removingItem = true;
    notifyListeners();
    try {
      await _dlqService.clearItem(dlqItem);
      await _reload();
    } finally {
      _removingItem = false;
      notifyListeners();
    }
  }

  Future<void> retryItem(DlqItem dlqItem) async {
    _retryingItem = dlqItem;
    notifyListeners();
    try {
      await _dlqService.retryItem(dlqItem);
      await _reload();
    } finally {
      _retryingItem = null;
      notifyListeners();
    }
  }

  Future<void> clearDlq() async {
    await _dlqService.clearDlq();
    _dlq = [];
    _totalCount = 0;
    _page = 0;
    notifyListeners();
  }
}