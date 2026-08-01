import 'package:racs_reader/features/scanner/domain/scan_context.dart';
import 'package:racs_reader/features/scanner/domain/scan_exception.dart';
import 'package:racs_reader/features/scanner/domain/scan_flag.dart';
import 'package:racs_reader/features/scanner/domain/scan_step.dart';

class ParseStep extends ScanStep {
  ParseStep(super.logger);

  @override
  Future<ScanContext> execute(ScanContext context) async {
    await logger.debug(
      'Parsing raw value: "${context.rawValue}"',
      className: 'ParseStep',
    );
    final value = context.rawValue.trim();
    if (value.isEmpty) {
      await logger.warning('Parse failed: empty value', className: 'ParseStep');
      throw ScanException(
        'Invalid QR code',
        context,
        flag: ScanFlag.invalidFormat,
      );
    }
    await logger.info('Parse successful', className: 'ParseStep');
    return context;
  }
}
