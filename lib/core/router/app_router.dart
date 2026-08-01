import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:racs_reader/common/widgets/app_shell.dart';
import 'package:racs_reader/features/auth/application/auth_notifier.dart';
import 'package:racs_reader/features/auth/presentation/pages/auth_screen.dart';
import 'package:racs_reader/features/cards/presentation/cards_screen.dart';
import 'package:racs_reader/features/dlq/presentation/dlq_screen.dart';
import 'package:racs_reader/features/logger/presentation/logs_screen.dart';
import 'package:racs_reader/features/scanner/presentation/scanner_screen.dart';
import 'package:racs_reader/features/scanner/presentation/scans_screen.dart';
import 'package:racs_reader/features/settings/application/connection_notifier.dart';
import 'package:racs_reader/features/settings/presentation/pages/profile_screen.dart';
import 'package:racs_reader/features/settings/presentation/pages/settings_screen.dart';
import 'package:racs_reader/injection.dart' show getIt;

final appRouter = GoRouter(
  initialLocation: '/auth',
  refreshListenable: Listenable.merge([
    getIt<AuthNotifier>(),
    getIt<ConnectionNotifier>(),
  ]),
  redirect: (context, state) {
    final isAuthenticated = getIt<AuthNotifier>().isAuthenticated;
    final isConnected = getIt<ConnectionNotifier>().isConnected;
    final location = state.matchedLocation;

    if (!isConnected && location != '/settings') return '/settings';
    if (isConnected && !isAuthenticated && location != '/auth') return '/auth';
    if (isConnected && isAuthenticated && location == '/auth') {
      return '/scanner';
    }
    return null;
  },
  routes: [
    GoRoute(path: '/auth', builder: (context, state) => const AuthScreen()),
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => AppShell(shell: shell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/scanner',
              builder: (context, state) => const ScannerScreen(),
              routes: [
                GoRoute(
                  path: 'scans',
                  builder: (context, state) => const ScansScreen(),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/logs',
              builder: (context, state) => const LogsScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/cards',
              builder: (context, state) => const CardsScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/dlq',
              builder: (context, state) => const DlqScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/settings',
              builder: (context, state) => const SettingsScreen(),
              routes: [
                GoRoute(
                  path: 'profile',
                  builder: (context, state) => const ProfileScreen(),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);
