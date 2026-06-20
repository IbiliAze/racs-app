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
import 'package:reader/core/network/http_client.dart' as _i33;
import 'package:reader/core/network/webrtc_client.dart' as _i880;
import 'package:reader/core/network/webrtc_mesh_client.dart' as _i267;
import 'package:reader/core/network/websocket_client.dart' as _i461;
import 'package:reader/core/storage/local_database.dart' as _i297;
import 'package:reader/core/storage/secure_storage.dart' as _i136;
import 'package:reader/core/storage/settings_storage.dart' as _i126;
import 'package:reader/features/auth/application/auth_notifier.dart' as _i378;
import 'package:reader/features/auth/application/auth_service.dart' as _i42;
import 'package:reader/features/auth/data/auth_repository_impl.dart' as _i630;
import 'package:reader/features/auth/domain/auth_repository.dart' as _i555;
import 'package:reader/features/auth/presentation/view_models/auth_view_model.dart'
    as _i750;
import 'package:reader/features/cards/application/card_service.dart' as _i467;
import 'package:reader/features/cards/data/card_local_repository_impl.dart'
    as _i490;
import 'package:reader/features/cards/data/card_repository_impl.dart' as _i551;
import 'package:reader/features/cards/domain/card_local_repository.dart'
    as _i682;
import 'package:reader/features/cards/domain/card_repository.dart' as _i465;
import 'package:reader/features/cards/view_models/cards_view_model.dart'
    as _i253;
import 'package:reader/features/dlq/application/dlq_service.dart' as _i817;
import 'package:reader/features/dlq/data/dlq_repository_impl.dart' as _i686;
import 'package:reader/features/dlq/domain/dlq_repository.dart' as _i1016;
import 'package:reader/features/dlq/view_models/dlq_view_model.dart' as _i627;
import 'package:reader/features/logger/application/logger_service.dart'
    as _i108;
import 'package:reader/features/logger/data/log_repository_impl.dart' as _i220;
import 'package:reader/features/logger/domain/log_repository.dart' as _i829;
import 'package:reader/features/logger/view_models/logs_view_model.dart'
    as _i1015;
import 'package:reader/features/scanner/application/mesh_service.dart' as _i265;
import 'package:reader/features/scanner/application/peer_sync_service.dart'
    as _i449;
import 'package:reader/features/scanner/application/scanner_service.dart'
    as _i968;
import 'package:reader/features/scanner/data/scan_local_repository_impl.dart'
    as _i1018;
import 'package:reader/features/scanner/data/scan_repository_impl.dart'
    as _i360;
import 'package:reader/features/scanner/domain/scan_local_repository.dart'
    as _i741;
import 'package:reader/features/scanner/domain/scan_remote_repository.dart'
    as _i634;
import 'package:reader/features/scanner/view_models/scanner_view_model.dart'
    as _i610;
import 'package:reader/features/scanner/view_models/scans_view_model.dart'
    as _i685;
import 'package:reader/features/settings/application/connection_notifier.dart'
    as _i723;
import 'package:reader/features/settings/application/settings_service.dart'
    as _i565;
import 'package:reader/features/settings/data/settings_repository_impl.dart'
    as _i198;
import 'package:reader/features/settings/domain/settings_repository.dart'
    as _i617;
import 'package:reader/features/settings/presentation/view_models/profile_view_model.dart'
    as _i905;
import 'package:reader/features/settings/presentation/view_models/settings_view_model.dart'
    as _i75;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    gh.lazySingleton<_i880.WebRtcClient>(() => _i880.WebRtcClient());
    gh.lazySingleton<_i267.WebRtcMeshClient>(() => _i267.WebRtcMeshClient());
    gh.lazySingleton<_i297.LocalDatabase>(() => _i297.LocalDatabase());
    gh.lazySingleton<_i136.SecureStorage>(() => _i136.SecureStorage());
    gh.lazySingleton<_i126.SettingsStorage>(() => _i126.SettingsStorage());
    gh.lazySingleton<_i378.AuthNotifier>(() => _i378.AuthNotifier());
    gh.lazySingleton<_i723.ConnectionNotifier>(
      () => _i723.ConnectionNotifier(),
    );
    gh.factory<_i741.ScanLocalRepository>(
      () => _i1018.ScanLocalRepositoryImpl(gh<_i297.LocalDatabase>()),
    );
    gh.factory<_i1016.DlqRepository>(
      () => _i686.DlqRepositoryImpl(gh<_i297.LocalDatabase>()),
    );
    gh.factory<_i682.CardLocalRepository>(
      () => _i490.CardLocalRepositoryImpl(gh<_i297.LocalDatabase>()),
    );
    gh.factory<_i829.LogRepository>(
      () => _i220.LogRepositoryImpl(gh<_i297.LocalDatabase>()),
    );
    gh.lazySingleton<_i33.HttpClient>(
      () => _i33.HttpClient(
        gh<_i126.SettingsStorage>(),
        gh<_i136.SecureStorage>(),
      ),
    );
    gh.lazySingleton<_i461.WebSocketClient>(
      () => _i461.WebSocketClient(
        gh<_i126.SettingsStorage>(),
        gh<_i136.SecureStorage>(),
      ),
    );
    gh.factory<_i685.ScansViewModel>(
      () => _i685.ScansViewModel(gh<_i741.ScanLocalRepository>()),
    );
    gh.factory<_i555.AuthRepository>(
      () => _i630.AuthRepositoryImpl(
        gh<_i33.HttpClient>(),
        gh<_i136.SecureStorage>(),
      ),
    );
    gh.factory<_i905.ProfileViewModel>(
      () => _i905.ProfileViewModel(
        gh<_i136.SecureStorage>(),
        gh<_i378.AuthNotifier>(),
      ),
    );
    gh.factory<_i634.ScanRemoteRepository>(
      () => _i360.ScanRepositoryImpl(
        gh<_i33.HttpClient>(),
        gh<_i136.SecureStorage>(),
      ),
    );
    gh.lazySingleton<_i108.LoggerService>(
      () => _i108.LoggerService(gh<_i829.LogRepository>()),
    );
    gh.lazySingleton<_i817.DlqService>(
      () => _i817.DlqService(
        gh<_i1016.DlqRepository>(),
        gh<_i634.ScanRemoteRepository>(),
      ),
    );
    gh.lazySingleton<_i449.PeerSyncService>(
      () => _i449.PeerSyncService(
        gh<_i267.WebRtcMeshClient>(),
        gh<_i682.CardLocalRepository>(),
        gh<_i108.LoggerService>(),
      ),
    );
    gh.lazySingleton<_i42.AuthService>(
      () => _i42.AuthService(gh<_i555.AuthRepository>()),
    );
    gh.factory<_i465.CardRepository>(
      () => _i551.CardRepositoryImpl(gh<_i33.HttpClient>()),
    );
    gh.lazySingleton<_i968.ScannerService>(
      () => _i968.ScannerService(
        gh<_i682.CardLocalRepository>(),
        gh<_i108.LoggerService>(),
        gh<_i817.DlqService>(),
        gh<_i449.PeerSyncService>(),
        gh<_i634.ScanRemoteRepository>(),
        gh<_i741.ScanLocalRepository>(),
        gh<_i136.SecureStorage>(),
      ),
    );
    gh.factory<_i1015.LogsViewModel>(
      () => _i1015.LogsViewModel(gh<_i108.LoggerService>()),
    );
    gh.factory<_i627.DlqViewModel>(
      () => _i627.DlqViewModel(gh<_i817.DlqService>()),
    );
    gh.factory<_i617.SettingsRepository>(
      () => _i198.SettingsRepositoryImpl(
        gh<_i126.SettingsStorage>(),
        gh<_i33.HttpClient>(),
        gh<_i461.WebSocketClient>(),
        gh<_i880.WebRtcClient>(),
      ),
    );
    gh.lazySingleton<_i467.CardService>(
      () => _i467.CardService(
        gh<_i465.CardRepository>(),
        gh<_i682.CardLocalRepository>(),
        gh<_i108.LoggerService>(),
      ),
    );
    gh.lazySingleton<_i565.SettingsService>(
      () => _i565.SettingsService(gh<_i617.SettingsRepository>()),
    );
    gh.factory<_i610.ScannerViewModel>(
      () => _i610.ScannerViewModel(
        gh<_i968.ScannerService>(),
        gh<_i467.CardService>(),
        gh<_i136.SecureStorage>(),
      ),
    );
    gh.factory<_i750.AuthViewModel>(
      () =>
          _i750.AuthViewModel(gh<_i42.AuthService>(), gh<_i378.AuthNotifier>()),
    );
    gh.factory<_i75.SettingsViewModel>(
      () => _i75.SettingsViewModel(
        gh<_i565.SettingsService>(),
        gh<_i723.ConnectionNotifier>(),
      ),
    );
    gh.factory<_i253.CardsViewModel>(
      () => _i253.CardsViewModel(
        gh<_i467.CardService>(),
        gh<_i136.SecureStorage>(),
      ),
    );
    gh.lazySingleton<_i265.MeshService>(
      () => _i265.MeshService(
        gh<_i461.WebSocketClient>(),
        gh<_i267.WebRtcMeshClient>(),
        gh<_i136.SecureStorage>(),
        gh<_i108.LoggerService>(),
        gh<_i467.CardService>(),
        gh<_i968.ScannerService>(),
      ),
    );
    return this;
  }
}
