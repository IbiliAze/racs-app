import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:reader/common/widgets/pagination_controls.dart';
import 'package:reader/features/cards/domain/card.dart' as card_domain;
import 'package:reader/features/cards/view_models/cards_view_model.dart';
import 'package:reader/injection.dart';

class CardsScreen extends StatefulWidget {
  const CardsScreen({super.key});

  @override
  State<CardsScreen> createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen> {
  late final CardsViewModel _viewModel;
  late final GoRouter _router;
  bool _listenerAdded = false;

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<CardsViewModel>();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_listenerAdded) {
      _router = GoRouter.of(context);
      _router.routerDelegate.addListener(_onNavigate);
      _listenerAdded = true;
      _viewModel.loadCards();
    }
  }

  void _onNavigate() {
    final location = _router.routeInformationProvider.value.uri.path;
    if (location == '/cards' && mounted) _viewModel.loadCards();
  }

  @override
  void dispose() {
    _router.routerDelegate.removeListener(_onNavigate);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cards')),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          if (_viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_viewModel.error != null) {
            return Center(child: Text(_viewModel.error!));
          }

          if (_viewModel.cards.isEmpty) {
            return const Center(child: Text('No cards found.'));
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
                  onNext: _viewModel.canGoNext
                      ? _viewModel.nextPage
                      : null,
                ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _viewModel.loadCards,
                  child: ListView.builder(
                    itemCount: _viewModel.cards.length,
                    itemBuilder: (context, index) {
                      return _CardTile(card: _viewModel.cards[index]);
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

class _CardTile extends StatelessWidget {
  final card_domain.Card card;

  const _CardTile({required this.card});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(card.label, style: theme.textTheme.titleMedium),
                ),
                _TypeChip(type: card.type),
                const SizedBox(width: 8),
                Icon(
                  card.invalidated ? Icons.block : Icons.check_circle,
                  color: card.invalidated ? Colors.red : Colors.green,
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(card.value, style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
            if (card.validFrom != null || card.validUntil != null) ...[
              const SizedBox(height: 8),
              _ValidityRow(validFrom: card.validFrom, validUntil: card.validUntil),
            ],
            if (card.metadata != null && card.metadata!.isNotEmpty) ...[
              const SizedBox(height: 8),
              _MetadataSection(metadata: card.metadata!),
            ],
          ],
        ),
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  final card_domain.CardType type;

  const _TypeChip({required this.type});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (type) {
      card_domain.CardType.voucher => ('Voucher', Colors.purple),
      card_domain.CardType.ticket => ('Ticket', Colors.blue),
      card_domain.CardType.membership => ('Member', Colors.teal),
      card_domain.CardType.pass => ('Pass', Colors.orange),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}

class _ValidityRow extends StatelessWidget {
  final DateTime? validFrom;
  final DateTime? validUntil;

  const _ValidityRow({this.validFrom, this.validUntil});

  String _fmt(DateTime dt) => '${dt.day}/${dt.month}/${dt.year}';

  @override
  Widget build(BuildContext context) {
    final parts = <String>[];
    if (validFrom != null) parts.add('From ${_fmt(validFrom!)}');
    if (validUntil != null) parts.add('Until ${_fmt(validUntil!)}');

    return Row(
      children: [
        const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
        const SizedBox(width: 4),
        Text(parts.join('  ·  '), style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}

class _MetadataSection extends StatelessWidget {
  final Map<String, dynamic> metadata;

  const _MetadataSection({required this.metadata});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: metadata.entries.map((e) {
        return Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Row(
            children: [
              Text('${e.key}: ', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey)),
              Expanded(child: Text('${e.value}', style: const TextStyle(fontSize: 12))),
            ],
          ),
        );
      }).toList(),
    );
  }
}