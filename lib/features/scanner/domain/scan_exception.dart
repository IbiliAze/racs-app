import 'package:reader/features/scanner/domain/scan_context.dart';
import 'package:reader/features/scanner/domain/scan_flag.dart';

class ScanException implements Exception {
  final String reason;
  final ScanContext context;
  final ScanFlag flag;

  const ScanException(this.reason, this.context, {this.flag = ScanFlag.unknown});

  @override
  String toString() => reason;
}