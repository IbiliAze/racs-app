import 'package:reader/features/dlq/domain/dlq_item.dart';

abstract class DlqRepository {
  Future<void> insert(DlqItem dlqItem);
  Future<List<DlqItem>> getAll();
  Future<void> clearAll();
  Future<void> clearItem(DlqItem dlqItem);
}