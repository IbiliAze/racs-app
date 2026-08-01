import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Visual style for [AppButton].
enum AppButtonStyle {
  /// Solid accent fill with white text — the primary call to action.
  filled,

  /// Soft tinted fill with accent text — a quieter secondary action.
  tonal,

  /// Solid red fill — destructive actions like delete or logout.
  destructive,
}

/// A native iOS-style button: flat (no elevation or ripple), rounded, with a
/// gentle press fade + scale instead of a Material splash.
///
/// Defaults to full width; pass `expand: false` for a content-sized button.
class AppButton extends StatefulWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.style = AppButtonStyle.filled,
    this.loading = false,
    this.expand = true,
  });

  /// A soft tinted secondary action.
  const AppButton.tonal({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.loading = false,
    this.expand = true,
  }) : style = AppButtonStyle.tonal;

  /// A destructive (red) action.
  const AppButton.destructive({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.loading = false,
    this.expand = true,
  }) : style = AppButtonStyle.destructive;

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final AppButtonStyle style;
  final bool loading;
  final bool expand;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _pressed = false;

  bool get _enabled => widget.onPressed != null && !widget.loading;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final (Color background, Color foreground) = switch (widget.style) {
      AppButtonStyle.filled => (scheme.primary, scheme.onPrimary),
      AppButtonStyle.destructive => (CupertinoColors.systemRed, Colors.white),
      AppButtonStyle.tonal => (
        scheme.primary.withValues(alpha: isDark ? 0.22 : 0.12),
        scheme.primary,
      ),
    };

    final content = widget.loading
        ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(strokeWidth: 2, color: foreground),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, size: 20, color: foreground),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  widget.label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: foreground,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ],
          );

    return Semantics(
      button: true,
      enabled: _enabled,
      label: widget.label,
      child: GestureDetector(
        onTapDown: _enabled ? (_) => _setPressed(true) : null,
        onTapUp: _enabled ? (_) => _setPressed(false) : null,
        onTapCancel: _enabled ? () => _setPressed(false) : null,
        onTap: _enabled ? widget.onPressed : null,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 120),
          opacity: _enabled ? (_pressed ? 0.6 : 1) : 0.4,
          child: AnimatedScale(
            scale: _pressed ? 0.97 : 1,
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeOut,
            child: Container(
              width: widget.expand ? double.infinity : null,
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: background,
                borderRadius: BorderRadius.circular(14),
              ),
              child: content,
            ),
          ),
        ),
      ),
    );
  }
}
