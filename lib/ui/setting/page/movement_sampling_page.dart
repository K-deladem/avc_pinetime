import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app_template/bloc/settings/settings_bloc.dart';
import 'package:flutter_bloc_app_template/bloc/settings/settings_event.dart';
import 'package:flutter_bloc_app_template/bloc/settings/settings_states.dart';
import 'package:flutter_bloc_app_template/models/movement_sampling_settings.dart';

class MovementSamplingPage extends StatefulWidget {
  const MovementSamplingPage({super.key});

  @override
  State<MovementSamplingPage> createState() => _MovementSamplingPageState();
}

class _MovementSamplingPageState extends State<MovementSamplingPage> {
  late MovementSamplingSettings _settings;

  @override
  void initState() {
    super.initState();
    final settingsState = context.read<SettingsBloc>().state;
    if (settingsState is SettingsLoaded) {
      _settings = settingsState.settings.movementSampling;
    } else {
      _settings = const MovementSamplingSettings();
    }
  }

  void _updateSettings(MovementSamplingSettings newSettings) {
    setState(() {
      _settings = newSettings;
    });

    final settingsBloc = context.read<SettingsBloc>();
    final currentState = settingsBloc.state;

    if (currentState is SettingsLoaded) {
      final updatedSettings = currentState.settings.copyWith(
        movementSampling: newSettings,
      );
      settingsBloc.add(UpdateSettings(updatedSettings));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Échantillonnage Mouvement'),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeader(theme),
          const SizedBox(height: 24),
          _buildPresetSection(theme),
          const Divider(height: 32),
          _buildAdvancedSection(theme),
          const SizedBox(height: 24),
          _buildInfoCard(theme),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fréquence d\'enregistrement',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Réduisez le volume de données de mouvement stockées. '
          'Un échantillonnage moins fréquent économise de l\'espace de stockage.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                Icons.speed,
                color: theme.colorScheme.onPrimaryContainer,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mode actuel: ${_settings.presetName}',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _settings.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPresetSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Préréglages',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildPresetTile(
          theme,
          'Économie Max',
          '1 échantillon / 5s (~12/min)',
          Icons.battery_saver,
          MovementSamplingSettings.economyMax,
        ),
        _buildPresetTile(
          theme,
          'Économie',
          '1 échantillon / 2s (~30/min)',
          Icons.eco,
          MovementSamplingSettings.economy,
        ),
        _buildPresetTile(
          theme,
          'Normal',
          '1 échantillon / seconde (~60/min)',
          Icons.speed,
          MovementSamplingSettings.normal,
        ),
        _buildPresetTile(
          theme,
          'Précis',
          '2 échantillons / seconde (~120/min)',
          Icons.precision_manufacturing,
          MovementSamplingSettings.precise,
        ),
        _buildPresetTile(
          theme,
          'Maximum',
          'Tout enregistrer (~600/min)',
          Icons.all_inclusive,
          MovementSamplingSettings.all,
        ),
      ],
    );
  }

  Widget _buildPresetTile(
    ThemeData theme,
    String title,
    String subtitle,
    IconData icon,
    MovementSamplingSettings preset,
  ) {
    final isSelected = _settings.mode == preset.mode &&
        _settings.intervalMs == preset.intervalMs;

    return Card(
      elevation: isSelected ? 2 : 0,
      color: isSelected
          ? theme.colorScheme.primaryContainer
          : theme.colorScheme.surfaceContainerHighest,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected
              ? theme.colorScheme.onPrimaryContainer
              : theme.colorScheme.onSurfaceVariant,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected
                ? theme.colorScheme.onPrimaryContainer
                : theme.colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: isSelected
                ? theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.7)
                : theme.colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: isSelected
            ? Icon(Icons.check_circle, color: theme.colorScheme.primary)
            : null,
        onTap: () => _updateSettings(preset),
      ),
    );
  }

  Widget _buildAdvancedSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Paramètres avancés',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        // Mode de sampling
        ListTile(
          leading: Icon(
            Icons.tune,
            color: theme.colorScheme.primary,
          ),
          title: const Text('Mode d\'échantillonnage'),
          subtitle: Text(_getModeDescription(_settings.mode)),
          trailing: DropdownButton<MovementSamplingMode>(
            value: _settings.mode,
            underline: const SizedBox(),
            items: MovementSamplingMode.values.map((mode) {
              return DropdownMenuItem(
                value: mode,
                child: Text(_getModeName(mode)),
              );
            }).toList(),
            onChanged: (mode) {
              if (mode != null) {
                _updateSettings(_settings.copyWith(mode: mode));
              }
            },
          ),
        ),

        // Intervalle (pour mode interval et aggregate)
        if (_settings.mode == MovementSamplingMode.interval ||
            _settings.mode == MovementSamplingMode.aggregate)
          Column(
            children: [
              ListTile(
                leading: Icon(
                  Icons.timer,
                  color: theme.colorScheme.primary,
                ),
                title: const Text('Intervalle'),
                subtitle: Text('${_settings.intervalMs}ms (${(_settings.intervalMs / 1000).toStringAsFixed(1)}s)'),
              ),
              Slider(
                value: _settings.intervalMs.toDouble(),
                min: 100,
                max: 10000,
                divisions: 99,
                label: '${_settings.intervalMs}ms',
                onChanged: (value) {
                  _updateSettings(_settings.copyWith(intervalMs: value.round()));
                },
              ),
            ],
          ),

        // Seuil (pour mode threshold)
        if (_settings.mode == MovementSamplingMode.threshold)
          Column(
            children: [
              ListTile(
                leading: Icon(
                  Icons.change_history,
                  color: theme.colorScheme.primary,
                ),
                title: const Text('Seuil de changement'),
                subtitle: Text('${_settings.changeThreshold.toStringAsFixed(2)} g'),
              ),
              Slider(
                value: _settings.changeThreshold,
                min: 0.1,
                max: 2.0,
                divisions: 19,
                label: '${_settings.changeThreshold.toStringAsFixed(2)} g',
                onChanged: (value) {
                  _updateSettings(_settings.copyWith(changeThreshold: value));
                },
              ),
            ],
          ),

        // Max samples per flush
        ListTile(
          leading: Icon(
            Icons.storage,
            color: theme.colorScheme.primary,
          ),
          title: const Text('Échantillons max par flush'),
          subtitle: Text('${_settings.maxSamplesPerFlush} échantillons'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: _settings.maxSamplesPerFlush > 10
                    ? () => _updateSettings(_settings.copyWith(
                          maxSamplesPerFlush: _settings.maxSamplesPerFlush - 10,
                        ))
                    : null,
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: _settings.maxSamplesPerFlush < 300
                    ? () => _updateSettings(_settings.copyWith(
                          maxSamplesPerFlush: _settings.maxSamplesPerFlush + 10,
                        ))
                    : null,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(ThemeData theme) {
    return Card(
      color: theme.colorScheme.tertiaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: theme.colorScheme.onTertiaryContainer,
                ),
                const SizedBox(width: 12),
                Text(
                  'Estimation du stockage',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.onTertiaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _getStorageEstimate(),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onTertiaryContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getModeName(MovementSamplingMode mode) {
    switch (mode) {
      case MovementSamplingMode.all:
        return 'Tout';
      case MovementSamplingMode.interval:
        return 'Intervalle';
      case MovementSamplingMode.threshold:
        return 'Seuil';
      case MovementSamplingMode.aggregate:
        return 'Moyenne';
    }
  }

  String _getModeDescription(MovementSamplingMode mode) {
    switch (mode) {
      case MovementSamplingMode.all:
        return 'Enregistre toutes les données reçues';
      case MovementSamplingMode.interval:
        return 'Garde un échantillon par intervalle de temps';
      case MovementSamplingMode.threshold:
        return 'Enregistre uniquement lors de changements significatifs';
      case MovementSamplingMode.aggregate:
        return 'Calcule une moyenne sur l\'intervalle';
    }
  }

  String _getStorageEstimate() {
    int samplesPerMinute;
    switch (_settings.mode) {
      case MovementSamplingMode.all:
        samplesPerMinute = 600;
        break;
      case MovementSamplingMode.interval:
      case MovementSamplingMode.aggregate:
        samplesPerMinute = 60000 ~/ _settings.intervalMs;
        break;
      case MovementSamplingMode.threshold:
        samplesPerMinute = 60; // Estimation variable
        break;
    }

    final perHour = samplesPerMinute * 60;
    final perDay = perHour * 8; // 8h d'utilisation estimée
    final bytesPerSample = 50; // Estimation
    final mbPerDay = (perDay * bytesPerSample * 2) / 1024 / 1024; // x2 pour les 2 montres

    return 'Environ $samplesPerMinute échantillons/min par montre\n'
        '~${perHour.toString()} échantillons/heure\n'
        '~${mbPerDay.toStringAsFixed(1)} Mo/jour (8h d\'utilisation, 2 montres)';
  }
}
