import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app_template/bloc/settings/settings_bloc.dart';
import 'package:flutter_bloc_app_template/bloc/settings/settings_states.dart';

class ProfileHeader extends StatelessWidget {
  final VoidCallback? onNotificationPressed;
  final String titleText;
  final String subtitleText;
  final VoidCallback? onSearchPressed;

  const ProfileHeader({
    super.key,
    this.onNotificationPressed,
    this.titleText = "Prêt à franchir les prochaines étapes de votre réadaptation?",
    this.subtitleText = "Chaque jour compte 😊 !",
    this.onSearchPressed,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        // Valeurs par défaut
        String userName = "Utilisateur";
        String? profileImagePath;

        if (state is SettingsLoaded) {
          userName = state.settings.userName;
          profileImagePath = state.settings.profileImagePath;
        }

        // OPTIMISÉ: Pas de File.existsSync() bloquant
        // On laisse Image.file avec errorBuilder gérer les fichiers manquants
        final hasImagePath = profileImagePath != null && profileImagePath.isNotEmpty;

    return SliverAppBar(
      backgroundColor: Theme.of(context).colorScheme.background,
      elevation: 0,
      floating: true,
      automaticallyImplyLeading: false,
      expandedHeight: 130,
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.none,
        background: Padding(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top ,
            left: 20,
            right: 20,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RichText(
                      text: TextSpan(
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                        children: [
                          TextSpan(
                            text: "Bonjour! ",
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.7),
                              fontSize: 22,
                            ),
                          ),
                          TextSpan(
                            text: userName,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                           TextSpan(text: " 👋",
                              style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),),
                        ],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      titleText,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500, fontSize: 12
                          ),
                    ),
                    Text(
                      subtitleText,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.color
                                ?.withOpacity(0.7),
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                height: 70,
                width: 70,
                child: CircleAvatar(
                  backgroundColor: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.6),
                  child: ClipOval(
                    child: hasImagePath
                        ? Image.file(
                            File(profileImagePath!),
                            fit: BoxFit.cover,
                            width: 55,
                            height: 55,
                            errorBuilder: (context, error, stackTrace) {
                              return defaultAvatar();
                            },
                          )
                        : defaultAvatar(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
      },
    );
  }

  Widget defaultAvatar() {
    return const SizedBox(
        height: 50,
        width: 50,
        child: CircleAvatar(
          backgroundColor: Colors.amber,
          child: ClipOval(
            child: Icon(Icons.person_outlined, size: 30, color: Colors.white),
          ),
        ));
  }
}

