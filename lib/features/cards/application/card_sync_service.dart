import 'package:injectable/injectable.dart';
import 'package:reader/features/cards/domain/card_local_repository.dart';
import 'package:reader/features/cards/domain/card_params.dart';
import 'package:reader/features/cards/domain/card_repository.dart';
import 'package:reader/features/logger/application/logger_service.dart';

@lazySingleton
class CardSyncService {
  final CardRepository _remoteRepository;
  final CardLocalRepository _localRepository;
  final LoggerService _loggerService;

  CardSyncService(
      this._remoteRepository,
      this._localRepository,
      this._loggerService);

  Future<void> sync(String ownerId) async {
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