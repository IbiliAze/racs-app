import 'package:flutter/material.dart';

/// A subtle, centered separator for list views — a thin hairline spanning
/// 70% of the width rather than edge-to-edge.
class ListDivider extends StatelessWidget {
  const ListDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FractionallySizedBox(
        widthFactor: 0.7,
        child: Divider(
          height: 1,
          thickness: 0.5,
          color: Theme.of(
            context,
          ).colorScheme.onSurface.withValues(alpha: 0.10),
        ),
      ),
    );
  }
}
