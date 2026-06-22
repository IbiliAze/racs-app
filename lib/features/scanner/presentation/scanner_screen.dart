import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:reader/common/widgets/app_button.dart';
import 'package:reader/common/widgets/glass_card.dart';
import 'package:reader/features/cards/domain/card.dart' as card_domain;
import 'package:reader/features/scanner/view_models/scanner_view_model.dart';
import 'package:reader/injection.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  late final ScannerViewModel _viewModel;
  late final MobileScannerController _controller;
  late final AnimationController _lineController;

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<ScannerViewModel>();
    _controller = MobileScannerController(
      // Ask the camera for 720p frames.
      cameraResolution: const Size(1280, 720),
      detectionSpeed: DetectionSpeed.noDuplicates,
    );
    _lineController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _lineController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Free the camera when the app goes to the background and bring it back
    // when the app returns to the foreground.
    switch (state) {
      case AppLifecycleState.resumed:
        _controller.start();
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        _controller.stop();
    }
  }

  void _onDetect(BarcodeCapture capture) {
    // Only act on a fresh scan; ignore frames while showing a result.
    if (_viewModel.state != ScanState.idle) return;
    final value = capture.barcodes.firstOrNull?.rawValue;
    if (value == null || value.isEmpty) return;
    _viewModel.onScan(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final size = constraints.biggest;
          final boxSide = size.width * 0.7;
          final boxRect = Rect.fromCenter(
            center: Offset(size.width / 2, size.height / 2),
            width: boxSide,
            height: boxSide,
          );
          const radius = 24.0;

          // Frost follows the theme: a dark navy in dark mode, a light blue in
          // light mode. The top-bar text flips with it so it stays readable.
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final frostColor = isDark
              ? const Color(0xFF07111F).withValues(alpha: 0.6)
              : const Color(0xFFBFD7FF).withValues(alpha: 0.6);
          final barTextColor = isDark ? Colors.white : Colors.black87;

          return Stack(
            fit: StackFit.expand,
            children: [
              // 1. Full-screen camera. Detection is limited to scanWindow.
              MobileScanner(
                controller: _controller,
                scanWindow: boxRect,
                fit: BoxFit.cover,
                onDetect: _onDetect,
              ),

              // 2. Frost + dim everything outside the scan box.
              ClipPath(
                clipper: _CutoutClipper(boxRect, radius),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(color: frostColor),
                ),
              ),

              // 3. The scan box outline with the moving red line.
              Positioned.fromRect(
                rect: boxRect,
                child: _ScanBox(
                  radius: radius,
                  animation: _lineController,
                ),
              ),

              // 4. Glass card with the app name at the top.
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: ListenableBuilder(
                      listenable: _viewModel,
                      builder: (context, _) => _GlassBar(
                        title: 'RACS Reader',
                        textColor: barTextColor,
                        isConnected: _viewModel.isConnected,
                        controller: _controller,
                      ),
                    ),
                  ),
                ),
              ),

              // 5. The two action buttons at the bottom.
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: ListenableBuilder(
                      listenable: _viewModel,
                      builder: (context, _) => _BottomBar(
                        isDownloading: _viewModel.isDownloading,
                        onDownload: _viewModel.onDownload,
                        onMyScans: () => context.push('/scanner/scans'),
                      ),
                    ),
                  ),
                ),
              ),

              // 6. Result / failure / progress on top of the camera.
              ListenableBuilder(
                listenable: _viewModel,
                builder: (context, _) {
                  return switch (_viewModel.state) {
                    ScanState.idle => const SizedBox.shrink(),
                    ScanState.scanning => const _ScrimOverlay(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                    ScanState.success => _ScrimOverlay(
                      child: _ResultCard.success(
                        card: _viewModel.scannedCard!,
                        onDismiss: _viewModel.reset,
                      ),
                    ),
                    ScanState.failure => _ScrimOverlay(
                      child: _ResultCard.failure(
                        reason: _viewModel.error!,
                        onDismiss: _viewModel.reset,
                      ),
                    ),
                  };
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Clips to everything *outside* the rounded box, so a blur/dim layer placed
/// inside it frosts the surround and leaves the box clear.
class _CutoutClipper extends CustomClipper<Path> {
  final Rect box;
  final double radius;

  const _CutoutClipper(this.box, this.radius);

  @override
  Path getClip(Size size) {
    final full = Path()..addRect(Offset.zero & size);
    final hole = Path()
      ..addRRect(RRect.fromRectAndRadius(box, Radius.circular(radius)));
    return Path.combine(PathOperation.difference, full, hole);
  }

  @override
  bool shouldReclip(_CutoutClipper oldClipper) =>
      box != oldClipper.box || radius != oldClipper.radius;
}

/// The rounded outline plus a red line that sweeps up and down.
class _ScanBox extends StatelessWidget {
  final double radius;
  final Animation<double> animation;

  const _ScanBox({required this.radius, required this.animation});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: Colors.white.withValues(alpha: 0.8), width: 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: AnimatedBuilder(
          animation: animation,
          builder: (context, _) {
            return LayoutBuilder(
              builder: (context, constraints) {
                final y = animation.value * constraints.maxHeight;
                return Stack(
                  children: [
                    Positioned(
                      top: y - 1,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 2,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withValues(alpha: 0.6),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

/// Frosted glass bar showing the app name.
class _GlassBar extends StatelessWidget {
  final String title;
  final Color textColor;
  final bool isConnected;
  final MobileScannerController controller;

  const _GlassBar({
    required this.title,
    required this.textColor,
    required this.isConnected,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderRadius: 16,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          Icon(Icons.qr_code_scanner, color: textColor, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: textColor,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          _TorchButton(controller: controller, color: textColor),
          const SizedBox(width: 12),
          _StatusDot(isConnected: isConnected),
        ],
      ),
    );
  }
}

/// A small flash/torch toggle that reflects and controls the camera torch.
class _TorchButton extends StatelessWidget {
  final MobileScannerController controller;
  final Color color;

  const _TorchButton({required this.controller, required this.color});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<MobileScannerState>(
      valueListenable: controller,
      builder: (context, state, _) {
        final isOn = state.torchState == TorchState.on;
        return GestureDetector(
          onTap: () => controller.toggleTorch(),
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isOn ? Colors.white : color.withValues(alpha: 0.12),
            ),
            child: Icon(
              isOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
              size: 18,
              color: isOn ? const Color(0xFFE8A100) : color,
            ),
          ),
        );
      },
    );
  }
}

/// A connection indicator: a green dot that pulses when connected, or a steady
/// red dot when not.
class _StatusDot extends StatefulWidget {
  final bool isConnected;

  const _StatusDot({required this.isConnected});

  @override
  State<_StatusDot> createState() => _StatusDotState();
}

class _StatusDotState extends State<_StatusDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    if (widget.isConnected) _controller.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(_StatusDot oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Pulse only while connected; hold still otherwise.
    if (widget.isConnected && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.isConnected && _controller.isAnimating) {
      _controller.stop();
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isConnected ? Colors.green : Colors.red;

    if (!widget.isConnected) {
      return _Dot(color: color, glow: 0);
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => _Dot(color: color, glow: _controller.value),
    );
  }
}

class _Dot extends StatelessWidget {
  final Color color;
  final double glow;

  const _Dot({required this.color, required this.glow});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.7 * glow),
            blurRadius: 8 * glow,
            spreadRadius: 3 * glow,
          ),
        ],
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final bool isDownloading;
  final VoidCallback onDownload;
  final VoidCallback onMyScans;

  const _BottomBar({
    required this.isDownloading,
    required this.onDownload,
    required this.onMyScans,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: AppButton(
            onPressed: isDownloading ? null : onDownload,
            loading: isDownloading,
            icon: Icons.download,
            label: 'Download Scans',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: AppButton.tonal(
            onPressed: onMyScans,
            icon: Icons.history,
            label: 'My Scans',
          ),
        ),
      ],
    );
  }
}

/// Dims the camera and centers its child — used for progress and results.
class _ScrimOverlay extends StatelessWidget {
  final Widget child;

  const _ScrimOverlay({required this.child});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: ColoredBox(
        color: Colors.black.withValues(alpha: 0.7),
        child: Center(child: child),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String? subtitle;
  final VoidCallback onDismiss;

  const _ResultCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onDismiss,
  });

  factory _ResultCard.success({
    required card_domain.Card card,
    required VoidCallback onDismiss,
  }) {
    return _ResultCard(
      icon: Icons.check_circle,
      color: Colors.green,
      title: card.label,
      subtitle: card.value,
      onDismiss: onDismiss,
    );
  }

  factory _ResultCard.failure({
    required String reason,
    required VoidCallback onDismiss,
  }) {
    return _ResultCard(
      icon: Icons.cancel,
      color: Colors.red,
      title: reason,
      subtitle: null,
      onDismiss: onDismiss,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 88, color: color),
          const SizedBox(height: 20),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
            ),
          ],
          const SizedBox(height: 28),
          AppButton(
            onPressed: onDismiss,
            label: 'Scan Again',
            expand: false,
          ),
        ],
      ),
    );
  }
}