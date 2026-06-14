import 'package:injectable/injectable.dart';
import 'package:reader/features/dlq/domain/dlq_item.dart';
import 'package:reader/features/dlq/domain/dlq_repository.dart';
import 'package:reader/features/scanner/domain/scan_remote_repository.dart';

@lazySingleton
class DlqService {
  final DlqRepository _dlqRepository;
  final ScanRemoteRepository _scanRemoteRepository;

  DlqService(this._dlqRepository, this._scanRemoteRepository);

  Future<void> clearDlq() => _dlqRepository.clearAll();
  Future<List<DlqItem>> getDlq() => _dlqRepository.getAll();
  Future<void> insertItem(DlqItem dlqItem) => _dlqRepository.insert(dlqItem);
  Future<void> clearItem(DlqItem dlqItem) => _dlqRepository.clearItem(dlqItem);

  Future<void> retryItem(DlqItem dlqItem) async {
    await _scanRemoteRepository.submit(
      scannedValue: dlqItem.scannedValue,
      flag: dlqItem.flag,
      cardId: dlqItem.cardId,
    );
    await _dlqRepository.clearItem(dlqItem);
  }
}