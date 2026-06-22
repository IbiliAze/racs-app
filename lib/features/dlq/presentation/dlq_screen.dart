import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:reader/common/widgets/list_divider.dart';
import 'package:reader/common/widgets/pagination_controls.dart';
import 'package:reader/features/dlq/domain/dlq_item.dart';
import 'package:reader/features/dlq/view_models/dlq_view_model.dart';
import 'package:reader/injection.dart';

class DlqScreen extends StatefulWidget {
  const DlqScreen({super.key});

  @override
  State<DlqScreen> createState() => _DlqScreenState();
}

class _DlqScreenState extends State<DlqScreen> {
  late final DlqViewModel _viewModel;
  late final GoRouter _router;
  bool _listenerAdded = false;

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<DlqViewModel>();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_listenerAdded) {
      _router = GoRouter.of(context);
      _router.routerDelegate.addListener(_onNavigate);
      _listenerAdded = true;
      _viewModel.loadDlq();
    }
  }

  void _onNavigate() {
    final location = _router.routeInformationProvider.value.uri.path;
    if (location == '/dlq' && mounted) _viewModel.loadDlq();
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
        content: const Text(
          'This will permanently remove all items from the queue.',
        ),
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
    if (confirmed == true) await _viewModel.clearDlq();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dead Letter Queue'),
        actions: [
          ListenableBuilder(
            listenable: _viewModel,
            builder: (context, _) => IconButton(
              icon: const Icon(Icons.delete_rounded),
              tooltip: 'Clear all',
              onPressed: _viewModel.dlq.isEmpty ? null : _confirmClearAll,
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

          if (_viewModel.dlq.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle_outline, size: 56, color: Colors.green),
                  SizedBox(height: 12),
                  Text('Queue is empty'),
                ],
              ),
            );
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
                  onRefresh: _viewModel.loadDlq,
                  child: ListView.separated(
                    itemCount: _viewModel.dlq.length,
                    separatorBuilder: (_, _) => const ListDivider(),
                    itemBuilder: (context, index) {
                      final item = _viewModel.dlq[index];
                      return _DlqTile(
                        item: item,
                        isRetrying: _viewModel.isRetrying(item),
                        onDismiss: () => _viewModel.removeDlqItem(item),
                        onRetry: () async {
                          try {
                            await _viewModel.retryItem(item);
                          } catch (_) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Retry failed')),
                              );
                            }
                          }
                        },
                      );
                    },
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

class _DlqTile extends StatelessWidget {
  final DlqItem item;
  final bool isRetrying;
  final VoidCallback onDismiss;
  final VoidCallback onRetry;

  const _DlqTile({
    required this.item,
    required this.isRetrying,
    required this.onDismiss,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(item.id ?? item.scannedValue),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete_rounded, color: Colors.white),
      ),
      onDismissed: (_) => onDismiss(),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Color(0x1FEF5350),
          child: Icon(Icons.error_outline, color: Colors.red, size: 20),
        ),
        title: Text(
          item.scannedValue,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          item.cardId != null ? 'Card: ${item.cardId}' : item.flag.serverValue,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (item.createdAt != null)
              Text(
                _formatTime(item.createdAt!),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            const SizedBox(width: 4),
            if (isRetrying)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              IconButton(
                icon: const Icon(Icons.replay, size: 20),
                tooltip: 'Retry',
                onPressed: onRetry,
              ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}