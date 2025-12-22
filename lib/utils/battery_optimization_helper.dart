// lib/utils/battery_optimization_helper.dart

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'app_logger.dart';

/// Helper pour gérer l'optimisation de la batterie et maintenir le service actif
class BatteryOptimizationHelper {
  /// Demande de désactiver l'optimisation de la batterie
  static Future<bool> requestDisableBatteryOptimization(BuildContext context) async {
    try {
      final status = await Permission.ignoreBatteryOptimizations.status;

      if (status.isGranted) {
        AppLogger.i('Optimisation batterie déjà désactivée');
        return true;
      }

      // Afficher un dialogue explicatif
      final shouldRequest = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Optimisation de la batterie'),
          content: const Text(
            'Pour permettre à l\'application de collecter les données en arrière-plan, '
            'même lorsque l\'appareil est en veille, nous devons désactiver '
            'l\'optimisation de la batterie pour cette application.\n\n'
            'Cela permettra:\n'
            '• La collecte continue des données\n'
            '• La reconnexion automatique aux montres\n'
            '• Le fonctionnement au démarrage de l\'appareil',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Autoriser'),
            ),
          ],
        ),
      );

      if (shouldRequest == true) {
        final result = await Permission.ignoreBatteryOptimizations.request();

        if (result.isGranted) {
          AppLogger.i('Permission d\'ignorer l\'optimisation batterie accordée');
          return true;
        } else {
          AppLogger.w('Permission d\'ignorer l\'optimisation batterie refusée');
          return false;
        }
      }

      return false;
    } catch (e) {
      AppLogger.e('Erreur lors de la demande d\'optimisation batterie', error: e);
      return false;
    }
  }

  /// Vérifie si l'optimisation de la batterie est désactivée
  static Future<bool> isBatteryOptimizationDisabled() async {
    try {
      final status = await Permission.ignoreBatteryOptimizations.status;
      return status.isGranted;
    } catch (e) {
      AppLogger.e('Erreur lors de la vérification de l\'optimisation batterie', error: e);
      return false;
    }
  }

  /// Affiche une notification pour rappeler à l'utilisateur de désactiver l'optimisation
  static Future<void> showBatteryOptimizationReminder(BuildContext context) async {
    final isDisabled = await isBatteryOptimizationDisabled();

    if (!isDisabled && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Pour une collecte de données continue, '
            'désactivez l\'optimisation de la batterie',
          ),
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'Configurer',
            onPressed: () => requestDisableBatteryOptimization(context),
          ),
        ),
      );
    }
  }
}
