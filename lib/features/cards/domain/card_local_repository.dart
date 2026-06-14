import 'package:reader/features/cards/domain/card.dart';
import 'package:reader/features/cards/domain/card_params.dart';

abstract class CardLocalRepository {
  Future<Card?> getCardById(String id);
  Future<Card?> getCardByLabel(String label);
  Future<Card?> getCardByValue(String value);
  Future<List<Card>> getCards(CardParams params);
  Future<Card?> markUsed(String id);
  Future<void> upsert(Card card);
  Future<void> upsertAll(List<Card> cards);
}
