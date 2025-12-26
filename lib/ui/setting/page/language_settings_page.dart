import 'package:flutter/material.dart';
import 'package:flutter_bloc_app_template/generated/l10n.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app_template/app/lang_helper.dart';
import 'package:flutter_bloc_app_template/bloc/settings/settings_bloc.dart';
import 'package:flutter_bloc_app_template/bloc/settings/settings_event.dart';
import 'package:flutter_bloc_app_template/bloc/settings/settings_states.dart';

class LanguageSettingsPage extends StatelessWidget {
  const LanguageSettingsPage({super.key});
  static const route = '/languageSettings';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).appLanguageTitle),
        elevation: 0,
        scrolledUnderElevation: 3,
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        centerTitle: true,
      ),
      body: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          if (state is! SettingsLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          final settings = state.settings;
          final currentLang = settings.language;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: AppLanguage.values.map((lang) {
              return RadioListTile<AppLanguage>(
                value: lang,
                groupValue: currentLang,
                title: Text(lang.displayName),
                onChanged: (newLang) {
                  if (newLang != null && newLang != currentLang) {
                    final updated = settings.copyWith(language: newLang);
                    context.read<SettingsBloc>().add(UpdateSettings(updated));

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(S.of(context).languageChangedToName(newLang.displayName))),
                    );

                    Navigator.pop(context);
                  }
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }
}