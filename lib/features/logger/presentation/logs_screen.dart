import 'package:flutter/cupertino.dart';
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
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Clear all?'),
        content: const Text('This will permanently remove all logs.'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => ctx.pop(false),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
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
                child: RefreshIndicator(
                  onRefresh: _viewModel.loadLogs,
                  child: ListView.separated(
                    itemCount: _viewModel.logs.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (_, i) => _LogTile(log: _viewModel.logs[i]),
                  ),
                ),
              ),
            ],
          );
        },
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

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.15),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(log.message, maxLines: 2, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        log.className,
        style: TextStyle(fontSize: 12, color: color),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(
        _fmt(log.timestamp),
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }

  String _fmt(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
}