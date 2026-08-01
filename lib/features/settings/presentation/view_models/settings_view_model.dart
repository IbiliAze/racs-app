import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:racs_reader/features/campaigns/application/campaign_service.dart';
import 'package:racs_reader/features/campaigns/domain/campaign.dart';
import 'package:racs_reader/features/campaigns/domain/campaign_params.dart';
import 'package:racs_reader/features/settings/application/connection_notifier.dart';
import 'package:racs_reader/features/settings/application/settings_service.dart';

@injectable
class SettingsViewModel extends ChangeNotifier {
  final SettingsService _settingsService;
  final CampaignService _campaignService;
  final ConnectionNotifier _connectionNotifier;

  SettingsViewModel(
    this._settingsService,
    this._campaignService,
    this._connectionNotifier,
  );

  String? _host;
  String? _campaignId;
  List<Campaign> _campaigns = [];
  bool _isLoadingCampaigns = false;
  String? _campaignsError;
  bool _isTesting = false;
  bool _isHttpConnected = false;
  bool _isWsConnected = false;
  bool _isStunConnected = false;

  String? get host => _host;
  String? get campaignId => _campaignId;
  List<Campaign> get campaigns => _campaigns;
  bool get isLoadingCampaigns => _isLoadingCampaigns;
  String? get campaignsError => _campaignsError;
  bool get isTesting => _isTesting;
  bool get isHttpConnected => _isHttpConnected;
  bool get isWsConnected => _isWsConnected;
  bool get isStunConnected => _isStunConnected;

  Future<void> loadHost() async {
    _host = await _settingsService.getHost();
    notifyListeners();
  }

  Future<void> loadCampaignId() async {
    _campaignId = await _settingsService.getCampaignId();
    notifyListeners();
  }

  // Same size=10000 workaround as cards to bypass the API's default page cap.
  Future<void> loadCampaigns() async {
    _isLoadingCampaigns = true;
    _campaignsError = null;
    notifyListeners();

    try {
      _campaigns = await _campaignService.getCampaigns(
        CampaignParams(page: 0, size: 10000),
      );
    } catch (e) {
      _campaignsError = e.toString();
    }

    _isLoadingCampaigns = false;
    notifyListeners();
  }

  Future<void> selectCampaign(String campaignId) async {
    _campaignId = campaignId;
    await _settingsService.saveCampaignId(campaignId);
    notifyListeners();
  }

  Future<void> testConnections(String host) async {
    _isTesting = true;
    notifyListeners();

    _host = host;
    await _settingsService.saveHost(host);

    await Future.wait([
      _settingsService.testHttp().then((v) {
        _isHttpConnected = v;
        notifyListeners();
      }),
      _settingsService.testWebSocket().then((v) {
        _isWsConnected = v;
        notifyListeners();
      }),
      _settingsService.testStun().then((v) {
        _isStunConnected = v;
        notifyListeners();
      }),
    ]);

    _isTesting = false;
    _connectionNotifier.setConnected(
      _isHttpConnected && _isWsConnected && _isStunConnected,
    );
    notifyListeners();
  }
}
