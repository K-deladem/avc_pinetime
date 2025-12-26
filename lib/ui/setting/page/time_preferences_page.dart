import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app_template/bloc/settings/settings_bloc.dart';
import 'package:flutter_bloc_app_template/bloc/settings/settings_event.dart';
import 'package:flutter_bloc_app_template/bloc/settings/settings_states.dart';
import 'package:flutter_bloc_app_template/models/time_preferences.dart';
import 'package:flutter_bloc_app_template/bloc/device/device.dart';
import 'package:flutter_bloc_app_template/models/arm_side.dart';
import 'package:flutter_bloc_app_template/generated/l10n.dart';

class TimePreferencesPage extends StatefulWidget {
  const TimePreferencesPage({super.key});

  @override
  State<TimePreferencesPage> createState() => _TimePreferencesPageState();
}

class _TimePreferencesPageState extends State<TimePreferencesPage> {
  late TimePreferences _preferences;
  late bool _isSyncing;

  @override
  void initState() {
    super.initState();
    _isSyncing = false;
    final settingsState = context.read<SettingsBloc>().state;
    if (settingsState is SettingsLoaded) {
      _preferences = settingsState.settings.timePreferences;
    } else {
      _preferences = const TimePreferences();
    }
  }

  void _updatePreferences(TimePreferences newPreferences) {
    setState(() {
      _preferences = newPreferences;
    });

    final settingsBloc = context.read<SettingsBloc>();
    final currentState = settingsBloc.state;

    if (currentState is SettingsLoaded) {
      final updatedSettings = currentState.settings.copyWith(
        timePreferences: newPreferences,
      );
      settingsBloc.add(UpdateSettings(updatedSettings));
    }
  }

  void _syncWatchTime() async {
    setState(() {
      _isSyncing = true;
    });

    final deviceBloc = context.read<DeviceBloc>();
    final deviceState = deviceBloc.state;

    // Vérifier quelles montres sont connectées
    final leftConnected = deviceState.left.connected;
    final rightConnected = deviceState.right.connected;

    if (!leftConnected && !rightConnected) {
      // Aucune montre connectée
      if (mounted) {
        final theme = Theme.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(S.of(context).noWatchConnected),
            backgroundColor: theme.colorScheme.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      setState(() {
        _isSyncing = false;
      });
      return;
    }

    // Synchroniser les montres connectées
    final List<String> syncedWatches = [];

    // Déterminer le fuseau horaire à utiliser
    // Si usePhoneTimezone est true, on passe null pour utiliser le fuseau du téléphone
    // Sinon, on passe le fuseau personnalisé
    final double? timezoneOffset = _preferences.usePhoneTimezone
        ? null
        : _preferences.timezoneOffsetHours;

    if (leftConnected) {
      deviceBloc.add(SyncTime(ArmSide.left, timezoneOffsetHours: timezoneOffset));
      syncedWatches.add(S.of(context).left);
    }
    if (rightConnected) {
      deviceBloc.add(SyncTime(ArmSide.right, timezoneOffsetHours: timezoneOffset));
      syncedWatches.add(S.of(context).right);
    }

    // Afficher un message de confirmation
    if (mounted) {
      final theme = Theme.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            S.of(context).timeSyncedFor(syncedWatches.join(", "), _preferences.timezoneDescription),
          ),
          backgroundColor: theme.colorScheme.primary,
          duration: const Duration(seconds: 3),
        ),
      );
    }

    // Réinitialiser l'état après 2 secondes
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() {
        _isSyncing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).syncSettings),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            S.of(context).timeConfiguration,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            S.of(context).timeConfigurationDescription,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),

          // Source du fuseau horaire
          _buildTimezoneSourceSwitch(theme),
          const SizedBox(height: 16,),

          // Sélection du fuseau horaire personnalisé
          if (!_preferences.usePhoneTimezone) ...[
            _buildTimezoneSelector(theme),
            const Divider(),
          ],

          const SizedBox(height: 24),

          // Bouton de synchronisation
          _buildSyncButton(theme),

          const SizedBox(height: 24),

          // Informations
          _buildInfoCard(theme),
        ],
      ),
    );
  }

  Widget _buildTimezoneSourceSwitch(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
        borderRadius: BorderRadius.circular(12),
      ),child: SwitchListTile(
      value: _preferences.usePhoneTimezone,
      onChanged: (value) {
        _updatePreferences(_preferences.copyWith(usePhoneTimezone: value));
      },
      title: Row(
        children: [
          Icon(
            Icons.public_outlined,
            color: theme.colorScheme.primary,
            size: 24,
          ),
          const SizedBox(width: 12),
          Text(S.of(context).usePhoneTimezone),
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(left: 36, top: 4),
        child: Text(
          _preferences.usePhoneTimezone
              ? S.of(context).phoneTimezone
              : S.of(context).useCustomTimezone,
          style: theme.textTheme.bodySmall,
        ),
      ),
      activeThumbColor: theme.colorScheme.primary,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ));
  }

  Widget _buildTimezoneSelector(ThemeData theme) {
    return ListTile(
      leading: Icon(
        Icons.language_outlined,
        color: theme.colorScheme.primary,
        size: 24,
      ),
      title: Text(S.of(context).customTimezone),
      subtitle: Text(
        _preferences.timezoneDescription,
        style: theme.textTheme.bodySmall,
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: theme.colorScheme.onSurfaceVariant,
      ),
      onTap: () => _showTimezoneDialog(theme),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  Widget _buildSyncButton(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton.icon(
        onPressed: _isSyncing ? null : _syncWatchTime,
        icon: _isSyncing
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.onPrimary,
                  ),
                ),
              )
            : const Icon(Icons.sync),
        label: Text(_isSyncing ? S.of(context).syncing : S.of(context).syncNow),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  Widget _buildInfoCard(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 12),
                Text(
                  S.of(context).information,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              S.of(context).timeSyncInfo,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTimezoneDialog(ThemeData theme) {
    showDialog(
      context: context,
      builder: (context) => _TimezonePickerDialog(
        currentOffset: _preferences.timezoneOffsetHours,
        onSelected: (offset) {
          _updatePreferences(_preferences.copyWith(timezoneOffsetHours: offset));
        },
      ),
    );
  }
}

class _TimezonePickerDialog extends StatefulWidget {
  final double currentOffset;
  final ValueChanged<double> onSelected;

  const _TimezonePickerDialog({
    required this.currentOffset,
    required this.onSelected,
  });

  @override
  State<_TimezonePickerDialog> createState() => _TimezonePickerDialogState();
}

class _TimezonePickerDialogState extends State<_TimezonePickerDialog> {
  late double _selectedOffset;

  @override
  void initState() {
    super.initState();
    _selectedOffset = widget.currentOffset;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Générer les fuseaux de UTC-12 à UTC+14
    final timezones = <double>[];
    for (double i = -12; i <= 14; i += 0.5) {
      timezones.add(i);
    }

    return AlertDialog(
      title: Text(S.of(context).selectTimezone),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: timezones.length,
          itemBuilder: (context, index) {
            final offset = timezones[index];
            final hours = offset.floor();
            final minutes = ((offset - hours) * 60).abs().round();

            String label;
            if (offset >= 0) {
              label = minutes > 0
                  ? 'UTC+$hours:${minutes.toString().padLeft(2, '0')}'
                  : 'UTC+$hours';
            } else {
              label = minutes > 0
                  ? 'UTC$hours:${minutes.toString().padLeft(2, '0')}'
                  : 'UTC$hours';
            }

            final isSelected = offset == _selectedOffset;

            return ListTile(
              title: Text(label),
              trailing: isSelected
                  ? Icon(Icons.check, color: theme.colorScheme.primary)
                  : null,
              selected: isSelected,
              onTap: () {
                setState(() {
                  _selectedOffset = offset;
                });
                widget.onSelected(offset);
                Navigator.pop(context);
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(S.of(context).cancel),
        ),
      ],
    );
  }
}
