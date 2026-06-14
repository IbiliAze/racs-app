import 'package:flutter/material.dart';
import 'package:reader/features/scanner/domain/scan_record.dart';
import 'package:reader/features/scanner/view_models/scans_view_model.dart';
import 'package:reader/injection.dart';

class ScansScreen extends StatefulWidget {
  const ScansScreen({super.key});

  @override
  State<ScansScreen> createState() => _ScansScreenState();
}

class _ScansScreenState extends State<ScansScreen> {
  late final ScansViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<ScansViewModel>();
    _viewModel.load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scans')),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          final scans = _viewModel.scans;
          if (scans.isEmpty) {
            return const Center(child: Text('No scans yet'));
          }
          return ListView.separated(
            itemCount: scans.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) => _ScanTile(scan: scans[i]),
          );
        },
      ),
    );
  }
}

class _ScanTile extends StatelessWidget {
  final ScanRecord scan;

  const _ScanTile({required this.scan});

  @override
  Widget build(BuildContext context) {
    final color = _flagColor(scan.flag);
    final label = scan.cardLabel ?? scan.scannedValue;
    final time = _formatTime(scan.createdAt);

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.15),
        child: Icon(Icons.qr_code, color: color, size: 20),
      ),
      title: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(_flagLabel(scan.flag), style: TextStyle(color: color, fontSize: 12)),
      trailing: Text(time, style: Theme.of(context).textTheme.bodySmall),
    );
  }

  Color _flagColor(String flag) => switch (flag) {
        'PASSED_OK' => Colors.green,
        'SIMILARITY_CHECK' => Colors.teal,
        'UNKNOWN_CARD' => Colors.orange,
        'DUPLICATE_ATTEMPT_MESH' || 'DUPLICATE_ATTEMPT_SERVER' => Colors.amber.shade700,
        'REJECTED' || 'INVALID_FORMAT' => Colors.red,
        _ => Colors.grey,
      };

  String _flagLabel(String flag) => flag
      .toLowerCase()
      .replaceAll('_', ' ')
      .replaceFirstMapped(RegExp(r'^\w'), (m) => m[0]!.toUpperCase());

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}