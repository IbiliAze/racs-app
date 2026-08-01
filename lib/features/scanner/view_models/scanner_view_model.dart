import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:racs_reader/features/cards/application/card_service.dart';
import 'package:racs_reader/features/cards/domain/card.dart';
import 'package:racs_reader/features/scanner/application/scanner_service.dart';
import 'package:racs_reader/features/scanner/domain/scan_exception.dart';
import 'package:racs_reader/features/settings/application/connection_notifier.dart';
import 'package:racs_reader/features/settings/application/settings_service.dart';

enum ScanState { idle, scanning, success, failure }

@injectable
class ScannerViewModel extends ChangeNotifier {
  final ScannerService _scannerService;
  final CardService _cardService;
  final SettingsService _settingsService;
  final ConnectionNotifier _connectionNotifier;

  ScannerViewModel(
    this._scannerService,
    this._cardService,
    this._settingsService,
    this._connectionNotifier,
  ) {
    // Forward connection changes so the UI's status dot updates live.
    _connectionNotifier.addListener(notifyListeners);
  }

  ScanState _state = ScanState.idle;
  Card? _scannedCard;
  String? _error;
  bool _isDownloading = false;

  ScanState get state => _state;
  Card? get scannedCard => _scannedCard;
  String? get error => _error;
  bool get isDownloading => _isDownloading;
  bool get isConnected => _connectionNotifier.isConnected;

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
      final campaignId = await _settingsService.getCampaignId();
      if (campaignId != null) {
        await _cardService.downloadCards(campaignId);
      }
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

  @override
  void dispose() {
    _connectionNotifier.removeListener(notifyListeners);
    super.dispose();
  }
}
