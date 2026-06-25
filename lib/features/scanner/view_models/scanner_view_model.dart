import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:reader/core/storage/secure_storage.dart';
import 'package:reader/features/tickets/application/ticket_service.dart';
import 'package:reader/features/tickets/domain/ticket.dart';
import 'package:reader/features/scanner/application/scanner_service.dart';
import 'package:reader/features/scanner/domain/scan_exception.dart';
import 'package:reader/features/settings/application/connection_notifier.dart';

enum ScanState { idle, scanning, success, failure }

@injectable
class ScannerViewModel extends ChangeNotifier {
  final ScannerService _scannerService;
  final TicketService _ticketService;
  final SecureStorage _secureStorage;
  final ConnectionNotifier _connectionNotifier;

  ScannerViewModel(
    this._scannerService,
    this._ticketService,
    this._secureStorage,
    this._connectionNotifier,
  ) {
    // Forward connection changes so the UI's status dot updates live.
    _connectionNotifier.addListener(notifyListeners);
  }

  ScanState _state = ScanState.idle;
  Ticket? _scannedTicket;
  String? _error;
  bool _isDownloading = false;

  ScanState get state => _state;
  Ticket? get scannedTicket => _scannedTicket;
  String? get error => _error;
  bool get isDownloading => _isDownloading;
  bool get isConnected => _connectionNotifier.isConnected;

  Future<void> onScan(String rawValue) async {
    _state = ScanState.scanning;
    _scannedTicket = null;
    _error = null;
    notifyListeners();

    try {
      final context = await _scannerService.scan(rawValue);
      _scannedTicket = context.ticket;
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
      await _ticketService.downloadTickets(profile?['eventId'] ?? '');
    } finally {
      _isDownloading = false;
      notifyListeners();
    }
  }

  void reset() {
    _state = ScanState.idle;
    _scannedTicket = null;
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _connectionNotifier.removeListener(notifyListeners);
    super.dispose();
  }
}
