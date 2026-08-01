/// Raised when submitting a scan to the remote server does not succeed.
///
/// Distinguishes between a definitive rejection by the server (4xx — e.g. a
/// duplicate scan, customer not allowed in) and a transient failure where the
/// server could not process the scan (5xx or unreachable), which should be
/// retried via the DLQ.
class ScanSubmitException implements Exception {
  final String message;

  /// HTTP status code returned by the server, or `null` if no response was
  /// received (e.g. the server was unreachable).
  final int? statusCode;

  const ScanSubmitException(this.message, {this.statusCode});

  /// 4xx — the server responded and definitively rejected the scan. The result
  /// is final, so it should be surfaced and the DLQ item (if any) removed.
  bool get isRejected =>
      statusCode != null && statusCode! >= 400 && statusCode! < 500;

  /// 5xx or no response — the server could not process the scan. The scan
  /// should be queued/kept in the DLQ and retried later.
  bool get isRetryable => !isRejected;

  @override
  String toString() => 'ScanSubmitException($statusCode): $message';
}
