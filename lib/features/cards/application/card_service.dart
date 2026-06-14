import 'package:injectable/injectable.dart';
import 'package:reader/features/cards/domain/card.dart';
import 'package:reader/features/cards/domain/card_local_repository.dart';
import 'package:reader/features/cards/domain/card_params.dart';

@lazySingleton
class CardService {
  final CardLocalRepository _localRepository;

  CardService(this._localRepository);

  Future<Card?> getCardById(String id) => _localRepository.getCardById(id);
  Future<Card?> getCardByLabel(String label) => _localRepository.getCardByLabel(label);
  Future<Card?> getCardByValue(String value) => _localRepository.getCardByValue(value);
  Future<List<Card>> getCards(CardParams params) => _localRepository.getCards(params);
}