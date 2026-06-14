import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:reader/core/storage/secure_storage.dart';
import 'package:reader/features/cards/application/card_service.dart';
import 'package:reader/features/cards/domain/card.dart';
import 'package:reader/features/cards/domain/card_params.dart';

@injectable
class CardsViewModel extends ChangeNotifier {
  final CardService _cardService;
  final SecureStorage _secureStorage;

  CardsViewModel(this._cardService, this._secureStorage);

  List<Card> _cards = [];
  bool _isLoading = false;
  String? _error;

  List<Card> get cards => _cards;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadCards() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final profile = await _secureStorage.getProfile();
      final ownerId = profile?['ownerId'] ?? '';
      _cards = await _cardService.getCards(
        CardParams(ownerId: ownerId),
      );
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }
}