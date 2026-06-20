import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:reader/core/storage/secure_storage.dart';
import 'package:reader/features/cards/application/card_service.dart';
import 'package:reader/features/cards/domain/card.dart';
import 'package:reader/features/cards/domain/card_params.dart';

@injectable
class CardsViewModel extends ChangeNotifier {
  static const pageSize = 30;

  final CardService _cardService;
  final SecureStorage _secureStorage;

  CardsViewModel(this._cardService, this._secureStorage);

  List<Card> _cards = [];
  bool _isLoading = false;
  String? _error;
  int _page = 0;
  int _totalCount = 0;
  String _ownerId = '';

  List<Card> get cards => _cards;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get page => _page;
  int get totalPages => (_totalCount / pageSize).ceil();
  bool get canGoPrevious => _page > 0;
  bool get canGoNext => _page < totalPages - 1;

  Future<void> loadCards() async {
    _page = 0;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final profile = await _secureStorage.getProfile();
      _ownerId = profile?['ownerId'] ?? '';
      _totalCount = await _cardService.countCards(_ownerId);
      _cards = await _cardService.getCards(
        CardParams(ownerId: _ownerId, page: _page, size: pageSize),
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
      _cards = await _cardService.getCards(
        CardParams(ownerId: _ownerId, page: page, size: pageSize),
      );
      _page = page;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }
}