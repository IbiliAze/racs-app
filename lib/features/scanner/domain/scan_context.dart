import 'package:reader/features/cards/domain/card.dart';

class ScanContext {
  final String rawValue;
  final Card? card;

  const ScanContext({required this.rawValue, this.card});

  ScanContext copyWith({Card? card}) => ScanContext(
        rawValue: rawValue,
        card: card ?? this.card,
      );
}