import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:reader/common/widgets/pagination_controls.dart';
import 'package:reader/features/logger/domain/log.dart';
import 'package:reader/features/logger/view_models/logs_view_model.dart';
import 'package:reader/injection.dart';

class LogsScreen extends StatefulWidget {
  const LogsScreen({super.key});

  @override
  State<LogsScreen> createState() => _LogsScreenState();
}

class _LogsScreenState extends State<LogsScreen> {
  late final LogsViewModel _viewModel;
  late final GoRouter _router;
  bool _listenerAdded = false;

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<LogsViewModel>();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_listenerAdded) {
      _router = GoRouter.of(context);
      _router.routerDelegate.addListener(_onNavigate);
      _listenerAdded = true;
      _viewModel.loadLogs();
    }
  }

  void _onNavigate() {
    final location = _router.routeInformationProvider.value.uri.path;
    if (location == '/logs' && mounted) _viewModel.loadLogs();
  }

  @override
  void dispose() {
    _router.routerDelegate.removeListener(_onNavigate);
    super.dispose();
  }

  Future<void> _confirmClearAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear all?'),
        content: const Text('This will permanently remove all logs.'),
        actions: [
          TextButton(
            onPressed: () => ctx.pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => ctx.pop(true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
    if (confirmed == true) await _viewModel.clearLogs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Logs'),
        actions: [
          ListenableBuilder(
            listenable: _viewModel,
            builder: (context, _) => IconButton(
              icon: const Icon(Icons.delete_sweep),
              tooltip: 'Clear all',
              onPressed: _viewModel.logs.isEmpty ? null : _confirmClearAll,
            ),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          if (_viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_viewModel.logs.isEmpty) {
            return const Center(child: Text('No logs yet.'));
          }

          return Column(
            children: [
              if (_viewModel.totalPages > 1)
                PaginationControls(
                  page: _viewModel.page,
                  totalPages: _viewModel.totalPages,
                  onPrevious: _viewModel.canGoPrevious
                      ? _viewModel.previousPage
                      : null,
                  onNext: _viewModel.canGoNext ? _viewModel.nextPage : null,
                ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: RefreshIndicator(
                    onRefresh: _viewModel.loadLogs,
                    child: ListView.builder(
                      itemCount: _viewModel.logs.length,
                      itemBuilder: (_, i) => _LogTile(log: _viewModel.logs[i]),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _viewModel.clearLogs,
        tooltip: 'Clear logs',
        child: const Icon(Icons.delete_sweep),
      ),
    );
  }
}

class _LogTile extends StatelessWidget {
  final Log log;

  const _LogTile({required this.log});

  @override
  Widget build(BuildContext context) {
    final (color, icon) = switch (log.level) {
      LogLevel.debug => (Colors.grey, Icons.bug_report),
      LogLevel.info => (Colors.blue, Icons.info),
      LogLevel.warning => (Colors.orange, Icons.warning),
      LogLevel.error => (Colors.red, Icons.error),
    };

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    log.className,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _fmt(log.timestamp),
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
              Text(log.message, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }

  String _fmt(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
}