// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:racs_reader/core/network/http_client.dart' as _i627;
import 'package:racs_reader/core/network/webrtc_client.dart' as _i946;
import 'package:racs_reader/core/network/webrtc_mesh_client.dart' as _i773;
import 'package:racs_reader/core/network/websocket_client.dart' as _i867;
import 'package:racs_reader/core/storage/local_database.dart' as _i383;
import 'package:racs_reader/core/storage/secure_storage.dart' as _i570;
import 'package:racs_reader/core/storage/settings_storage.dart' as _i222;
import 'package:racs_reader/features/auth/application/auth_notifier.dart'
    as _i890;
import 'package:racs_reader/features/auth/application/auth_service.dart'
    as _i599;
import 'package:racs_reader/features/auth/data/auth_repository_impl.dart'
    as _i727;
import 'package:racs_reader/features/auth/domain/auth_repository.dart' as _i727;
import 'package:racs_reader/features/auth/presentation/view_models/auth_view_model.dart'
    as _i178;
import 'package:racs_reader/features/campaigns/application/campaign_service.dart'
    as _i915;
import 'package:racs_reader/features/campaigns/data/campaign_repository_impl.dart'
    as _i195;
import 'package:racs_reader/features/campaigns/domain/campaign_repository.dart'
    as _i28;
import 'package:racs_reader/features/cards/application/card_service.dart'
    as _i378;
import 'package:racs_reader/features/cards/data/card_local_repository_impl.dart'
    as _i701;
import 'package:racs_reader/features/cards/data/card_repository_impl.dart'
    as _i750;
import 'package:racs_reader/features/cards/domain/card_local_repository.dart'
    as _i303;
import 'package:racs_reader/features/cards/domain/card_repository.dart'
    as _i483;
import 'package:racs_reader/features/cards/view_models/cards_view_model.dart'
    as _i225;
import 'package:racs_reader/features/dlq/application/dlq_service.dart' as _i450;
import 'package:racs_reader/features/dlq/data/dlq_repository_impl.dart'
    as _i644;
import 'package:racs_reader/features/dlq/domain/dlq_repository.dart' as _i158;
import 'package:racs_reader/features/dlq/view_models/dlq_view_model.dart'
    as _i455;
import 'package:racs_reader/features/logger/application/logger_service.dart'
    as _i621;
import 'package:racs_reader/features/logger/data/log_repository_impl.dart'
    as _i108;
import 'package:racs_reader/features/logger/domain/log_repository.dart'
    as _i754;
import 'package:racs_reader/features/logger/view_models/logs_view_model.dart'
    as _i444;
import 'package:racs_reader/features/scanner/application/mesh_service.dart'
    as _i375;
import 'package:racs_reader/features/scanner/application/peer_sync_service.dart'
    as _i630;
import 'package:racs_reader/features/scanner/application/scanner_service.dart'
    as _i660;
import 'package:racs_reader/features/scanner/data/scan_local_repository_impl.dart'
    as _i704;
import 'package:racs_reader/features/scanner/data/scan_repository_impl.dart'
    as _i643;
import 'package:racs_reader/features/scanner/domain/scan_local_repository.dart'
    as _i1059;
import 'package:racs_reader/features/scanner/domain/scan_remote_repository.dart'
    as _i59;
import 'package:racs_reader/features/scanner/view_models/scanner_view_model.dart'
    as _i272;
import 'package:racs_reader/features/scanner/view_models/scans_view_model.dart'
    as _i564;
import 'package:racs_reader/features/settings/application/connection_notifier.dart'
    as _i1056;
import 'package:racs_reader/features/settings/application/settings_service.dart'
    as _i516;
import 'package:racs_reader/features/settings/data/settings_repository_impl.dart'
    as _i326;
import 'package:racs_reader/features/settings/domain/settings_repository.dart'
    as _i800;
import 'package:racs_reader/features/settings/presentation/view_models/profile_view_model.dart'
    as _i786;
import 'package:racs_reader/features/settings/presentation/view_models/settings_view_model.dart'
    as _i12;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    gh.lazySingleton<_i946.WebRtcClient>(() => _i946.WebRtcClient());
    gh.lazySingleton<_i773.WebRtcMeshClient>(() => _i773.WebRtcMeshClient());
    gh.lazySingleton<_i383.LocalDatabase>(() => _i383.LocalDatabase());
    gh.lazySingleton<_i570.SecureStorage>(() => _i570.SecureStorage());
    gh.lazySingleton<_i222.SettingsStorage>(() => _i222.SettingsStorage());
    gh.lazySingleton<_i890.AuthNotifier>(() => _i890.AuthNotifier());
    gh.lazySingleton<_i1056.ConnectionNotifier>(
      () => _i1056.ConnectionNotifier(),
    );
    gh.factory<_i1059.ScanLocalRepository>(
      () => _i704.ScanLocalRepositoryImpl(gh<_i383.LocalDatabase>()),
    );
    gh.factory<_i564.ScansViewModel>(
      () => _i564.ScansViewModel(gh<_i1059.ScanLocalRepository>()),
    );
    gh.factory<_i786.ProfileViewModel>(
      () => _i786.ProfileViewModel(
        gh<_i570.SecureStorage>(),
        gh<_i890.AuthNotifier>(),
      ),
    );
    gh.factory<_i754.LogRepository>(
      () => _i108.LogRepositoryImpl(gh<_i383.LocalDatabase>()),
    );
    gh.factory<_i158.DlqRepository>(
      () => _i644.DlqRepositoryImpl(gh<_i383.LocalDatabase>()),
    );
    gh.factory<_i303.CardLocalRepository>(
      () => _i701.CardLocalRepositoryImpl(gh<_i383.LocalDatabase>()),
    );
    gh.lazySingleton<_i627.HttpClient>(
      () => _i627.HttpClient(
        gh<_i222.SettingsStorage>(),
        gh<_i570.SecureStorage>(),
      ),
    );
    gh.lazySingleton<_i867.WebSocketClient>(
      () => _i867.WebSocketClient(
        gh<_i222.SettingsStorage>(),
        gh<_i570.SecureStorage>(),
      ),
    );
    gh.lazySingleton<_i621.LoggerService>(
      () => _i621.LoggerService(gh<_i754.LogRepository>()),
    );
    gh.factory<_i483.CardRepository>(
      () => _i750.CardRepositoryImpl(gh<_i627.HttpClient>()),
    );
    gh.factory<_i727.AuthRepository>(
      () => _i727.AuthRepositoryImpl(
        gh<_i627.HttpClient>(),
        gh<_i570.SecureStorage>(),
      ),
    );
    gh.factory<_i28.CampaignRepository>(
      () => _i195.CampaignRepositoryImpl(gh<_i627.HttpClient>()),
    );
    gh.factory<_i800.SettingsRepository>(
      () => _i326.SettingsRepositoryImpl(
        gh<_i222.SettingsStorage>(),
        gh<_i627.HttpClient>(),
        gh<_i867.WebSocketClient>(),
        gh<_i946.WebRtcClient>(),
      ),
    );
    gh.lazySingleton<_i630.PeerSyncService>(
      () => _i630.PeerSyncService(
        gh<_i773.WebRtcMeshClient>(),
        gh<_i303.CardLocalRepository>(),
        gh<_i621.LoggerService>(),
      ),
    );
    gh.lazySingleton<_i599.AuthService>(
      () => _i599.AuthService(gh<_i727.AuthRepository>()),
    );
    gh.factory<_i444.LogsViewModel>(
      () => _i444.LogsViewModel(gh<_i621.LoggerService>()),
    );
    gh.factory<_i59.ScanRemoteRepository>(
      () => _i643.ScanRepositoryImpl(
        gh<_i627.HttpClient>(),
        gh<_i570.SecureStorage>(),
      ),
    );
    gh.lazySingleton<_i378.CardService>(
      () => _i378.CardService(
        gh<_i483.CardRepository>(),
        gh<_i303.CardLocalRepository>(),
        gh<_i621.LoggerService>(),
      ),
    );
    gh.lazySingleton<_i516.SettingsService>(
      () => _i516.SettingsService(gh<_i800.SettingsRepository>()),
    );
    gh.lazySingleton<_i915.CampaignService>(
      () => _i915.CampaignService(
        gh<_i28.CampaignRepository>(),
        gh<_i621.LoggerService>(),
      ),
    );
    gh.lazySingleton<_i450.DlqService>(
      () => _i450.DlqService(
        gh<_i158.DlqRepository>(),
        gh<_i59.ScanRemoteRepository>(),
      ),
    );
    gh.factory<_i455.DlqViewModel>(
      () => _i455.DlqViewModel(gh<_i450.DlqService>()),
    );
    gh.lazySingleton<_i660.ScannerService>(
      () => _i660.ScannerService(
        gh<_i303.CardLocalRepository>(),
        gh<_i621.LoggerService>(),
        gh<_i450.DlqService>(),
        gh<_i630.PeerSyncService>(),
        gh<_i59.ScanRemoteRepository>(),
        gh<_i1059.ScanLocalRepository>(),
        gh<_i570.SecureStorage>(),
      ),
    );
    gh.factory<_i178.AuthViewModel>(
      () => _i178.AuthViewModel(
        gh<_i599.AuthService>(),
        gh<_i890.AuthNotifier>(),
      ),
    );
    gh.factory<_i225.CardsViewModel>(
      () => _i225.CardsViewModel(
        gh<_i378.CardService>(),
        gh<_i516.SettingsService>(),
      ),
    );
    gh.factory<_i272.ScannerViewModel>(
      () => _i272.ScannerViewModel(
        gh<_i660.ScannerService>(),
        gh<_i378.CardService>(),
        gh<_i516.SettingsService>(),
        gh<_i1056.ConnectionNotifier>(),
      ),
    );
    gh.factory<_i12.SettingsViewModel>(
      () => _i12.SettingsViewModel(
        gh<_i516.SettingsService>(),
        gh<_i915.CampaignService>(),
        gh<_i1056.ConnectionNotifier>(),
      ),
    );
    gh.lazySingleton<_i375.MeshService>(
      () => _i375.MeshService(
        gh<_i867.WebSocketClient>(),
        gh<_i773.WebRtcMeshClient>(),
        gh<_i570.SecureStorage>(),
        gh<_i222.SettingsStorage>(),
        gh<_i621.LoggerService>(),
        gh<_i378.CardService>(),
        gh<_i660.ScannerService>(),
      ),
    );
    return this;
  }
}
