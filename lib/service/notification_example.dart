// Exemple d'utilisation du NotificationService
// Ce fichier montre comment envoyer des notifications qui navigueront correctement

import 'package:flutter_bloc_app_template/routes/app_routes.dart';
import 'package:flutter_bloc_app_template/service/notification_service.dart';

class NotificationExamples {
  final _notificationService = NotificationService();

  /// Exemple 1: Notification simple qui ouvre l'écran principal
  Future<void> showSimpleNotification() async {
    await _notificationService.showNotification(
      id: 1,
      title: 'Nouvelle notification',
      body: 'Cliquez pour ouvrir l\'application',
      payload: AppRoutes.app, // Ouvrira l'écran principal
    );
  }

  /// Exemple 2: Notification pour ouvrir les paramètres de profil
  Future<void> showProfileNotification() async {
    await _notificationService.showNotification(
      id: 2,
      title: 'Profil mis à jour',
      body: 'Vos paramètres de profil ont été modifiés',
      payload: AppRoutes.profile, // Ouvrira l'écran de profil
    );
  }

  /// Exemple 3: Notification pour une montre spécifique
  Future<void> showWatchNotification({required bool isLeftWatch}) async {
    await _notificationService.showNotification(
      id: 3,
      title: 'Montre déconnectée',
      body: 'La montre ${isLeftWatch ? "gauche" : "droite"} s\'est déconnectée',
      payload: isLeftWatch ? AppRoutes.watchLeft : AppRoutes.watchRight,
      channelId: 'watch_channel',
      channelName: 'Notifications montres',
    );
  }

  /// Exemple 4: Notification de connexion Bluetooth
  Future<void> showBluetoothNotification() async {
    await _notificationService.showNotification(
      id: 4,
      title: 'Bluetooth',
      body: 'Problème de connexion Bluetooth détecté',
      payload: AppRoutes.bluetoothSettings,
      channelId: 'bluetooth_channel',
      channelName: 'Notifications Bluetooth',
    );
  }

  /// Exemple 5: Notification de collecte de données
  Future<void> showDataCollectionNotification() async {
    await _notificationService.showNotification(
      id: 5,
      title: 'Collecte de données',
      body: 'Nouvelles données collectées depuis vos montres',
      payload: AppRoutes.app, // Ouvre l'écran principal pour voir les données
      channelId: 'data_channel',
      channelName: 'Collecte de données',
    );
  }

  /// Annuler une notification spécifique
  Future<void> cancelNotification(int id) async {
    await _notificationService.cancelNotification(id);
  }

  /// Annuler toutes les notifications
  Future<void> cancelAllNotifications() async {
    await _notificationService.cancelAllNotifications();
  }
}
