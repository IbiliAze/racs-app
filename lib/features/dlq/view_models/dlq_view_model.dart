import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:reader/features/dlq/application/dlq_service.dart';
import 'package:reader/features/dlq/domain/dlq_item.dart';

@injectable
class DlqViewModel extends ChangeNotifier {
  final DlqService _dlqService;

  DlqViewModel(this._dlqService);

  List<DlqItem> _dlq = [];
  bool _isLoading = false;
  bool _inserting = false;
  bool _removingItem = false;
  DlqItem? _retryingItem;

  List<DlqItem> get dlq => _dlq;
  bool get isLoading => _isLoading;
  bool get isInserting => _inserting;
  bool get isRemovingItem => _removingItem;
  bool isRetrying(DlqItem item) => _retryingItem == item;

  Future<void> loadDlq() async {
    _isLoading = true;
    notifyListeners();
    try {
      _dlq = await _dlqService.getDlq();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> insertDlqItem(DlqItem dlqItem) async {
    _inserting = true;
    notifyListeners();
    try {
      await _dlqService.insertItem(dlqItem);
      _dlq.add(dlqItem);
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
      _dlq.remove(dlqItem);
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
      _dlq.remove(dlqItem);
    } finally {
      _retryingItem = null;
      notifyListeners();
    }
  }

  Future<void> clearDlq() async {
    await _dlqService.clearDlq();
    _dlq = [];
    notifyListeners();
  }
}