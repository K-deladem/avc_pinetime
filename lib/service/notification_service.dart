import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_bloc_app_template/routes/app_routes.dart';
import 'package:flutter_bloc_app_template/routes/router.dart';
import 'package:flutter_bloc_app_template/utils/app_logger.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
      onDidReceiveBackgroundNotificationResponse: _onBackgroundNotificationTapped,
    );

    _isInitialized = true;
    AppLogger.i('Service de notifications initialisé');
  }

  /// Gère le clic sur une notification quand l'app est en foreground ou en background
  void _onNotificationTapped(NotificationResponse response) {
    AppLogger.i('Notification cliquée: ${response.payload}');
    _handleNotificationNavigation(response.payload);
  }

  /// Gère le clic sur une notification quand l'app était complètement fermée
  @pragma('vm:entry-point')
  static void _onBackgroundNotificationTapped(NotificationResponse response) {
    AppLogger.i('Notification cliquée (background): ${response.payload}');
    // La navigation sera gérée lors de l'ouverture de l'app
    _handleNotificationNavigation(response.payload);
  }

  /// Navigation basée sur le payload de la notification
  static void _handleNotificationNavigation(String? payload) {
    if (payload == null || payload.isEmpty) {
      // Par défaut, naviguer vers l'écran principal
      _navigateToRoute(AppRoutes.app);
      return;
    }

    // Parser le payload pour déterminer où naviguer
    // Format attendu: "route|arguments"
    final parts = payload.split('|');
    final route = parts.isNotEmpty ? parts[0] : AppRoutes.app;

    _navigateToRoute(route);
  }

  static void _navigateToRoute(String route) {
    final context = appNavigatorKey.currentContext;
    if (context != null) {
      // Utiliser le NavigationService pour naviguer
      appNavigatorKey.currentState?.pushNamed(route);
      AppLogger.i('Navigation vers: $route');
    } else {
      AppLogger.w('Impossible de naviguer: contexte non disponible');
      // Si le contexte n'est pas disponible, on attend un peu et réessaie
      Future.delayed(const Duration(milliseconds: 500), () {
        final retryContext = appNavigatorKey.currentContext;
        if (retryContext != null) {
          appNavigatorKey.currentState?.pushNamed(route);
          AppLogger.i('Navigation vers: $route (après délai)');
        }
      });
    }
  }

  /// Affiche une notification locale
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    String channelId = 'default_channel',
    String channelName = 'Notifications par défaut',
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: 'Canal pour les notifications de l\'application',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload ?? AppRoutes.app,
    );

    AppLogger.i('Notification affichée: $title');
  }

  /// Annule une notification spécifique
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  /// Annule toutes les notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }
}
