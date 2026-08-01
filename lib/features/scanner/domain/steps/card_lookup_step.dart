import 'package:racs_reader/features/cards/domain/card_local_repository.dart';
import 'package:racs_reader/features/logger/application/logger_service.dart';
import 'package:racs_reader/features/scanner/domain/scan_context.dart';
import 'package:racs_reader/features/scanner/domain/scan_exception.dart';
import 'package:racs_reader/features/scanner/domain/scan_flag.dart';
import 'package:racs_reader/features/scanner/domain/scan_step.dart';

class CardLookupStep extends ScanStep {
  final CardLocalRepository _localRepository;

  CardLookupStep(this._localRepository, LoggerService logger) : super(logger);

  @override
  Future<ScanContext> execute(ScanContext context) async {
    await logger.debug(
      'Looking up card with value: "${context.rawValue}"',
      className: 'CardLookupStep',
    );
    final card = await _localRepository.getCardByValue(context.rawValue);
    if (card == null) {
      await logger.warning(
        'Card not found for value: "${context.rawValue}"',
        className: 'CardLookupStep',
      );
      throw ScanException(
        'Card not found',
        context,
        flag: ScanFlag.unknownCard,
      );
    }
    await logger.info('Card found: ${card.id}', className: 'CardLookupStep');
    return context.copyWith(card: card);
  }
}
