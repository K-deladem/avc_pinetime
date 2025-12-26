import 'package:equatable/equatable.dart';

import '../../models/arm_side.dart';
import '../../service/chart/chart_models.dart';
import '../../ui/home/chart/reusable_comparison_chart.dart';
import 'chart_event.dart';

/// État des données d'un graphique spécifique
class ChartDataState extends Equatable {
  final List<ChartDataPoint> data;
  final List<AsymmetryDataPoint> asymmetryData;
  final String period;
  final DateTime? selectedDate;
  final bool isLoading;
  final String? error;
  final DateTime? lastUpdated;

  const ChartDataState({
    this.data = const [],
    this.asymmetryData = const [],
    this.period = 'Semaine',
    this.selectedDate,
    this.isLoading = false,
    this.error,
    this.lastUpdated,
  });

  bool get hasData => data.isNotEmpty || asymmetryData.isNotEmpty;
  bool get hasError => error != null;

  ChartDataState copyWith({
    List<ChartDataPoint>? data,
    List<AsymmetryDataPoint>? asymmetryData,
    String? period,
    DateTime? selectedDate,
    bool? isLoading,
    String? error,
    DateTime? lastUpdated,
    bool clearError = false,
  }) {
    return ChartDataState(
      data: data ?? this.data,
      asymmetryData: asymmetryData ?? this.asymmetryData,
      period: period ?? this.period,
      selectedDate: selectedDate ?? this.selectedDate,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  List<Object?> get props => [
        data,
        asymmetryData,
        period,
        selectedDate,
        isLoading,
        error,
        lastUpdated,
      ];
}

/// État global du ChartBloc
class ChartState extends Equatable {
  /// Données par type de graphique
  final Map<ChartDataType, ChartDataState> chartData;

  /// Côté affecté pour les calculs d'asymétrie
  final ArmSide affectedSide;

  /// Indique si un rafraîchissement global est en cours
  final bool isRefreshing;

  const ChartState({
    this.chartData = const {},
    this.affectedSide = ArmSide.left,
    this.isRefreshing = false,
  });

  /// Obtenir l'état d'un type de graphique spécifique
  ChartDataState getChartState(ChartDataType type) {
    return chartData[type] ?? const ChartDataState();
  }

  /// Vérifier si un type de graphique est en chargement
  bool isLoading(ChartDataType type) {
    return chartData[type]?.isLoading ?? false;
  }

  /// Obtenir les données d'un type de graphique
  List<ChartDataPoint> getData(ChartDataType type) {
    return chartData[type]?.data ?? [];
  }

  /// Obtenir les données d'asymétrie d'un type de graphique
  List<AsymmetryDataPoint> getAsymmetryData(ChartDataType type) {
    return chartData[type]?.asymmetryData ?? [];
  }

  /// Obtenir la période actuelle d'un type de graphique
  String getPeriod(ChartDataType type) {
    return chartData[type]?.period ?? 'Semaine';
  }

  ChartState copyWith({
    Map<ChartDataType, ChartDataState>? chartData,
    ArmSide? affectedSide,
    bool? isRefreshing,
  }) {
    return ChartState(
      chartData: chartData ?? this.chartData,
      affectedSide: affectedSide ?? this.affectedSide,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }

  /// Met à jour l'état d'un type de graphique spécifique
  ChartState withChartData(ChartDataType type, ChartDataState state) {
    final newChartData = Map<ChartDataType, ChartDataState>.from(chartData);
    newChartData[type] = state;
    return copyWith(chartData: newChartData);
  }

  @override
  List<Object?> get props => [chartData, affectedSide, isRefreshing];
}
