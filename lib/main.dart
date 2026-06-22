import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:reader/features/settings/application/theme_settings.dart';
import 'package:reader/core/router/app_router.dart';
import 'package:reader/features/auth/application/auth_notifier.dart';
import 'package:reader/features/scanner/application/mesh_service.dart';
import 'package:reader/features/scanner/application/peer_sync_service.dart';
import 'package:reader/features/settings/application/connection_notifier.dart';
import 'package:reader/features/settings/application/settings_service.dart';
import 'injection.dart' show configureDependencies, getIt;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  getIt<PeerSyncService>().init();

  final http = await getIt<SettingsService>().testHttp();
  final ws = await getIt<SettingsService>().testWebSocket();
  final stun = await getIt<SettingsService>().testStun();
  final isConnected = http && ws && stun;

  if (isConnected) {
    getIt<ConnectionNotifier>().setConnected(true);

    try {
      getIt<AuthNotifier>().setAuthenticated(true);
      await getIt<MeshService>().connect();
    } catch (_) {
      getIt<AuthNotifier>().setAuthenticated(false);
    } finally {

    }
  }

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeSettings(settingsStorage: getIt()),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const Color _seedBlue = Color(0xFF4F8CFF);

  @override
  Widget build(BuildContext context) {
    final themeSettings = context.watch<ThemeSettings>();

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
      themeMode: themeSettings.themeMode,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _seedBlue,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF3F7FF),
      ).copyWith(
        textTheme: GoogleFonts.outfitTextTheme(ThemeData.light().textTheme),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _seedBlue,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF121212),
      ).copyWith(
        textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
      ),
    );
  }
}