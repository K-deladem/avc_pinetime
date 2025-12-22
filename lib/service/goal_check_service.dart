import 'dart:async';
import 'package:flutter_bloc_app_template/extension/notification_strategy.dart';
import 'package:flutter_bloc_app_template/models/app_settings.dart';
import 'package:flutter_bloc_app_template/service/goal_calculator_service.dart';
import 'package:flutter_bloc_app_template/service/notification_service.dart';
import 'package:flutter_bloc_app_template/service/watch_vibration_service.dart';
import 'package:flutter_bloc_app_template/utils/app_logger.dart';

/// Service qui vérifie périodiquement si l'objectif d'équilibre est atteint
/// et déclenche des notifications/vibrations selon la configuration
class GoalCheckService {
  static final GoalCheckService _instance = GoalCheckService._internal();
  factory GoalCheckService() => _instance;
  GoalCheckService._internal();

  Timer? _checkTimer;
  final GoalCalculatorService _goalCalculator = GoalCalculatorService();
  final NotificationService _notificationService = NotificationService();
  final WatchVibrationService _vibrationService = WatchVibrationService();

  bool _isRunning = false;

  /// Démarre le service de vérification périodique
  Future<void> start(AppSettings settings) async {
    if (_isRunning) {
      AppLogger.w('GoalCheckService déjà démarré');
      return;
    }

    _isRunning = true;
    final frequencyMinutes = settings.checkRatioFrequencyMin;

    AppLogger.i('Démarrage GoalCheckService: vérification toutes les $frequencyMinutes minutes');

    // Annuler le timer précédent si existant
    _checkTimer?.cancel();

    // Créer un nouveau timer périodique
    _checkTimer = Timer.periodic(
      Duration(minutes: frequencyMinutes),
      (_) => _performGoalCheck(settings),
    );

    // Effectuer une première vérification immédiatement
    await _performGoalCheck(settings);
  }

  /// Arrête le service de vérification
  void stop() {
    if (!_isRunning) return;

    AppLogger.i('Arrêt GoalCheckService');
    _checkTimer?.cancel();
    _checkTimer = null;
    _isRunning = false;
  }

  /// Met à jour la configuration sans redémarrer
  Future<void> updateConfiguration(AppSettings settings) async {
    if (_isRunning) {
      await start(settings); // Redémarre avec la nouvelle config
    }
  }

  /// Effectue une vérification de l'objectif
  Future<void> _performGoalCheck(AppSettings settings) async {
    try {
      AppLogger.i('Vérification de l\'objectif...');

      // Si les notifications sont désactivées, ne rien faire
      if (!settings.notificationsEnabled) {
        AppLogger.i('Notifications désactivées, vérification ignorée');
        return;
      }

      // Calculer l'objectif selon la configuration (utilise le service partagé)
      final goalRatio = await _goalCalculator.calculateGoalFromSettings(settings);

      // Obtenir le ratio actuel depuis les données (utilise le service partagé)
      final currentRatio = await _goalCalculator.getCurrentRatio(settings);

      AppLogger.i('Objectif: $goalRatio%, Actuel: ${currentRatio.toStringAsFixed(1)}%');

      // Vérifier si l'objectif est atteint
      if (currentRatio >= goalRatio) {
        AppLogger.i('Objectif atteint!');
        await _sendSuccessNotification(currentRatio, goalRatio, settings);
      } else {
        AppLogger.i('Objectif non atteint');
        await _sendReminderNotification(currentRatio, goalRatio, settings);
      }
    } catch (e) {
      AppLogger.e('Erreur lors de la vérification de l\'objectif', error: e);
    }
  }

  /// Envoie une notification de succès
  Future<void> _sendSuccessNotification(
    double currentRatio,
    int goalRatio,
    AppSettings settings,
  ) async {
    final strategy = settings.notificationStrategy;

    // Notification discrète: ne notifier que si largement dépassé
    if (strategy.label == 'Discrète' && currentRatio < goalRatio * 1.1) {
      return;
    }

    await _notificationService.showNotification(
      id: 1,
      title: 'Objectif atteint!',
      body: 'Excellent! Ratio actuel: ${currentRatio.toStringAsFixed(1)}% (objectif: $goalRatio%)',
    );

    // Vibration optionnelle selon la stratégie (succès = vibration légère)
    if (strategy.label == 'Agressive') {
      await _vibrationService.triggerVibration(settings, reason: 'objectif_atteint');
    }
  }

  /// Envoie une notification de rappel
  Future<void> _sendReminderNotification(
    double currentRatio,
    int goalRatio,
    AppSettings settings,
  ) async {
    final strategy = settings.notificationStrategy;
    final gap = goalRatio - currentRatio;

    // Stratégie discrète: ne rappeler que si très loin de l'objectif
    if (strategy.label == 'Discrète' && gap < goalRatio * 0.3) {
      return;
    }

    // Stratégie équilibrée: rappeler si modérément loin
    if (strategy.label == 'Équilibrée' && gap < goalRatio * 0.15) {
      return;
    }

    // Stratégie agressive: toujours rappeler

    String urgencyLevel = 'Rappel';
    if (gap > goalRatio * 0.5) {
      urgencyLevel = 'Attention';
    } else if (gap > goalRatio * 0.3) {
      urgencyLevel = 'Important';
    }

    await _notificationService.showNotification(
      id: 2,
      title: '$urgencyLevel - Objectif',
      body: 'Ratio actuel: ${currentRatio.toStringAsFixed(1)}% - Objectif: $goalRatio% (${gap.toStringAsFixed(1)}% restant)',
    );

    // Vibration selon la stratégie et l'écart
    if (strategy.label == 'Agressive' || gap > goalRatio * 0.4) {
      await _vibrationService.triggerVibration(settings, reason: 'rappel_objectif');
    }
  }

  /// Getter pour savoir si le service est actif
  bool get isRunning => _isRunning;
}
