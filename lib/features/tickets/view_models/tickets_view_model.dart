import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:reader/core/storage/secure_storage.dart';
import 'package:reader/features/tickets/application/ticket_service.dart';
import 'package:reader/features/tickets/domain/ticket.dart';
import 'package:reader/features/tickets/domain/ticket_params.dart';

@injectable
class TicketsViewModel extends ChangeNotifier {
  static const pageSize = 30;

  final TicketService _ticketService;
  final SecureStorage _secureStorage;

  TicketsViewModel(this._ticketService, this._secureStorage);

  List<Ticket> _tickets = [];
  bool _isLoading = false;
  String? _error;
  int _page = 0;
  int _totalCount = 0;
  String _eventId = '';

  List<Ticket> get tickets => _tickets;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get page => _page;
  int get totalPages => (_totalCount / pageSize).ceil();
  bool get canGoPrevious => _page > 0;
  bool get canGoNext => _page < totalPages - 1;

  Future<void> loadTickets() async {
    _page = 0;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final profile = await _secureStorage.getProfile();
      _eventId = profile?['eventId'] ?? '';
      _totalCount = await _ticketService.countTickets(_eventId);
      _tickets = await _ticketService.getTickets(
        TicketParams(eventId: _eventId, page: _page, size: pageSize),
      );
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
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
      _tickets = await _ticketService.getTickets(
        TicketParams(eventId: _eventId, page: page, size: pageSize),
      );
      _page = page;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }
}