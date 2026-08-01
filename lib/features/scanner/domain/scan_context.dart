import 'package:racs_reader/features/cards/domain/card.dart';

class ScanContext {
  final String rawValue;
  final Card? card;

  /// Set once the scan has been handed to the server (sent, or queued to the
  /// DLQ) by SubmitRemoteStep, so it is never submitted a second time.
  final bool submitted;

  const ScanContext({
    required this.rawValue,
    this.card,
    this.submitted = false,
  });

  ScanContext copyWith({Card? card, bool? submitted}) => ScanContext(
    rawValue: rawValue,
    card: card ?? this.card,
    submitted: submitted ?? this.submitted,
  );
}
