import 'dart:async';
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

  // Garder une référence aux settings actuels pour les mises à jour
  AppSettings? _currentSettings;

  /// Démarre le service de vérification périodique
  Future<void> start(AppSettings settings) async {
    // Sauvegarder les settings actuels
    _currentSettings = settings;

    if (_isRunning) {
      AppLogger.i('GoalCheckService déjà démarré, mise à jour de la configuration');
      // Redémarrer le timer avec la nouvelle fréquence si elle a changé
      _restartTimer(settings);
      return;
    }

    _isRunning = true;
    _startTimer(settings);

    // Effectuer une première vérification immédiatement
    await _performGoalCheck(settings);
  }

  /// Démarre le timer avec les settings fournis
  void _startTimer(AppSettings settings) {
    final frequencyMinutes = settings.checkRatioFrequencyMin;
    AppLogger.i('Démarrage GoalCheckService: vérification toutes les $frequencyMinutes minutes');

    // Annuler le timer précédent si existant
    _checkTimer?.cancel();

    // Créer un nouveau timer périodique
    // IMPORTANT: Le callback utilise _currentSettings pour toujours avoir les derniers settings
    _checkTimer = Timer.periodic(
      Duration(minutes: frequencyMinutes),
      (_) {
        if (_currentSettings != null) {
          _performGoalCheck(_currentSettings!);
        }
      },
    );
  }

  /// Redémarre le timer si la fréquence a changé
  void _restartTimer(AppSettings settings) {
    _checkTimer?.cancel();
    _startTimer(settings);
  }

  /// Arrête le service de vérification
  void stop() {
    if (!_isRunning) return;

    AppLogger.i('Arrêt GoalCheckService');
    _checkTimer?.cancel();
    _checkTimer = null;
    _isRunning = false;
    _currentSettings = null;
  }

  /// Met à jour la configuration
  Future<void> updateConfiguration(AppSettings settings) async {
    _currentSettings = settings;
    AppLogger.i('Configuration GoalCheckService mise à jour: notifications=${settings.notificationsEnabled}, fréquence=${settings.checkRatioFrequencyMin}min');

    if (_isRunning) {
      // Vérifier si la fréquence a changé pour redémarrer le timer
      _restartTimer(settings);
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
    AppLogger.i('_sendSuccessNotification: ratio=$currentRatio, objectif=$goalRatio');

    AppLogger.i('Envoi notification téléphone...');
    await _notificationService.showNotification(
      id: 1,
      title: 'Objectif atteint!',
      body: 'Bravo! Ratio actuel: ${currentRatio.toStringAsFixed(1)}% (objectif: $goalRatio%)',
    );

    // Toujours vibrer pour feedback positif
    AppLogger.i('Déclenchement vibration montre (succès)...');
    AppLogger.i('WatchVibrationService.hasActiveSession: ${_vibrationService.hasActiveSession}');
    await _vibrationService.triggerVibration(
      settings,
      reason: 'objectif_atteint',
      currentRatio: currentRatio,
      goalRatio: goalRatio,
    );
  }

  /// Envoie une notification de rappel
  Future<void> _sendReminderNotification(
    double currentRatio,
    int goalRatio,
    AppSettings settings,
  ) async {
    final gap = goalRatio - currentRatio;
    AppLogger.i('_sendReminderNotification: ratio=$currentRatio, objectif=$goalRatio, gap=$gap');

    AppLogger.i('Envoi notification téléphone...');
    await _notificationService.showNotification(
      id: 2,
      title: 'Objectif en cours',
      body: 'Ratio: ${currentRatio.toStringAsFixed(1)}% - ${gap.toStringAsFixed(1)}% restant pour atteindre $goalRatio%',
    );

    // Toujours envoyer la vibration avec les infos de progression
    AppLogger.i('Déclenchement vibration montre (rappel)...');
    AppLogger.i('WatchVibrationService.hasActiveSession: ${_vibrationService.hasActiveSession}');
    await _vibrationService.triggerVibration(
      settings,
      reason: 'rappel_objectif',
      currentRatio: currentRatio,
      goalRatio: goalRatio,
    );
  }

  /// Getter pour savoir si le service est actif
  bool get isRunning => _isRunning;

  /// Force une vérification immédiate (pour tests/debug)
  Future<void> forceCheck() async {
    if (_currentSettings != null) {
      AppLogger.i('Force check triggered');
      await _performGoalCheck(_currentSettings!);
    } else {
      AppLogger.w('Force check: pas de settings disponibles');
    }
  }

  /// Teste uniquement la vibration sans les conditions (pour debug)
  Future<void> testVibration() async {
    if (_currentSettings != null) {
      AppLogger.i('Test vibration triggered');
      AppLogger.i('Sessions actives: ${_vibrationService.hasActiveSession}');
      await _vibrationService.triggerVibration(_currentSettings!, reason: 'test_manuel');
    } else {
      AppLogger.w('Test vibration: pas de settings disponibles');
    }
  }
}
