import 'package:flutter/material.dart';
import 'package:flutter_bloc_app_template/generated/l10n.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app_template/bloc/settings/settings_bloc.dart';
import 'package:flutter_bloc_app_template/bloc/settings/settings_event.dart';
import 'package:flutter_bloc_app_template/bloc/settings/settings_states.dart';
import 'package:flutter_bloc_app_template/models/chart_preferences.dart';

class ChartPreferencesPage extends StatefulWidget {
  const ChartPreferencesPage({super.key});

  @override
  State<ChartPreferencesPage> createState() => _ChartPreferencesPageState();
}

class _ChartPreferencesPageState extends State<ChartPreferencesPage> {
  late ChartPreferences _preferences;

  @override
  void initState() {
    super.initState();
    final settingsState = context.read<SettingsBloc>().state;
    if (settingsState is SettingsLoaded) {
      _preferences = settingsState.settings.chartPreferences;
    } else {
      _preferences = const ChartPreferences();
    }
  }

  void _updatePreferences(ChartPreferences newPreferences) {
    setState(() {
      _preferences = newPreferences;
    });

    final settingsBloc = context.read<SettingsBloc>();
    final currentState = settingsBloc.state;

    if (currentState is SettingsLoaded) {
      final updatedSettings = currentState.settings.copyWith(
        chartPreferences: newPreferences,
      );
      settingsBloc.add(UpdateSettings(updatedSettings));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Préférences des Graphiques'),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Sélectionnez les graphiques à afficher',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Les graphiques désactivés ne seront pas affichés dans l\'écran principal',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          _buildChartSwitch(
            theme,
            title: 'Asymétrie (Magnitude & Axe)',
            subtitle: 'Graphique gauge fusionné montrant l\'asymétrie',
            icon: Icons.assessment_outlined,
            value: _preferences.showAsymmetryGauge,
            onChanged: (value) {
              _updatePreferences(
                _preferences.copyWith(showAsymmetryGauge: value),
              );
            },
          ),
          const Divider(),
          _buildChartSwitch(
            theme,
            title: 'Niveau de Batterie',
            subtitle: 'Comparaison du niveau de batterie des deux montres',
            icon: Icons.battery_charging_full_outlined,
            value: _preferences.showBatteryComparison,
            onChanged: (value) {
              _updatePreferences(
                _preferences.copyWith(showBatteryComparison: value),
              );
            },
          ),
          const Divider(),
          _buildChartSwitch(
            theme,
            title: 'Objectif Équilibre',
            subtitle: 'Heatmap magnitude/axis pour le suivi de l\'équilibre',
            icon: Icons.calendar_month_outlined,
            value: _preferences.showAsymmetryHeatmap,
            onChanged: (value) {
              _updatePreferences(
                _preferences.copyWith(showAsymmetryHeatmap: value),
              );
            },
          ),
          const Divider(),
          _buildChartSwitch(
            theme,
            title: 'Nombre de Pas',
            subtitle: 'Comparaison du nombre de pas entre les deux bras',
            icon: Icons.directions_walk_outlined,
            value: _preferences.showStepsComparison,
            onChanged: (value) {
              _updatePreferences(
                _preferences.copyWith(showStepsComparison: value),
              );
            },
          ),
          const SizedBox(height: 32),
          Card(
            color: theme.colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      '${_preferences.enabledCount} graphique(s) activé(s)',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartSwitch(
    ThemeData theme, {
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      title: Row(
        children: [
          Icon(
            icon,
            color: value
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: value ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(left: 36, top: 4),
        child: Text(
          subtitle,
          style: theme.textTheme.bodySmall,
        ),
      ),
      activeThumbColor: theme.colorScheme.primary,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }
}
