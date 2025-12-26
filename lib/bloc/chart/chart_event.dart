import 'package:equatable/equatable.dart';

import '../../models/arm_side.dart';

/// Types de données de graphique disponibles
enum ChartDataType {
  steps,
  battery,
  motionMagnitude,
  activityLevel,
  magnitudeActiveTime,
  axisActiveTime,
  stepsAsymmetry,
  magnitudeAsymmetry,
  axisAsymmetry,
}

/// Événements du ChartBloc
abstract class ChartEvent extends Equatable {
  const ChartEvent();

  @override
  List<Object?> get props => [];
}

/// Charger les données d'un type de graphique
class LoadChartData extends ChartEvent {
  final ChartDataType dataType;
  final String period;
  final DateTime? selectedDate;
  final ArmSide? affectedSide;

  const LoadChartData({
    required this.dataType,
    required this.period,
    this.selectedDate,
    this.affectedSide,
  });

  @override
  List<Object?> get props => [dataType, period, selectedDate, affectedSide];
}

/// Changer la période d'affichage
class ChangePeriod extends ChartEvent {
  final ChartDataType dataType;
  final String newPeriod;

  const ChangePeriod({
    required this.dataType,
    required this.newPeriod,
  });

  @override
  List<Object?> get props => [dataType, newPeriod];
}

/// Rafraîchir toutes les données
class RefreshAllCharts extends ChartEvent {
  const RefreshAllCharts();
}

/// Rafraîchir un type spécifique de données
class RefreshChartData extends ChartEvent {
  final ChartDataType dataType;

  const RefreshChartData(this.dataType);

  @override
  List<Object?> get props => [dataType];
}

/// Invalider le cache d'un type de données
class InvalidateCache extends ChartEvent {
  final ChartDataType? dataType;

  const InvalidateCache([this.dataType]);

  @override
  List<Object?> get props => [dataType];
}

/// Changer le côté affecté (pour les graphiques d'asymétrie)
class ChangeAffectedSide extends ChartEvent {
  final ArmSide side;

  const ChangeAffectedSide(this.side);

  @override
  List<Object?> get props => [side];
}
