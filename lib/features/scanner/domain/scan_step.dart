import 'package:racs_reader/features/logger/application/logger_service.dart';
import 'package:racs_reader/features/scanner/domain/scan_context.dart';

abstract class ScanStep {
  final LoggerService logger;

  const ScanStep(this.logger);

  Future<ScanContext> execute(ScanContext context);
}
