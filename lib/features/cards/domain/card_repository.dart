import 'package:reader/features/cards/domain/card.dart';
import 'package:reader/features/cards/domain/card_params.dart';

abstract class CardRepository {
  Future<Card?> getCardById(String id);
  Future<Card?> getCardByLabel(String name);
  Future<Card?> getCardByValue(String value);
  Future<List<Card>> getCards(CardParams params);
  Future<Card?> markUsed(String id);
}