// service/chart_refresh_notifier.dart

import 'dart:async';

/// Service singleton pour notifier les graphiques qu'ils doivent se rafraîchir
/// lorsque de nouvelles données sont enregistrées en base de données.
/// OPTIMISÉ: Throttling côté émetteur pour éviter les rafraîchissements trop fréquents
class ChartRefreshNotifier {
  static final ChartRefreshNotifier _instance = ChartRefreshNotifier._internal();
  factory ChartRefreshNotifier() => _instance;
  ChartRefreshNotifier._internal();

  final StreamController<ChartRefreshEvent> _controller =
      StreamController<ChartRefreshEvent>.broadcast();

  // Throttling: éviter d'émettre trop d'événements
  DateTime? _lastMovementNotification;
  DateTime? _lastAllNotification;
  static const Duration _minNotificationInterval = Duration(seconds: 10);

  /// Stream pour écouter les événements de rafraîchissement
  Stream<ChartRefreshEvent> get stream => _controller.stream;

  /// Notifie que les données de mouvement ont été mises à jour
  /// OPTIMISÉ: Throttling pour éviter les notifications trop fréquentes
  void notifyMovementDataUpdated() {
    final now = DateTime.now();
    if (_lastMovementNotification != null &&
        now.difference(_lastMovementNotification!) < _minNotificationInterval) {
      return; // Ignorer si notification trop récente
    }
    _lastMovementNotification = now;
    _controller.add(ChartRefreshEvent(
      type: ChartRefreshType.movement,
      timestamp: now,
    ));
  }

  /// Notifie que les données de batterie ont été mises à jour
  void notifyBatteryDataUpdated() {
    _controller.add(ChartRefreshEvent(
      type: ChartRefreshType.battery,
      timestamp: DateTime.now(),
    ));
  }

  /// Notifie que les données de pas ont été mises à jour
  void notifyStepsDataUpdated() {
    _controller.add(ChartRefreshEvent(
      type: ChartRefreshType.steps,
      timestamp: DateTime.now(),
    ));
  }

  /// Notifie que toutes les données doivent être rafraîchies
  /// OPTIMISÉ: Throttling pour éviter les notifications trop fréquentes
  void notifyAllDataUpdated() {
    final now = DateTime.now();
    if (_lastAllNotification != null &&
        now.difference(_lastAllNotification!) < _minNotificationInterval) {
      return; // Ignorer si notification trop récente
    }
    _lastAllNotification = now;
    _controller.add(ChartRefreshEvent(
      type: ChartRefreshType.all,
      timestamp: now,
    ));
  }

  /// Ferme le stream (à appeler lors de la fermeture de l'application)
  void dispose() {
    _controller.close();
  }
}

/// Types d'événements de rafraîchissement
enum ChartRefreshType {
  movement,
  battery,
  steps,
  all,
}

/// Événement de rafraîchissement des graphiques
class ChartRefreshEvent {
  final ChartRefreshType type;
  final DateTime timestamp;

  ChartRefreshEvent({
    required this.type,
    required this.timestamp,
  });
}
