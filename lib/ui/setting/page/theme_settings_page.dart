import 'package:flutter/material.dart';
import 'package:flutter_bloc_app_template/generated/l10n.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app_template/app/theme_helper.dart';
import 'package:flutter_bloc_app_template/bloc/settings/settings_bloc.dart';
import 'package:flutter_bloc_app_template/bloc/settings/settings_event.dart';
import 'package:flutter_bloc_app_template/bloc/settings/settings_states.dart';

class ThemeSettingsPage extends StatefulWidget {
  static const routeName = '/themeSettings';

  const ThemeSettingsPage({super.key});

  @override
  State<ThemeSettingsPage> createState() => _ThemeSettingsPageState();
}

class _ThemeSettingsPageState extends State<ThemeSettingsPage> {
  @override
  void initState() {
    super.initState();
    context.read<SettingsBloc>().add(LoadSettings());
  }

  void _applyTheme(BuildContext context, AppTheme newTheme) {
    final bloc = context.read<SettingsBloc>();
    final state = bloc.state;

    if (state is SettingsLoaded) {
      final updated = state.settings.copyWith(themeMode: newTheme);
      bloc.add(UpdateSettings(updated));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Thème mis à jour.")),
      );
    }
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

        final currentTheme = state.settings.themeMode;

        return Scaffold(
          appBar: AppBar(
            title: const Text("Thème de l'application"),
            centerTitle: true,
            elevation: 0,
            backgroundColor: Theme.of(context).colorScheme.surface,
            foregroundColor: Theme.of(context).colorScheme.onSurface,
          ),
          body: ListView(
            children: [
              _buildThemeTile(context, "Or (Clair)", AppTheme.lightGold, "Thème clair élégant avec du doré", Icons.wb_sunny, currentTheme),
              _buildThemeTile(context, "Menthe (Clair)", AppTheme.lightMint, "Thème clair avec une teinte verte menthe", Icons.eco, currentTheme),
              _buildThemeTile(context, "Or (Sombre)", AppTheme.darkGold, "Thème sombre élégant avec du doré", Icons.nights_stay, currentTheme),
              _buildThemeTile(context, "Menthe (Sombre)", AppTheme.darkMint, "Thème sombre avec une teinte menthe", Icons.forest, currentTheme),
              _buildThemeTile(context, "Suivre le système", AppTheme.system, "Adapte automatiquement le thème à l'appareil", Icons.phone_android, currentTheme),
              _buildThemeTile(context, "Expérimental", AppTheme.experimental, "Mode visuel avancé pour tests", Icons.science, currentTheme),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThemeTile(
      BuildContext context,
      String title,
      AppTheme theme,
      String subtitle,
      IconData icon,
      AppTheme currentTheme,
      ) {
    return RadioListTile<AppTheme>(
      value: theme,
      groupValue: currentTheme,
      onChanged: (newTheme) {
        if (newTheme != null) _applyTheme(context, newTheme);
      },
      title: Text(title),
      subtitle: Text(subtitle),
      secondary: Icon(icon, color: Theme.of(context).colorScheme.primary),
      selected: currentTheme == theme,
    );
  }
}