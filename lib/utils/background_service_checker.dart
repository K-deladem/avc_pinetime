// lib/utils/background_service_checker.dart

import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_bloc_app_template/utils/app_logger.dart';

/// Utilitaire pour vérifier l'état du service en arrière-plan
class BackgroundServiceChecker {
  /// Vérifie si le service est en cours d'exécution
  static Future<bool> isServiceRunning() async {
    try {
      final service = FlutterBackgroundService();
      return await service.isRunning();
    } catch (e) {
      AppLogger.e('Erreur vérification service', error: e);
      return false;
    }
  }

  /// Affiche les informations de debug du service
  static Future<Map<String, dynamic>> getServiceInfo() async {
    try {
      final service = FlutterBackgroundService();
      final isRunning = await service.isRunning();

      return {
        'isRunning': isRunning,
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      AppLogger.e('Erreur récupération info service', error: e);
      return {
        'isRunning': false,
        'error': e.toString(),
      };
    }
  }

  /// Envoie un ping au service pour vérifier qu'il répond
  static Future<bool> pingService() async {
    try {
      final service = FlutterBackgroundService();
      final isRunning = await service.isRunning();

      if (!isRunning) {
        AppLogger.w('Service non démarré');
        return false;
      }

      // Envoyer un message de test
      service.invoke('ping');
      AppLogger.d('Ping envoyé au service');
      return true;
    } catch (e) {
      AppLogger.e('Erreur ping service', error: e);
      return false;
    }
  }

  /// Log les informations du service
  static Future<void> logServiceStatus() async {
    final info = await getServiceInfo();

    AppLogger.i('=== État du service en arrière-plan ===');
    AppLogger.i('En cours d\'exécution: ${info['isRunning']}');
    AppLogger.i('Timestamp: ${info['timestamp']}');

    if (info.containsKey('error')) {
      AppLogger.e('Erreur: ${info['error']}');
    }

    AppLogger.i('========================================');
  }
}
