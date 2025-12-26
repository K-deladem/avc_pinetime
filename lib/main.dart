import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc_app_template/app_runner.dart';
import 'package:flutter_bloc_app_template/config/app_config.dart';
import 'package:flutter_bloc_app_template/config/build_type.dart';
import 'package:flutter_bloc_app_template/config/environment.dart';
import 'package:flutter_bloc_app_template/core/di/injection_container.dart';
import 'package:flutter_bloc_app_template/service/notification_service.dart';
import 'package:flutter_bloc_app_template/utils/app_logger.dart';


void main(List<String> args) async {
  // Initialisation de Flutter
  WidgetsFlutterBinding.ensureInitialized();

  // Initialiser l'environnement (synchrone, rapide)
  Environment.init(
    buildType: BuildType.release,
    config: AppConfig(
      url: '',
    ),
  );

  // Initialiser l'injection de dépendances
  await initDependencies();

  // Lancer l'app immédiatement, les services seront initialisés après
  run();

  // Initialiser le service de notifications en arrière-plan (non-bloquant)
  Future.microtask(() async {
    try {
      await NotificationService().initialize();
    } catch (e) {
      AppLogger.e('Erreur initialisation service notifications', error: e);
    }
  });
}


