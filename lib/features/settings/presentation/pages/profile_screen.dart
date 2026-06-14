import 'package:flutter/material.dart';
import 'package:reader/features/settings/presentation/view_models/profile_view_model.dart';
import 'package:reader/injection.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final ProfileViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<ProfileViewModel>();
    _viewModel.loadProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          if (_viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final reader = _viewModel.reader;
          if (reader == null) {
            return const Center(child: Text('No profile data.'));
          }

          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const CircleAvatar(
                  radius: 36,
                  child: Icon(Icons.person, size: 36),
                ),
                const SizedBox(height: 24),
                _ProfileRow(label: 'Username', value: reader.username),
                _ProfileRow(label: 'Reader ID', value: reader.id),
                _ProfileRow(label: 'Location ID', value: reader.locationId),
                _ProfileRow(
                  label: 'Status',
                  value: reader.inactive ? 'Inactive' : 'Active',
                  valueColor: reader.inactive ? Colors.red : Colors.green,
                ),
                _ProfileRow(
                  label: 'Member since',
                  value: '${reader.createdAt.day}/${reader.createdAt.month}/${reader.createdAt.year}',
                ),
                const Spacer(),
                FilledButton.icon(
                  style: FilledButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: _viewModel.isLoggingOut ? null : _viewModel.logout,
                  icon: _viewModel.isLoggingOut
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.logout),
                  label: const Text('Logout'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _ProfileRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: valueColor),
            ),
          ),
        ],
      ),
    );
  }
}