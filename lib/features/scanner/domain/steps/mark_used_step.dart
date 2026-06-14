import 'package:reader/features/cards/domain/card_local_repository.dart';
import 'package:reader/features/logger/application/logger_service.dart';
import 'package:reader/features/scanner/domain/scan_context.dart';
import 'package:reader/features/scanner/domain/scan_exception.dart';
import 'package:reader/features/scanner/domain/scan_step.dart';

class MarkUsedStep extends ScanStep {
  final CardLocalRepository _localRepository;

  MarkUsedStep(this._localRepository, LoggerService logger) : super(logger);

  @override
  Future<ScanContext> execute(ScanContext context) async {
    final card = context.card!;
    await logger.info('Marking card as used locally: ${card.id}', className: 'MarkUsedStep');

    final updated = await _localRepository.markUsed(card.id);
    if (updated == null) {
      await logger.error('Failed to mark card as used: ${card.id}', className: 'MarkUsedStep');
      throw ScanException('Failed to mark card as used', context);
    }

    await logger.info('Card marked as used: ${card.id}', className: 'MarkUsedStep');
    return context.copyWith(card: updated);
  }
}