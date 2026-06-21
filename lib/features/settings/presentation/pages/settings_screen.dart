import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:reader/features/settings/application/theme_settings.dart';
import 'package:reader/features/settings/presentation/view_models/settings_view_model.dart';
import 'package:reader/injection.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final SettingsViewModel _viewModel;
  late final TextEditingController _hostController;

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<SettingsViewModel>();
    _hostController = TextEditingController();
    _loadHost();
  }

  @override
  void dispose() {
    _hostController.dispose();
    super.dispose();
  }

  Future<void> _loadHost() async {
    await _viewModel.loadHost();
    final host = _viewModel.host;
    if (host == null) return;
    _hostController.text = host;
    await _viewModel.testConnections(host);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: 'Profile',
            onPressed: () => context.push('/settings/profile'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: ListenableBuilder(
          listenable: _viewModel,
          builder: (context, _) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _hostController,
                  decoration: const InputDecoration(
                    labelText: 'API Host',
                    hintText: '192.168.1.1',
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _viewModel.isTesting
                      ? null
                      : () => _viewModel.testConnections(_hostController.text.trim()),
                  child: _viewModel.isTesting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Test & Save'),
                ),
                const SizedBox(height: 32),
                _ConnectivityRow(label: 'HTTP', connected: _viewModel.isHttpConnected),
                _ConnectivityRow(label: 'WebSocket', connected: _viewModel.isWsConnected),
                _ConnectivityRow(label: 'STUN', connected: _viewModel.isStunConnected),
                const Divider(height: 32),
                Consumer<ThemeSettings>(
                  builder: (context, theme, _) => SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Dark mode'),
                    secondary: const Icon(Icons.dark_mode_outlined),
                    value: theme.isDarkMode,
                    onChanged: theme.toggleDarkMode,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ConnectivityRow extends StatelessWidget {
  final String label;
  final bool? connected;

  const _ConnectivityRow({required this.label, required this.connected});

  @override
  Widget build(BuildContext context) {
    final icon = switch (connected) {
      null => const Icon(Icons.circle_outlined, color: Colors.grey),
      true => const Icon(Icons.check_circle, color: Colors.green),
      false => const Icon(Icons.cancel, color: Colors.red),
    };

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          icon,
          const SizedBox(width: 12),
          Text(label, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}