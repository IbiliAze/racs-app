import 'dart:ui';

import 'package:flutter/material.dart';

/// A modern, lightly-frosted glass surface with a hairline edge.
///
/// Flat tint, thin uniform border, soft shadow placed outside the clip so it
/// stays soft instead of being cut off. No gradients — just clean glass.
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(12),
    this.borderRadius = 22,
  });

  final Widget child;
  final EdgeInsets padding;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final radius = BorderRadius.circular(borderRadius);

    final fill = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.white.withValues(alpha: 0.40);

    final edge = isDark
        ? Colors.white.withValues(alpha: 0.14)
        : Colors.white.withValues(alpha: 0.55);

    return DecoratedBox(
      // Shadow lives outside the clip so it diffuses softly underneath.
      decoration: BoxDecoration(
        borderRadius: radius,
        // Layered shadow: a soft, wide ambient cast plus a tighter, darker
        // close shadow — gives a modern sense of depth instead of one flat blur.
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.40 : 0.14),
            blurRadius: 32,
            spreadRadius: -4,
            offset: const Offset(0, 18),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.24 : 0.08),
            blurRadius: 10,
            spreadRadius: -2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: fill,
              borderRadius: radius,
              border: Border.all(color: edge, width: 0.8),
            ),
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}