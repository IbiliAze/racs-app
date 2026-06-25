import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:reader/common/widgets/list_divider.dart';
import 'package:reader/common/widgets/pagination_controls.dart';
import 'package:reader/features/tickets/domain/ticket.dart' as ticket_domain;
import 'package:reader/features/tickets/view_models/tickets_view_model.dart';
import 'package:reader/injection.dart';

class TicketsScreen extends StatefulWidget {
  const TicketsScreen({super.key});

  @override
  State<TicketsScreen> createState() => _TicketsScreenState();
}

class _TicketsScreenState extends State<TicketsScreen> {
  late final TicketsViewModel _viewModel;
  late final GoRouter _router;
  bool _listenerAdded = false;

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<TicketsViewModel>();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_listenerAdded) {
      _router = GoRouter.of(context);
      _router.routerDelegate.addListener(_onNavigate);
      _listenerAdded = true;
      _viewModel.loadTickets();
    }
  }

  void _onNavigate() {
    final location = _router.routeInformationProvider.value.uri.path;
    if (location == '/tickets' && mounted) _viewModel.loadTickets();
  }

  @override
  void dispose() {
    _router.routerDelegate.removeListener(_onNavigate);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tickets')),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          if (_viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_viewModel.error != null) {
            return Center(child: Text(_viewModel.error!));
          }

          if (_viewModel.tickets.isEmpty) {
            return const Center(child: Text('No tickets found.'));
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
                  onRefresh: _viewModel.loadTickets,
                  child: ListView.separated(
                    itemCount: _viewModel.tickets.length,
                    separatorBuilder: (_, _) => const ListDivider(),
                    itemBuilder: (context, index) {
                      return _TicketTile(ticket: _viewModel.tickets[index]);
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

class _TicketTile extends StatelessWidget {
  final ticket_domain.Ticket ticket;

  const _TicketTile({required this.ticket});

  @override
  Widget build(BuildContext context) {
    final color = ticket.invalidated ? Colors.red : Colors.green;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.15),
        child: Icon(
          ticket.invalidated ? Icons.block : Icons.check_circle,
          color: color,
          size: 20,
        ),
      ),
      title: Text(ticket.label, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        ticket.value,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
      trailing: _TypeChip(type: ticket.type),
    );
  }
}

class _TypeChip extends StatelessWidget {
  final ticket_domain.TicketType type;

  const _TypeChip({required this.type});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (type) {
      ticket_domain.TicketType.voucher => ('Voucher', Colors.purple),
      ticket_domain.TicketType.ticket => ('Ticket', Colors.blue),
      ticket_domain.TicketType.membership => ('Member', Colors.teal),
      ticket_domain.TicketType.pass => ('Pass', Colors.orange),
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
