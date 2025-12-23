// service/chart_refresh_notifier.dart

import 'dart:async';

/// Service singleton pour notifier les graphiques qu'ils doivent se rafraîchir
/// lorsque de nouvelles données sont enregistrées en base de données.
class ChartRefreshNotifier {
  static final ChartRefreshNotifier _instance = ChartRefreshNotifier._internal();
  factory ChartRefreshNotifier() => _instance;
  ChartRefreshNotifier._internal();

  final StreamController<ChartRefreshEvent> _controller =
      StreamController<ChartRefreshEvent>.broadcast();

  /// Stream pour écouter les événements de rafraîchissement
  Stream<ChartRefreshEvent> get stream => _controller.stream;

  /// Notifie que les données de mouvement ont été mises à jour
  void notifyMovementDataUpdated() {
    _controller.add(ChartRefreshEvent(
      type: ChartRefreshType.movement,
      timestamp: DateTime.now(),
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
  void notifyAllDataUpdated() {
    _controller.add(ChartRefreshEvent(
      type: ChartRefreshType.all,
      timestamp: DateTime.now(),
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
