import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app_template/bloc/settings/settings_bloc.dart';
import 'package:flutter_bloc_app_template/bloc/settings/settings_event.dart';
import 'package:flutter_bloc_app_template/bloc/settings/settings_states.dart';
import 'package:flutter_bloc_app_template/models/goal_config.dart';
import 'package:flutter_bloc_app_template/generated/l10n.dart';

class GoalSettingsPage extends StatefulWidget {
  const GoalSettingsPage({super.key});

  @override
  State<GoalSettingsPage> createState() => _GoalSettingsPageState();
}

class _GoalSettingsPageState extends State<GoalSettingsPage> {
  late GoalConfig goalConfig;
  late int checkRatioFrequencyMin;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        if (state is SettingsLoaded) {
          goalConfig = state.settings.goalConfig;
          checkRatioFrequencyMin = state.settings.checkRatioFrequencyMin;

          return Scaffold(
            appBar: AppBar(
              title: Text(S.of(context).goalConfiguration),
              elevation: 0,
              scrolledUnderElevation: 3,
              backgroundColor: Theme.of(context).colorScheme.surface,
              foregroundColor: Theme.of(context).colorScheme.onSurface,
              centerTitle: true,
            ),
            body: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildCheckFrequencySection(),
                const SizedBox(height: 24),
                _buildGoalTypeSection(),
                const SizedBox(height: 24),
                if (goalConfig.type == GoalType.fixed)
                  _buildFixedGoalSection()
                else
                  _buildDynamicGoalSection(),
              ],
            ),
          );
        }

        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }

  Widget _buildCheckFrequencySection() {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
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
                  Icons.schedule_outlined,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    S.of(context).periodicCheckFrequency,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              S.of(context).periodicCheckFrequencyDescription,
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 13),
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(S.of(context).checkFrequency),
              subtitle: Text('$checkRatioFrequencyMin ${S.of(context).minutes}'),
              trailing: const Icon(Icons.edit),
              onTap: () => _editCheckFrequency(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalTypeSection() {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
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
                  Icons.flag_outlined,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  S.of(context).goalType,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            RadioListTile<GoalType>(
              contentPadding: EdgeInsets.zero,
              title: Text(S.of(context).fixedGoal),
              subtitle: Text(S.of(context).fixedGoalDescription),
              value: GoalType.fixed,
              groupValue: goalConfig.type,
              onChanged: (value) => _changeGoalType(value!),
            ),
            RadioListTile<GoalType>(
              contentPadding: EdgeInsets.zero,
              title: Text(S.of(context).dynamicGoal),
              subtitle: Text(S.of(context).dynamicGoalDescription),
              value: GoalType.dynamic,
              groupValue: goalConfig.type,
              onChanged: (value) => _changeGoalType(value!),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFixedGoalSection() {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
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
                  Icons.straighten_outlined,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    S.of(context).fixedGoalConfig,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              S.of(context).fixedGoalConfigDescription,
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 13),
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(S.of(context).goalRatio),
              subtitle: Text('${goalConfig.fixedRatio ?? 80}%'),
              trailing: const Icon(Icons.edit),
              onTap: () => _editFixedRatio(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDynamicGoalSection() {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.trending_up_outlined,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    S.of(context).dynamicGoalConfig,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              S.of(context).dynamicGoalConfigDescription,
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 13),
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(S.of(context).periodDays),
              subtitle: Text('${goalConfig.periodDays ?? 7} ${S.of(context).periodDaysUnit}'),
              trailing: const Icon(Icons.edit),
              onTap: () => _editPeriodDays(),
            ),
            const Divider(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(S.of(context).dailyIncreasePercent),
              subtitle: Text('${goalConfig.dailyIncreasePercentage ?? 1.0}%'),
              trailing: const Icon(Icons.edit),
              onTap: () => _editDailyIncrease(),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: theme.colorScheme.onPrimaryContainer,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      S.of(context).dynamicGoalInfo,
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _changeGoalType(GoalType type) {
    GoalConfig newConfig;
    if (type == GoalType.fixed) {
      newConfig = const GoalConfig.fixed(ratio: 80);
    } else {
      newConfig = const GoalConfig.dynamic(days: 7, increasePercentage: 1.0);
    }

    _saveSettings(newGoalConfig: newConfig);
  }

  void _editCheckFrequency() {
    final controller =
        TextEditingController(text: checkRatioFrequencyMin.toString());
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(S.of(context).checkFrequency),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: S.of(context).frequencyLabel,
            hintText: S.of(context).enterValue,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(S.of(context).cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              final value = int.tryParse(controller.text);
              if (value != null && value > 0) {
                Navigator.pop(ctx);
                _saveSettings(newCheckFrequency: value);
              }
            },
            child: Text(S.of(context).ok),
          ),
        ],
      ),
    );
  }

  void _editFixedRatio() {
    final controller =
        TextEditingController(text: (goalConfig.fixedRatio ?? 80).toString());
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(S.of(context).goalRatio),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: S.of(context).ratioPercent,
            hintText: S.of(context).enterValueBetween0And100,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(S.of(context).cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              final value = int.tryParse(controller.text);
              if (value != null && value >= 0 && value <= 100) {
                Navigator.pop(ctx);
                _saveSettings(
                  newGoalConfig: GoalConfig.fixed(ratio: value),
                );
              }
            },
            child: Text(S.of(context).ok),
          ),
        ],
      ),
    );
  }

  void _editPeriodDays() {
    final controller = TextEditingController(
        text: (goalConfig.periodDays ?? 7).toString());
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(S.of(context).periodDays),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: S.of(context).numberOfDays,
            hintText: S.of(context).enterValue,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(S.of(context).cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              final value = int.tryParse(controller.text);
              if (value != null && value > 0) {
                Navigator.pop(ctx);
                _saveSettings(
                  newGoalConfig: GoalConfig.dynamic(
                    days: value,
                    increasePercentage:
                        goalConfig.dailyIncreasePercentage ?? 1.0,
                  ),
                );
              }
            },
            child: Text(S.of(context).ok),
          ),
        ],
      ),
    );
  }

  void _editDailyIncrease() {
    final controller = TextEditingController(
        text: (goalConfig.dailyIncreasePercentage ?? 1.0).toString());
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(S.of(context).dailyIncrease),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: S.of(context).percentageDecimal,
            hintText: S.of(context).enterDecimalValue,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(S.of(context).cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              final value = double.tryParse(controller.text);
              if (value != null && value >= 0) {
                Navigator.pop(ctx);
                _saveSettings(
                  newGoalConfig: GoalConfig.dynamic(
                    days: goalConfig.periodDays ?? 7,
                    increasePercentage: value,
                  ),
                );
              }
            },
            child: Text(S.of(context).ok),
          ),
        ],
      ),
    );
  }

  void _saveSettings({
    int? newCheckFrequency,
    GoalConfig? newGoalConfig,
  }) {
    final state = context.read<SettingsBloc>().state;
    if (state is SettingsLoaded) {
      final updatedSettings = state.settings.copyWith(
        checkRatioFrequencyMin: newCheckFrequency,
        goalConfig: newGoalConfig,
      );

      context.read<SettingsBloc>().add(UpdateSettings(updatedSettings));
    }
  }
}
