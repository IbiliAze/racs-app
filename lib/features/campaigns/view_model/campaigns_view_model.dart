import 'package:flutter/cupertino.dart';
import 'package:racs_reader/features/campaigns/application/campaign_service.dart';
import 'package:racs_reader/features/campaigns/domain/campaign.dart';
import 'package:racs_reader/features/campaigns/domain/campaign_params.dart';

class CampaignsViewModel extends ChangeNotifier {
  static const pageSize = 30;

  final CampaignService _campaignService;

  CampaignsViewModel(this._campaignService);

  List<Campaign> _campaigns = [];
  bool _isLoading = false;
  String? _error;
  int _page = 0;
  int _totalCount = 0;

  List<Campaign> get campaigns => _campaigns;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get page => _page;
  int get totalPages => (_totalCount / pageSize).ceil();
  bool get canGoPrevious => _page > 0;
  bool get canGoNext => _page < totalPages - 1;

  Future<void> loadCampaigns() async {
    _page = 0;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _totalCount = await _campaignService.countCampaigns();
      _campaigns = await _campaignService.getCampaigns(
        CampaignParams(page: _page, size: pageSize),
      );
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> nextPage() async {
    if (!canGoNext) return;
    await _loadPage(_page + 1);
  }

  Future<void> previousPage() async {
    if (!canGoPrevious) return;
    await _loadPage(_page - 1);
  }

  Future<void> _loadPage(int page) async {
    _isLoading = true;
    notifyListeners();

    try {
      _campaigns = await _campaignService.getCampaigns(
        CampaignParams(page: page, size: pageSize),
      );
      _page = page;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }
}
