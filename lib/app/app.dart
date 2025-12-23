import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app_template/app/lang_helper.dart';
import 'package:flutter_bloc_app_template/app/theme_helper.dart';
import 'package:flutter_bloc_app_template/service/background_infinitime_service.dart';
import 'package:flutter_bloc_app_template/service/firmware_source.dart';
import 'package:flutter_bloc_app_template/service/goal_check_service.dart';
import 'package:flutter_bloc_app_template/bloc/infinitime/dual_infinitime_bloc.dart';
import 'package:flutter_bloc_app_template/bloc/infinitime/dual_infinitime_event.dart';
import 'package:flutter_bloc_app_template/bloc/init/init_bloc.dart';
import 'package:flutter_bloc_app_template/bloc/settings/settings_bloc.dart';
import 'package:flutter_bloc_app_template/bloc/settings/settings_event.dart';
import 'package:flutter_bloc_app_template/bloc/settings/settings_repository.dart';
import 'package:flutter_bloc_app_template/bloc/settings/settings_states.dart';
import 'package:flutter_bloc_app_template/bloc/watch/watch_bloc.dart';
import 'package:flutter_bloc_app_template/bloc/watch/watch_event.dart';
import 'package:flutter_bloc_app_template/bloc/watch/watch_repository.dart';
import 'package:flutter_bloc_app_template/generated/l10n.dart';
import 'package:flutter_bloc_app_template/index.dart';
import 'package:flutter_bloc_app_template/routes/app_routes.dart';
import 'package:flutter_bloc_app_template/ui/splash/splash_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:infinitime_dfu_library/infinitime_dfu_library.dart';
import 'package:permission_handler/permission_handler.dart';

import 'app_database.dart';

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final watchRepository = WatchRepository();
  final ble = FlutterReactiveBle();
  final firmwareManager = FirmwareManager(FirmwareSource());

  // Variable pour éviter les rechargements en boucle
  static int _retryCount = 0;
  static const int _maxRetries = 3;

  // Variable pour éviter de démarrer plusieurs fois les services
  static bool _servicesStarted = false;

  // Variable pour éviter de demander les permissions plusieurs fois
  static bool _permissionsRequested = false;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (_) => NavigationService()),
        RepositoryProvider<WatchRepository>(create: (_) => watchRepository),
        RepositoryProvider<FlutterReactiveBle>.value(value: ble),
        RepositoryProvider<FirmwareManager>.value(value: firmwareManager),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<InitBloc>(
              create: (_) => InitBloc()..add(StartAppEvent())),
          BlocProvider<WatchBloc>(
              create: (_) =>
                  WatchBloc(watchRepository)..add(LoadWatchDevices())),
          BlocProvider<SettingsBloc>(
              create: (_) =>
                  SettingsBloc(SettingsRepositoryImpl())..add(LoadSettings())),
          BlocProvider<DualInfiniTimeBloc>(
            create: (ctx) {
              if (kDebugMode) {
                print(' Création du DualInfiniTimeBloc...');
              }
              final bloc = DualInfiniTimeBloc(ctx.read<FlutterReactiveBle>());
              // Charger les bindings après un court délai pour ne pas bloquer le rendu
              Future.delayed(const Duration(milliseconds: 100), () {
                if (kDebugMode) {
                  print('Chargement des bindings...');
                }
                bloc.add(DualLoadBindingsRequested());
              });
              return bloc;
            },
          )
        ],
        child: Builder(
          builder: (context) {
            final navigator = NavigationService.of(context);
            // Demander les permissions une seule fois, de manière asynchrone
            if (!_permissionsRequested) {
              _permissionsRequested = true;
              Future.microtask(() => _requestPermissions());
            }

            return BlocBuilder<SettingsBloc, SettingsState>(
              buildWhen: (previous, current) {
                // Rebuild when settings are loaded OR when there's an error
                return current is SettingsLoaded || current is SettingsError;
              },
              builder: (context, state) {

                // Gestion des erreurs: charger les paramètres par défaut
                if (state is SettingsError) {
                  if (kDebugMode) {
                    print('Erreur chargement settings: ${state.message}');
                    print('Tentative n°${_retryCount + 1}/$_maxRetries');
                  }

                  // Limiter le nombre de tentatives pour éviter la boucle infinie
                  if (_retryCount < _maxRetries) {
                    _retryCount++;
                    // Recharger avec les paramètres par défaut
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (kDebugMode) {
                        print('Tentative de rechargement des settings...');
                      }
                      context.read<SettingsBloc>().add(LoadSettings());
                    });
                  } else {
                    // Après 3 tentatives, forcer l'utilisation des paramètres par défaut
                    if (kDebugMode) {
                      print('Nombre max de tentatives atteint, utilisation des paramètres par défaut');
                    }
                    final defaultSettings = AppDatabase.defaultSettings;
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      context.read<SettingsBloc>().add(UpdateSettings(defaultSettings));
                    });
                  }

                  return const MaterialApp(
                      debugShowCheckedModeBanner: false, home: SplashScreen());
                }

                if (state is! SettingsLoaded) {
                  return const MaterialApp(
                      debugShowCheckedModeBanner: false, home: SplashScreen());
                }

                final settings = state.settings;

                // Mettre à jour la configuration du DualInfiniTimeBloc quand les settings changent
                context
                    .read<DualInfiniTimeBloc>()
                    .updateConfiguration(settings);

                // Démarrer les services en arrière-plan de manière différée
                // pour ne pas bloquer le rendu de l'UI
                if (!_servicesStarted) {
                  _servicesStarted = true; // Marquer immédiatement pour éviter les appels multiples
                  Future.delayed(const Duration(milliseconds: 500), () {
                    _startBackgroundServices();
                    GoalCheckService().start(settings);
                  });
                }

                // Sécurise les valeurs pour éviter les crash
                final themeEnum = settings.themeMode;
                final languageCode = settings.language.code;
                final themeMode = ThemeHelper.getThemeMode(themeEnum);
                final lightTheme = ThemeHelper.getLightTheme(themeEnum);
                final darkTheme = ThemeHelper.getDarkTheme(themeEnum);

                // Determine initial route based on whether this is first launch
                final initialRoute = settings.isFirstLaunch
                    ? AppRoutes.onboarding
                    : AppRoutes.app;

                return MaterialApp(
                  debugShowCheckedModeBanner: kDebugMode,
                  locale: Locale(languageCode),
                  themeMode: themeMode,
                  theme: lightTheme,
                  darkTheme: darkTheme,
                  navigatorKey: appNavigatorKey,
                  onGenerateRoute: navigator.onGenerateRoute,
                  initialRoute: initialRoute,
                  localizationsDelegates: const [
                    S.delegate,
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                  ],
                  supportedLocales:
                      AppLanguage.values.map((e) => e.locale).toList(),
                  onGenerateTitle: (context) => S.of(context).appTitle,
                  builder: (_, child) => BlocListener<InitBloc, InitState>(
                    listener: (_, state) {
                      if (state is OpenApp) {
                        // Ne pas naviguer automatiquement si c'est le premier lancement
                        // L'écran d'onboarding est déjà affiché via initialRoute
                        if (!settings.isFirstLaunch) {
                          navigator.pushAndRemoveAll(AppRoutes.app);
                        }
                      }
                    },
                    child: child,
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Future<void> _startBackgroundServices() async {
    try {
      await BackgroundInfiniTimeService.initialize();
      await BackgroundInfiniTimeService.start();
    } catch (e) {
      if (kDebugMode) {
        print('Erreur démarrage services background: $e');
      }
    }
  }

  Future<void> _requestPermissions() async {
    print('Demande des permissions...');

    // Permissions de base
    final permissions = [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.bluetoothAdvertise,
      Permission.locationWhenInUse,
    ];

    // Ajouter notification pour Android 13+
    if (await Permission.notification.isDenied) {
      permissions.add(Permission.notification);
    }

    final statuses = await permissions.request();

    // Afficher le résultat
    for (final permission in permissions) {
      final status = statuses[permission];
      print('Permission $permission: $status');
    }

    // Optimisation batterie (optionnel pour Xiaomi)
    try {
      await Permission.ignoreBatteryOptimizations.request();
    } catch (e) {
      print('Optimisation batterie non disponible: $e');
    }
  }
}
