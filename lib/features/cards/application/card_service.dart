import 'package:injectable/injectable.dart';
import 'package:racs_reader/features/cards/domain/card.dart';
import 'package:racs_reader/features/cards/domain/card_local_repository.dart';
import 'package:racs_reader/features/cards/domain/card_params.dart';
import 'package:racs_reader/features/cards/domain/card_repository.dart';
import 'package:racs_reader/features/logger/application/logger_service.dart';

@lazySingleton
class CardService {
  final CardRepository _remoteRepository;
  final CardLocalRepository _localRepository;
  final LoggerService _loggerService;

  CardService(
    this._remoteRepository,
    this._localRepository,
    this._loggerService,
  );

  Future<Card?> getCardById(String id) => _localRepository.getCardById(id);
  Future<Card?> getCardByLabel(String label) =>
      _localRepository.getCardByLabel(label);
  Future<Card?> getCardByValue(String value) =>
      _localRepository.getCardByValue(value);
  Future<List<Card>> getCards(CardParams params) =>
      _localRepository.getCards(params);
  Future<int> countCards(String campaignId) =>
      _localRepository.countCards(campaignId);
  Future<void> upsert(Card card) => _localRepository.upsert(card);
  Future<void> upsertFromMap(Map<String, dynamic> map) =>
      _localRepository.upsertFromMap(map);
  Future<void> delete(String id) => _localRepository.delete(id);

  Future<void> downloadCards(String campaignId) async {
    try {
      _loggerService.debug("Syncing from remote", className: 'CardSyncService');
      _loggerService.debug(
        "Downloading cards for campaign $campaignId",
        className: 'CardSyncService',
      );
      final cards = await _remoteRepository.getCards(
        CardParams(campaignId: campaignId),
      );
      _loggerService.debug(
        "Inserting ${cards.length} cards from remote",
        className: 'CardSyncService',
      );
      await _localRepository.upsertAll(cards);
      _loggerService.info('Synced from remote', className: 'CardSyncService');
    } catch (e) {
      _loggerService.error(e.toString(), className: 'CardSyncService');
    }
  }
}
