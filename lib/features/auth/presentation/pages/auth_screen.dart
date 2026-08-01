import 'package:flutter/material.dart';
import 'package:racs_reader/common/widgets/app_button.dart';
import 'package:racs_reader/features/auth/presentation/view_models/auth_view_model.dart';
import 'package:racs_reader/features/settings/application/settings_service.dart';
import 'package:racs_reader/injection.dart' show getIt;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _hostController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  late final AuthViewModel _viewModel;
  late final SettingsService _settingsService;

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<AuthViewModel>();
    _viewModel.addListener(_onViewModelChanged);
    _settingsService = getIt<SettingsService>();
    _loadHost();
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    _hostController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadHost() async {
    final host = await _settingsService.getHost();
    if (host == null || !mounted) return;
    _hostController.text = host;
  }

  void _onViewModelChanged() {
    if (_viewModel.status == AuthStatus.error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_viewModel.error ?? 'Login failed')),
      );
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      await _settingsService.saveHost(_hostController.text.trim());
      await _viewModel.login(
        _usernameController.text.trim(),
        _passwordController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ListenableBuilder(
            listenable: _viewModel,
            builder: (context, _) {
              return Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Sign in',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: _hostController,
                      decoration: const InputDecoration(
                        labelText: 'API Host',
                        hintText: '192.168.1.1',
                      ),
                      textInputAction: TextInputAction.next,
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _usernameController,
                      decoration: const InputDecoration(labelText: 'Username'),
                      textInputAction: TextInputAction.next,
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(labelText: 'Password'),
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submit(),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 32),
                    AppButton(
                      onPressed: _viewModel.isLoading ? null : _submit,
                      loading: _viewModel.isLoading,
                      label: 'Sign in',
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
