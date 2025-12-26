import 'package:flutter/material.dart';
import 'package:flutter_bloc_app_template/generated/l10n.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app_template/bloc/settings/settings_bloc.dart';
import 'package:flutter_bloc_app_template/bloc/settings/settings_event.dart';
import 'package:flutter_bloc_app_template/bloc/settings/settings_states.dart';
import 'package:flutter_bloc_app_template/models/app_settings.dart';

class BluetoothSettingsPage extends StatefulWidget {
  static const routeName = '/bluetoothSettings';

  const BluetoothSettingsPage({super.key});

  @override
  State<BluetoothSettingsPage> createState() => _BluetoothSettingsPageState();
}

class _BluetoothSettingsPageState extends State<BluetoothSettingsPage> {
  @override
  void initState() {
    super.initState();
    context.read<SettingsBloc>().add(LoadSettings());
  }

  void _updateSettings(BuildContext context, AppSettings updatedSettings) {
    final bloc = context.read<SettingsBloc>();
    bloc.add(UpdateSettings(updatedSettings));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(S.of(context).bluetoothSettingsUpdated),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        if (state is! SettingsLoaded) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final settings = state.settings;

        return Scaffold(
          appBar: AppBar(
            title: Text(S.of(context).bluetoothSettings),
            centerTitle: true,
            elevation: 0,
            backgroundColor: Theme.of(context).colorScheme.surface,
            foregroundColor: Theme.of(context).colorScheme.onSurface,
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildInfoCard(context),
              const SizedBox(height: 24),
              _buildSectionTitle(context, S.of(context).connection),
              _buildSliderTile(
                context: context,
                title: S.of(context).scanDuration,
                subtitle: S.of(context).scanDurationDescription,
                currentValue: settings.bluetoothScanTimeout.toDouble(),
                min: 10,
                max: 30,
                divisions: 4,
                unit: S.of(context).seconds,
                onChanged: (value) {
                  final updated = settings.copyWith(
                    bluetoothScanTimeout: value.toInt(),
                  );
                  _updateSettings(context, updated);
                },
              ),
              _buildSliderTile(
                context: context,
                title: S.of(context).connectionDelay,
                subtitle: S.of(context).connectionDelayDescription,
                currentValue: settings.bluetoothConnectionTimeout.toDouble(),
                min: 15,
                max: 60,
                divisions: 9,
                unit: S.of(context).seconds,
                onChanged: (value) {
                  final updated = settings.copyWith(
                    bluetoothConnectionTimeout: value.toInt(),
                  );
                  _updateSettings(context, updated);
                },
              ),
              _buildSliderTile(
                context: context,
                title: S.of(context).reconnectionAttempts,
                subtitle: S.of(context).reconnectionAttemptsDescription,
                currentValue: settings.bluetoothMaxRetries.toDouble(),
                min: 3,
                max: 10,
                divisions: 7,
                unit: S.of(context).attempts,
                onChanged: (value) {
                  final updated = settings.copyWith(
                    bluetoothMaxRetries: value.toInt(),
                  );
                  _updateSettings(context, updated);
                },
              ),
              const SizedBox(height: 24),
              _buildSectionTitle(context, S.of(context).dataRecording),
              _buildSliderTile(
                context: context,
                title: S.of(context).batteryRssiFrequency,
                subtitle: S.of(context).batteryRssiFrequencyDescription,
                currentValue: settings.dataRecordInterval.toDouble(),
                min: 1,
                max: 10,
                divisions: 9,
                unit: S.of(context).minutes,
                onChanged: (value) {
                  final updated = settings.copyWith(
                    dataRecordInterval: value.toInt(),
                  );
                  _updateSettings(context, updated);
                },
              ),
              _buildSliderTile(
                context: context,
                title: S.of(context).movementFrequency,
                subtitle: S.of(context).movementFrequencyDescription,
                currentValue: settings.movementRecordInterval.toDouble(),
                min: 10,
                max: 120,
                divisions: 11,
                unit: S.of(context).seconds,
                onChanged: (value) {
                  final updated = settings.copyWith(
                    movementRecordInterval: value.toInt(),
                  );
                  _updateSettings(context, updated);
                },
              ),
              const SizedBox(height: 24),
              _buildPresetSection(context, settings),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.bluetooth_outlined,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
              size: 32,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                S.of(context).adjustBluetoothSettings,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildSliderTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required double currentValue,
    required double min,
    required double max,
    required int divisions,
    required String unit,
    required ValueChanged<double> onChanged,
  }) {
    var theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.6),
                            ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: theme.colorScheme.outline.withValues(alpha: 0.3),
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "${currentValue.toInt()} $unit",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            Slider(
              value: currentValue,
              min: min,
              max: max,
              divisions: divisions,
              label: "${currentValue.toInt()} $unit",
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPresetSection(BuildContext context, AppSettings settings) {
    var theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, S.of(context).presetProfiles),
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.3),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            children: [
              _buildPresetTile(
                context,
                S.of(context).powerSaving,
                S.of(context).powerSavingDescription,
                Icons.battery_saver,
                () => _applyPreset(
                  context,
                  settings.copyWith(
                    bluetoothScanTimeout: 10,
                    bluetoothConnectionTimeout: 20,
                    bluetoothMaxRetries: 3,
                    dataRecordInterval: 5,
                    movementRecordInterval: 60,
                  ),
                ),
              ),
              const Divider(height: 1),
              _buildPresetTile(
                context,
                S.of(context).balancedProfile,
                S.of(context).balancedProfileDescription,
                Icons.balance,
                () => _applyPreset(
                  context,
                  settings.copyWith(
                    bluetoothScanTimeout: 15,
                    bluetoothConnectionTimeout: 30,
                    bluetoothMaxRetries: 5,
                    dataRecordInterval: 2,
                    movementRecordInterval: 30,
                  ),
                ),
              ),
              const Divider(height: 1),
              _buildPresetTile(
                context,
                S.of(context).performanceProfile,
                S.of(context).performanceProfileDescription,
                Icons.speed,
                () => _applyPreset(
                  context,
                  settings.copyWith(
                    bluetoothScanTimeout: 20,
                    bluetoothConnectionTimeout: 45,
                    bluetoothMaxRetries: 8,
                    dataRecordInterval: 1,
                    movementRecordInterval: 15,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPresetTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  void _applyPreset(BuildContext context, AppSettings updatedSettings) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.of(context).applyProfileQuestion),
        content: Text(S.of(context).applyProfileDescription),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(S.of(context).cancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _updateSettings(context, updatedSettings);
            },
            child: Text(S.of(context).apply),
          ),
        ],
      ),
    );
  }
}
