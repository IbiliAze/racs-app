import 'package:reader/features/logger/application/logger_service.dart';
import 'package:reader/features/scanner/application/peer_sync_service.dart';
import 'package:reader/features/scanner/domain/scan_context.dart';
import 'package:reader/features/scanner/domain/scan_step.dart';

/// Tells the other readers that this ticket is now used, so they mark it used in
/// their own databases and it can't be presented at another gate. Runs only on
/// the success path — if an earlier step rejects the scan, the pipeline aborts
/// before reaching here.
class BroadcastStep extends ScanStep {
  final PeerSyncService _peerSyncService;

  BroadcastStep(this._peerSyncService, LoggerService logger) : super(logger);

  @override
  Future<ScanContext> execute(ScanContext context) async {
    final ticket = context.ticket!;
    await logger.info('Broadcasting ticket used to peers: ${ticket.id}', className: 'BroadcastStep');

    _peerSyncService.broadcastTicketUsed(ticket.id);
    return context;
  }
}