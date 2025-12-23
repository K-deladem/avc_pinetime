import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app_template/bloc/settings/settings_bloc.dart';
import 'package:flutter_bloc_app_template/bloc/settings/settings_event.dart';
import 'package:flutter_bloc_app_template/bloc/settings/settings_states.dart';
import 'package:flutter_bloc_app_template/models/time_preferences.dart';
import 'package:flutter_bloc_app_template/bloc/infinitime/dual_infinitime_bloc.dart';
import 'package:flutter_bloc_app_template/bloc/infinitime/dual_infinitime_event.dart';
import 'package:flutter_bloc_app_template/models/arm_side.dart';

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

    final infiniTimeBloc = context.read<DualInfiniTimeBloc>();
    final now = DateTime.now();

    // Déterminer l'heure locale à envoyer à la montre
    // La montre affiche l'heure telle quelle, sans conversion de fuseau
    DateTime localTimeToSend;

    if (_preferences.usePhoneTimezone) {
      // Utiliser l'heure locale du téléphone directement
      localTimeToSend = now;
    } else {
      // Calculer l'heure pour le fuseau personnalisé
      // D'abord convertir en UTC, puis ajouter le décalage personnalisé
      final utcNow = now.toUtc();
      localTimeToSend = utcNow.add(_preferences.timezoneOffset);
    }

    // Synchroniser les deux montres avec l'heure locale
    // Note: On utilise syncTimeUtc mais on envoie l'heure locale car
    // la montre n'applique pas de conversion de fuseau horaire
    infiniTimeBloc.add(OnSyncTimeUtc(ArmSide.left, localTimeToSend));
    infiniTimeBloc.add(OnSyncTimeUtc(ArmSide.right, localTimeToSend));

    // Afficher un message de confirmation
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Synchronisation de l\'heure lancée pour les deux montres.\n'
            'Fuseau: ${_preferences.timezoneDescription}',
          ),
          backgroundColor: Colors.green,
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
        title: const Text('Paramètres de Synchronisation'),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Configuration de l\'heure',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Personnalisez les paramètres de synchronisation de l\'heure avec vos montres',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),

          // Format d'heure
          _buildFormatSwitch(theme),
          const Divider(),

          // Source du fuseau horaire
          _buildTimezoneSourceSwitch(theme),
          const Divider(),

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

  Widget _buildFormatSwitch(ThemeData theme) {
    return SwitchListTile(
      value: _preferences.use24HourFormat,
      onChanged: (value) {
        _updatePreferences(_preferences.copyWith(use24HourFormat: value));
      },
      title: Row(
        children: [
          Icon(
            Icons.access_time_outlined,
            color: theme.colorScheme.primary,
            size: 24,
          ),
          const SizedBox(width: 12),
          const Text('Format 24 heures'),
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(left: 36, top: 4),
        child: Text(
          _preferences.use24HourFormat
              ? 'Affichage au format 24h (ex: 14:30)'
              : 'Affichage au format 12h (ex: 2:30 PM)',
          style: theme.textTheme.bodySmall,
        ),
      ),
      activeThumbColor: theme.colorScheme.primary,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  Widget _buildTimezoneSourceSwitch(ThemeData theme) {
    return SwitchListTile(
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
          const Text('Fuseau du téléphone'),
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(left: 36, top: 4),
        child: Text(
          _preferences.usePhoneTimezone
              ? 'Utiliser le fuseau horaire du téléphone'
              : 'Utiliser un fuseau horaire personnalisé',
          style: theme.textTheme.bodySmall,
        ),
      ),
      activeThumbColor: theme.colorScheme.primary,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  Widget _buildTimezoneSelector(ThemeData theme) {
    return ListTile(
      leading: Icon(
        Icons.language_outlined,
        color: theme.colorScheme.primary,
        size: 24,
      ),
      title: const Text('Fuseau horaire personnalisé'),
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
        label: Text(_isSyncing ? 'Synchronisation...' : 'Synchroniser maintenant'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
        ),
      ),
    );
  }

  Widget _buildInfoCard(ThemeData theme) {
    return Card(
      color: theme.colorScheme.primaryContainer,
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
                  'Information',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'L\'heure est automatiquement synchronisée à chaque connexion des montres. '
              'Utilisez la synchronisation manuelle après un voyage dans un autre fuseau horaire '
              'ou lors du changement d\'heure (été/hiver).',
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
      title: const Text('Sélectionner le fuseau horaire'),
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
          child: const Text('Annuler'),
        ),
      ],
    );
  }
}
