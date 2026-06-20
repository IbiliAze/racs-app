import 'package:injectable/injectable.dart';
import 'package:reader/features/cards/domain/card.dart';
import 'package:reader/features/cards/domain/card_local_repository.dart';
import 'package:reader/features/cards/domain/card_params.dart';
import 'package:reader/features/cards/domain/card_repository.dart';
import 'package:reader/features/logger/application/logger_service.dart';

@lazySingleton
class CardService {
  final CardRepository _remoteRepository;
  final CardLocalRepository _localRepository;
  final LoggerService _loggerService;

  CardService(
      this._remoteRepository,
      this._localRepository,
      this._loggerService);

  Future<Card?> getCardById(String id) => _localRepository.getCardById(id);
  Future<Card?> getCardByLabel(String label) => _localRepository.getCardByLabel(label);
  Future<Card?> getCardByValue(String value) => _localRepository.getCardByValue(value);
  Future<List<Card>> getCards(CardParams params) => _localRepository.getCards(params);
  Future<int> countCards(String ownerId) => _localRepository.countCards(ownerId);
  Future<void> upsert(Card card) => _localRepository.upsert(card);
  Future<void> upsertFromMap(Map<String, dynamic> map) => _localRepository.upsertFromMap(map);
  Future<void> delete(String id) => _localRepository.delete(id);

  Future<void> downloadCards(String ownerId) async {
    try {
      _loggerService.debug("Syncing from remote", className: 'CardSyncService');
      final cards = await _remoteRepository.getCards(CardParams(ownerId: ownerId));
      _loggerService.debug("Inserting ${cards.length} cards from remote", className: 'CardSyncService');
      await _localRepository.upsertAll(cards);
      _loggerService.info('Synced from remote', className: 'CardSyncService');
    } catch (e) {
      _loggerService.error(e.toString(), className: 'CardSyncService');
    }
  }
}