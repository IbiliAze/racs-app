import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:racs_reader/common/widgets/glass_card.dart';

class AppShell extends StatelessWidget {
  final StatefulNavigationShell shell;

  const AppShell({required this.shell, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      extendBody: true,
      body: shell,
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(16, 0, 16, bottomPadding + 12),
        child: GlassCard(
          borderRadius: 28,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: GNav(
            selectedIndex: shell.currentIndex,
            gap: 8,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.85),
            activeColor: theme.colorScheme.onSurface,
            tabBackgroundColor: theme.colorScheme.onSurface.withValues(
              alpha: 0.10,
            ),
            tabBorderRadius: 22,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            duration: const Duration(milliseconds: 250),
            onTabChange: (index) => shell.goBranch(
              index,
              initialLocation: index == shell.currentIndex,
            ),
            tabs: const [
              GButton(icon: Icons.qr_code_rounded, text: 'Scanner'),
              GButton(icon: Icons.list_rounded, text: 'Logs'),
              GButton(icon: Icons.receipt_long_rounded, text: 'Cards'),
              GButton(icon: Icons.sync_problem_rounded, text: 'DLQ'),
              GButton(icon: Icons.settings_rounded, text: 'Settings'),
            ],
          ),
        ),
      ),
    );
  }
}
