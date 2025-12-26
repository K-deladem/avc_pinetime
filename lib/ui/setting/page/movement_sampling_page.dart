import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app_template/bloc/settings/settings_bloc.dart';
import 'package:flutter_bloc_app_template/bloc/settings/settings_event.dart';
import 'package:flutter_bloc_app_template/bloc/settings/settings_states.dart';
import 'package:flutter_bloc_app_template/generated/l10n.dart';
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
        title: Text(S.of(context).movementSamplingTitle),
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
          S.of(context).recordingFrequency,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          S.of(context).recordingFrequencyDescription,
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
                      S.of(context).currentMode(_settings.presetName),
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
          S.of(context).presets,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        // Nouveau mode par défaut: par unité de temps
        _buildRecordsPerTimeUnitSection(theme),
        const Divider(height: 24),
        Text(
          S.of(context).classicModes,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        _buildPresetTile(
          theme,
          S.of(context).economyMax,
          S.of(context).economyMaxDescription,
          Icons.battery_saver,
          MovementSamplingSettings.economyMax,
        ),
        _buildPresetTile(
          theme,
          S.of(context).economy,
          S.of(context).economyDescription,
          Icons.eco,
          MovementSamplingSettings.economy,
        ),
        _buildPresetTile(
          theme,
          S.of(context).normal,
          S.of(context).normalDescription,
          Icons.speed,
          MovementSamplingSettings.normal,
        ),
        _buildPresetTile(
          theme,
          S.of(context).precise,
          S.of(context).preciseDescription,
          Icons.precision_manufacturing,
          MovementSamplingSettings.precise,
        ),
        _buildPresetTile(
          theme,
          S.of(context).maximum,
          S.of(context).maximumDescription,
          Icons.all_inclusive,
          MovementSamplingSettings.all,
        ),
      ],
    );
  }

  Widget _buildRecordsPerTimeUnitSection(ThemeData theme) {
    final isSelected = _settings.mode == MovementSamplingMode.recordsPerTimeUnit;

    return Container(
      //elevation: isSelected ? 3 : 0,
      decoration: BoxDecoration(
        color:  isSelected
            ? theme.colorScheme.primaryContainer
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),

      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  color: isSelected
                      ? theme.colorScheme.onPrimaryContainer
                      : theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        S.of(context).perTimeUnit,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          fontSize: 16,
                          color: isSelected
                              ? theme.colorScheme.onPrimaryContainer
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        S.of(context).perTimeUnitDescription,
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected
                              ? theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.7)
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(Icons.check_circle, color: theme.colorScheme.primary),
              ],
            ),
            if (isSelected) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          S.of(context).numberOfRecords,
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            IconButton(
                              onPressed: _settings.recordsCount > 1
                                  ? () => _updateSettings(_settings.copyWith(
                                        recordsCount: _settings.recordsCount - 1,
                                      ))
                                  : null,
                              icon: const Icon(Icons.remove_circle_outline),
                              iconSize: 28,
                              color: theme.colorScheme.primary,
                            ),
                            Container(
                              width: 50,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surface,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${_settings.recordsCount}',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: _settings.recordsCount < 100
                                  ? () => _updateSettings(_settings.copyWith(
                                        recordsCount: _settings.recordsCount + 1,
                                      ))
                                  : null,
                              icon: const Icon(Icons.add_circle_outline),
                              iconSize: 28,
                              color: theme.colorScheme.primary,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          S.of(context).per,
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<SamplingTimeUnit>(
                              value: _settings.timeUnit,
                              isExpanded: true,
                              icon: Icon(
                                Icons.keyboard_arrow_down,
                                color: theme.colorScheme.primary,
                              ),
                              items: SamplingTimeUnit.values.map((unit) {
                                return DropdownMenuItem(
                                  value: unit,
                                  child: Text(
                                    _getTimeUnitName(unit),
                                    style: TextStyle(
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (unit) {
                                if (unit != null) {
                                  _updateSettings(_settings.copyWith(timeUnit: unit));
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _settings.description,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    _updateSettings(_settings.copyWith(
                      mode: MovementSamplingMode.recordsPerTimeUnit,
                      recordsCount: 4,
                      timeUnit: SamplingTimeUnit.hour,
                    ));
                  },
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(S.of(context).selectThisMode),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getTimeUnitName(SamplingTimeUnit unit) {
    switch (unit) {
      case SamplingTimeUnit.second:
        return S.of(context).timeUnitSecond;
      case SamplingTimeUnit.minute:
        return S.of(context).timeUnitMinute;
      case SamplingTimeUnit.hour:
        return S.of(context).timeUnitHour;
    }
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

    return Container(
    //  elevation: isSelected ? 2 : 0,
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
          S.of(context).advancedSettings,
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
          title: Text(S.of(context).samplingModeLabel),
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
                title: Text(S.of(context).intervalLabel),
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
                title: Text(S.of(context).changeThresholdLabel),
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
          title: Text(S.of(context).maxSamplesPerFlushLabel),
          subtitle: Text(S.of(context).samplesPerFlushUnit(_settings.maxSamplesPerFlush)),
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
    return Container(
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
                  S.of(context).storageEstimate,
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
        return S.of(context).modeAll;
      case MovementSamplingMode.interval:
        return S.of(context).modeInterval;
      case MovementSamplingMode.threshold:
        return S.of(context).modeThreshold;
      case MovementSamplingMode.aggregate:
        return S.of(context).modeAggregate;
      case MovementSamplingMode.recordsPerTimeUnit:
        return S.of(context).modePerUnit;
    }
  }

  String _getModeDescription(MovementSamplingMode mode) {
    switch (mode) {
      case MovementSamplingMode.all:
        return S.of(context).modeAllDescription;
      case MovementSamplingMode.interval:
        return S.of(context).modeIntervalDescription;
      case MovementSamplingMode.threshold:
        return S.of(context).modeThresholdDescription;
      case MovementSamplingMode.aggregate:
        return S.of(context).modeAggregateDescription;
      case MovementSamplingMode.recordsPerTimeUnit:
        return S.of(context).modePerUnitDescription;
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
      case MovementSamplingMode.recordsPerTimeUnit:
        // Calculer selon l'unité de temps
        switch (_settings.timeUnit) {
          case SamplingTimeUnit.second:
            samplesPerMinute = _settings.recordsCount * 60;
            break;
          case SamplingTimeUnit.minute:
            samplesPerMinute = _settings.recordsCount;
            break;
          case SamplingTimeUnit.hour:
            // Convertir en par minute (fraction)
            samplesPerMinute = (_settings.recordsCount / 60).ceil();
            if (samplesPerMinute < 1) samplesPerMinute = 1;
            break;
        }
        break;
    }

    final perHour = _settings.mode == MovementSamplingMode.recordsPerTimeUnit &&
            _settings.timeUnit == SamplingTimeUnit.hour
        ? _settings.recordsCount
        : samplesPerMinute * 60;
    final perDay = perHour * 8; // 8h d'utilisation estimée
    final bytesPerSample = 50; // Estimation
    final mbPerDay = (perDay * bytesPerSample * 2) / 1024 / 1024; // x2 pour les 2 montres

    String samplesText;
    if (_settings.mode == MovementSamplingMode.recordsPerTimeUnit &&
        _settings.timeUnit == SamplingTimeUnit.hour) {
      samplesText = S.of(context).samplesPerHourPerWatch(_settings.recordsCount);
    } else {
      samplesText = S.of(context).samplesPerMinutePerWatch(samplesPerMinute);
    }

    return '$samplesText\n'
        '${S.of(context).samplesPerHour(perHour)}\n'
        '${S.of(context).mbPerDay(mbPerDay.toStringAsFixed(1))}';
  }
}
