import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:reader/core/storage/secure_storage.dart';
import 'package:reader/features/cards/application/card_service.dart';
import 'package:reader/features/cards/domain/card.dart';
import 'package:reader/features/scanner/application/scanner_service.dart';
import 'package:reader/features/scanner/domain/scan_exception.dart';

enum ScanState { idle, scanning, success, failure }

@injectable
class ScannerViewModel extends ChangeNotifier {
  final ScannerService _scannerService;
  final CardService _cardService;
  final SecureStorage _secureStorage;

  ScannerViewModel(this._scannerService, this._cardService, this._secureStorage);

  ScanState _state = ScanState.idle;
  Card? _scannedCard;
  String? _error;
  bool _isDownloading = false;

  ScanState get state => _state;
  Card? get scannedCard => _scannedCard;
  String? get error => _error;
  bool get isDownloading => _isDownloading;

  Future<void> onScan(String rawValue) async {
    _state = ScanState.scanning;
    _scannedCard = null;
    _error = null;
    notifyListeners();

    try {
      final context = await _scannerService.scan(rawValue);
      _scannedCard = context.card;
      _state = ScanState.success;
    } on ScanException catch (e) {
      _error = e.reason;
      _state = ScanState.failure;
    } catch (e) {
      _error = 'Unexpected error';
      _state = ScanState.failure;
    }

    notifyListeners();
  }

  Future<void> onDownload() async {
    _isDownloading = true;
    notifyListeners();

    try {
      final profile = await _secureStorage.getProfile();
      await _cardService.downloadCards(profile?['ownerId'] ?? '');
    } finally {
      _isDownloading = false;
      notifyListeners();
    }
  }

  void reset() {
    _state = ScanState.idle;
    _scannedCard = null;
    _error = null;
    notifyListeners();
  }
}