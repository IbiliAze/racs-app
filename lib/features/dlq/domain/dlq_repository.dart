import 'package:racs_reader/features/dlq/domain/dlq_item.dart';
import 'package:racs_reader/features/dlq/domain/dlq_params.dart';

abstract class DlqRepository {
  Future<void> insert(DlqItem dlqItem);
  Future<List<DlqItem>> getPaged(DlqParams params);
  Future<int> count();
  Future<void> clearAll();
  Future<void> clearItem(DlqItem dlqItem);
}
