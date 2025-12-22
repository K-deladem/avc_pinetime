import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc_app_template/app_runner.dart';
import 'package:flutter_bloc_app_template/config/app_config.dart';
import 'package:flutter_bloc_app_template/config/build_type.dart';
import 'package:flutter_bloc_app_template/config/environment.dart';
import 'package:flutter_bloc_app_template/service/background_infinitime_service.dart';
import 'package:flutter_bloc_app_template/service/notification_service.dart';
import 'package:flutter_bloc_app_template/utils/app_logger.dart';


void main(List<String> args) async {

  // Initialisation de Flutter et des services
  WidgetsFlutterBinding.ensureInitialized();

  // Service de notifications - DOIT être initialisé avant tout
  try {
    await NotificationService().initialize();
    AppLogger.i('Service de notifications initialisé');
  } catch (e) {
    AppLogger.e(' Erreur initialisation service notifications', error: e);
  }

  // Service de collecte en arrière-plan - fonctionne sur Android et iOS
  try {
    await BackgroundInfiniTimeService.initialize();
    await BackgroundInfiniTimeService.start();
    AppLogger.i('Service de collecte en arrière-plan démarré');
  } catch (e) {
    AppLogger.e(' Erreur démarrage service background', error: e);
  }

  Environment.init(
    buildType: BuildType.release,
    config: AppConfig(
      url: '',
    ),
  );
  run();
}


