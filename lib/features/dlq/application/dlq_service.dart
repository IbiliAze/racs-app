import 'package:injectable/injectable.dart';
import 'package:racs_reader/features/dlq/domain/dlq_item.dart';
import 'package:racs_reader/features/dlq/domain/dlq_params.dart';
import 'package:racs_reader/features/dlq/domain/dlq_repository.dart';
import 'package:racs_reader/features/scanner/domain/scan_remote_repository.dart';
import 'package:racs_reader/features/scanner/domain/scan_submit_exception.dart';

@lazySingleton
class DlqService {
  final DlqRepository _dlqRepository;
  final ScanRemoteRepository _scanRemoteRepository;

  DlqService(this._dlqRepository, this._scanRemoteRepository);

  Future<void> clearDlq() => _dlqRepository.clearAll();
  Future<List<DlqItem>> getDlq(DlqParams params) =>
      _dlqRepository.getPaged(params);
  Future<int> countDlq() => _dlqRepository.count();
  Future<void> insertItem(DlqItem dlqItem) => _dlqRepository.insert(dlqItem);
  Future<void> clearItem(DlqItem dlqItem) => _dlqRepository.clearItem(dlqItem);

  Future<void> retryItem(DlqItem dlqItem) async {
    try {
      await _scanRemoteRepository.submit(
        scannedValue: dlqItem.scannedValue,
        flag: dlqItem.flag,
        cardId: dlqItem.cardId,
      );
    } on ScanSubmitException catch (e) {
      // 5xx / unreachable — keep the item and retry later. A 4xx is a
      // definitive answer, so fall through and remove it.
      if (e.isRetryable) rethrow;
    }
    // Reached on 2xx (success) or 4xx (definitive rejection): remove the item.
    await _dlqRepository.clearItem(dlqItem);
  }
}
