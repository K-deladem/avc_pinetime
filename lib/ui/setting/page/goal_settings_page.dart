import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app_template/bloc/settings/settings_bloc.dart';
import 'package:flutter_bloc_app_template/bloc/settings/settings_event.dart';
import 'package:flutter_bloc_app_template/bloc/settings/settings_states.dart';
import 'package:flutter_bloc_app_template/models/goal_config.dart';

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
              title: const Text('Configuration des objectifs'),
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.schedule_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Fréquence de vérification périodique',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Définir la fréquence à laquelle le système vérifiera si l\'objectif est atteint.',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Fréquence de vérification'),
              subtitle: Text('$checkRatioFrequencyMin minutes'),
              trailing: const Icon(Icons.edit),
              onTap: () => _editCheckFrequency(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalTypeSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.flag_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Type d\'objectif',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            RadioListTile<GoalType>(
              contentPadding: EdgeInsets.zero,
              title: const Text('Objectif fixe'),
              subtitle: const Text('Définir un ratio fixe à atteindre'),
              value: GoalType.fixed,
              groupValue: goalConfig.type,
              onChanged: (value) => _changeGoalType(value!),
            ),
            RadioListTile<GoalType>(
              contentPadding: EdgeInsets.zero,
              title: const Text('Objectif dynamique'),
              subtitle: const Text(
                  'Calculé sur les derniers jours avec augmentation quotidienne'),
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.straighten_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Configuration objectif fixe',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Définir directement le ratio de l\'objectif à atteindre.',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Ratio de l\'objectif'),
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.trending_up_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Configuration objectif dynamique',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'L\'objectif sera calculé sur la base des X derniers jours avec une augmentation quotidienne de Y%.',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Nombre de jours de la période'),
              subtitle: Text('${goalConfig.periodDays ?? 7} jours'),
              trailing: const Icon(Icons.edit),
              onTap: () => _editPeriodDays(),
            ),
            const Divider(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Pourcentage d\'augmentation journalière'),
              subtitle: Text('${goalConfig.dailyIncreasePercentage ?? 1.0}%'),
              trailing: const Icon(Icons.edit),
              onTap: () => _editDailyIncrease(),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'L\'objectif sera automatiquement recalculé chaque jour en fonction de votre progression.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
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

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Fréquence de vérification'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Fréquence (minutes)',
            hintText: 'Entrer une valeur',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              final value = int.tryParse(controller.text);
              if (value != null && value > 0) {
                Navigator.pop(ctx);
                _saveSettings(newCheckFrequency: value);
              }
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _editFixedRatio() {
    final controller =
        TextEditingController(text: (goalConfig.fixedRatio ?? 80).toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ratio de l\'objectif'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Ratio (%)',
            hintText: 'Entrer une valeur entre 0 et 100',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              final value = int.tryParse(controller.text);
              if (value != null && value >= 0 && value <= 100) {
                Navigator.pop(ctx);
                _saveSettings(
                  newGoalConfig: GoalConfig.fixed(ratio: value),
                );
              }
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _editPeriodDays() {
    final controller = TextEditingController(
        text: (goalConfig.periodDays ?? 7).toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nombre de jours de la période'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Nombre de jours',
            hintText: 'Entrer une valeur',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
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
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _editDailyIncrease() {
    final controller = TextEditingController(
        text: (goalConfig.dailyIncreasePercentage ?? 1.0).toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Augmentation journalière'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Pourcentage (%)',
            hintText: 'Entrer une valeur décimale',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
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
            child: const Text('OK'),
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
