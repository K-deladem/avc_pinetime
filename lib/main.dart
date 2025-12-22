import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc_app_template/app_runner.dart';
import 'package:flutter_bloc_app_template/config/app_config.dart';
import 'package:flutter_bloc_app_template/config/build_type.dart';
import 'package:flutter_bloc_app_template/config/environment.dart';
import 'package:flutter_bloc_app_template/service/notification_service.dart';
import 'package:flutter_bloc_app_template/utils/app_logger.dart';


void main(List<String> args) async {
  print('Démarrage de l\'application...');

  // Initialisation de Flutter et des services
  WidgetsFlutterBinding.ensureInitialized();
  print('Flutter initialisé');

  // NE PAS démarrer les services en arrière-plan au lancement
  // Ils seront démarrés APRÈS que l'app soit complètement chargée
  // Cela évite les problèmes d'écran noir au démarrage

  // Service de notifications - Initialisation seulement, pas de démarrage
  try {
    print('Initialisation du service de notifications...');
    await NotificationService().initialize();
    AppLogger.i('Service de notifications initialisé');
    print('Service de notifications initialisé');
  } catch (e) {
    AppLogger.e('Erreur initialisation service notifications', error: e);
    print('Erreur service notifications: $e');
  }

  // IMPORTANT: Ne pas démarrer le service background ici
  // Il sera démarré après le chargement complet de l'app
  print('Service background sera démarré après chargement complet');

  print('Initialisation de l\'environnement...');
  Environment.init(
    buildType: BuildType.release,
    config: AppConfig(
      url: '',
    ),
  );
  print('Environnement initialisé');

  print('Lancement de l\'application...');
  run();
}


