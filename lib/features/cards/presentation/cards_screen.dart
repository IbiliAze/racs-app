import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:reader/common/widgets/list_divider.dart';
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
                  child: ListView.separated(
                    itemCount: _viewModel.cards.length,
                    separatorBuilder: (_, _) => const ListDivider(),
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
    final color = card.invalidated ? Colors.red : Colors.green;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.15),
        child: Icon(
          card.invalidated ? Icons.block : Icons.check_circle,
          color: color,
          size: 20,
        ),
      ),
      title: Text(card.label, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        card.value,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
      trailing: _TypeChip(type: card.type),
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
