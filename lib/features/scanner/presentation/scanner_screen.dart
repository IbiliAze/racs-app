import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:reader/features/cards/domain/card.dart' as card_domain;
import 'package:reader/features/scanner/view_models/scanner_view_model.dart';
import 'package:reader/injection.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  late final ScannerViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<ScannerViewModel>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          return switch (_viewModel.state) {
            ScanState.idle => _IdleView(
              onSimulate: () => _viewModel.onScan('CARD-M006'),
              onSync: _viewModel.onSync,
              isSyncing: _viewModel.isSyncing,
            ),
            ScanState.scanning => const Center(child: CircularProgressIndicator()),
            ScanState.success => _ResultView(
                card: _viewModel.scannedCard!,
                onReset: _viewModel.reset,
              ),
            ScanState.failure => _FailureView(
                reason: _viewModel.error!,
                onReset: _viewModel.reset,
              ),
          };
        },
      ),
    );
  }
}

class _IdleView extends StatelessWidget {
  final VoidCallback onSimulate;
  final VoidCallback onSync;
  final bool isSyncing;

  const _IdleView({required this.onSimulate, required this.onSync, required this.isSyncing});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.qr_code_scanner, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('Ready to scan'),
          const SizedBox(height: 24),
          FilledButton(onPressed: isSyncing ? null : onSimulate, child: const Text('Simulate Scan')),
          const SizedBox(height: 8),
          FilledButton.tonal(
            onPressed: isSyncing ? null : onSync,
            child: isSyncing
                ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Sync from remote'),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () => context.push('/scanner/scans'),
            icon: const Icon(Icons.history),
            label: const Text('Scans'),
          ),
        ],
      ),
    );
  }
}

class _ResultView extends StatelessWidget {
  final card_domain.Card card;
  final VoidCallback onReset;

  const _ResultView({required this.card, required this.onReset});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, size: 80, color: Colors.green),
            const SizedBox(height: 16),
            Text(card.label, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(card.value, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),
            FilledButton(onPressed: onReset, child: const Text('Scan Again')),
          ],
        ),
      ),
    );
  }
}

class _FailureView extends StatelessWidget {
  final String reason;
  final VoidCallback onReset;

  const _FailureView({required this.reason, required this.onReset});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cancel, size: 80, color: Colors.red),
            const SizedBox(height: 16),
            Text(reason, style: Theme.of(context).textTheme.titleMedium, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            FilledButton(onPressed: onReset, child: const Text('Try Again')),
          ],
        ),
      ),
    );
  }
}