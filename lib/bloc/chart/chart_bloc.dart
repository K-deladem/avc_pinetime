import 'dart:async';

import 'package:bloc/bloc.dart';

import '../../models/arm_side.dart';
import '../../service/chart_data_adapter.dart';
import '../../service/chart_refresh_notifier.dart';
import '../../ui/home/chart/reusable_comparison_chart.dart';
import '../../utils/app_logger.dart';
import 'chart_event.dart';
import 'chart_state.dart';

/// ChartBloc - Gestion centralisée des données de graphiques
///
/// Fonctionnalités:
/// - Cache intelligent des données
/// - Rafraîchissement automatique via ChartRefreshNotifier
/// - Gestion des périodes et dates sélectionnées
/// - Support des graphiques de comparaison et d'asymétrie
class ChartBloc extends Bloc<ChartEvent, ChartState> {
  final ChartDataAdapter _adapter = ChartDataAdapter();
  StreamSubscription<ChartRefreshEvent>? _refreshSubscription;

  /// Durée de validité du cache (10 secondes)
  static const Duration _cacheValidityDuration = Duration(seconds: 10);

  ChartBloc() : super(const ChartState()) {
    // Enregistrer les handlers
    on<LoadChartData>(_onLoadChartData);
    on<ChangePeriod>(_onChangePeriod);
    on<RefreshAllCharts>(_onRefreshAllCharts);
    on<RefreshChartData>(_onRefreshChartData);
    on<InvalidateCache>(_onInvalidateCache);
    on<ChangeAffectedSide>(_onChangeAffectedSide);

    // S'abonner aux notifications de rafraîchissement
    _refreshSubscription = ChartRefreshNotifier().stream.listen(_handleRefreshEvent);
  }

  /// Gère les événements de rafraîchissement du ChartRefreshNotifier
  void _handleRefreshEvent(ChartRefreshEvent event) {
    switch (event.type) {
      case ChartRefreshType.movement:
        add(const RefreshChartData(ChartDataType.motionMagnitude));
        add(const RefreshChartData(ChartDataType.activityLevel));
        add(const RefreshChartData(ChartDataType.magnitudeActiveTime));
        add(const RefreshChartData(ChartDataType.axisActiveTime));
        add(const RefreshChartData(ChartDataType.magnitudeAsymmetry));
        add(const RefreshChartData(ChartDataType.axisAsymmetry));
        break;
      case ChartRefreshType.battery:
        add(const RefreshChartData(ChartDataType.battery));
        break;
      case ChartRefreshType.steps:
        add(const RefreshChartData(ChartDataType.steps));
        add(const RefreshChartData(ChartDataType.stepsAsymmetry));
        break;
      case ChartRefreshType.all:
        add(const RefreshAllCharts());
        break;
    }
  }

  /// Vérifie si le cache est encore valide
  bool _isCacheValid(ChartDataState chartState) {
    if (chartState.lastUpdated == null) return false;
    final elapsed = DateTime.now().difference(chartState.lastUpdated!);
    return elapsed < _cacheValidityDuration;
  }

  /// Charge les données d'un type de graphique
  Future<void> _onLoadChartData(
    LoadChartData event,
    Emitter<ChartState> emit,
  ) async {
    final currentState = state.getChartState(event.dataType);

    // Vérifier si le cache est valide et les paramètres identiques
    if (_isCacheValid(currentState) &&
        currentState.period == event.period &&
        currentState.selectedDate == event.selectedDate) {
      AppLogger.debug('Cache hit for ${event.dataType}');
      return;
    }

    // Marquer comme en chargement
    emit(state.withChartData(
      event.dataType,
      currentState.copyWith(isLoading: true, clearError: true),
    ));

    try {
      final affectedSide = event.affectedSide ?? state.affectedSide;

      // Charger les données selon le type
      if (_isAsymmetryType(event.dataType)) {
        final asymmetryData = await _loadAsymmetryData(
          event.dataType,
          event.period,
          event.selectedDate,
          affectedSide,
        );

        emit(state.withChartData(
          event.dataType,
          ChartDataState(
            asymmetryData: asymmetryData,
            period: event.period,
            selectedDate: event.selectedDate,
            isLoading: false,
            lastUpdated: DateTime.now(),
          ),
        ));
      } else {
        final data = await _loadChartData(
          event.dataType,
          event.period,
          event.selectedDate,
        );

        emit(state.withChartData(
          event.dataType,
          ChartDataState(
            data: data,
            period: event.period,
            selectedDate: event.selectedDate,
            isLoading: false,
            lastUpdated: DateTime.now(),
          ),
        ));
      }

      AppLogger.debug('Loaded ${event.dataType} data for ${event.period}');
    } catch (e, stackTrace) {
      AppLogger.error('Error loading ${event.dataType}', e, stackTrace);

      emit(state.withChartData(
        event.dataType,
        currentState.copyWith(
          isLoading: false,
          error: e.toString(),
        ),
      ));
    }
  }

  /// Vérifie si le type est un type d'asymétrie
  bool _isAsymmetryType(ChartDataType type) {
    return type == ChartDataType.stepsAsymmetry ||
        type == ChartDataType.magnitudeAsymmetry ||
        type == ChartDataType.axisAsymmetry;
  }

  /// Charge les données de graphique standard
  Future<List<ChartDataPoint>> _loadChartData(
    ChartDataType type,
    String period,
    DateTime? selectedDate,
  ) async {
    switch (type) {
      case ChartDataType.steps:
        return _adapter.getStepsData(period, selectedDate);
      case ChartDataType.battery:
        return _adapter.getBatteryData(period, selectedDate);
      case ChartDataType.motionMagnitude:
        return _adapter.getMotionMagnitudeData(period, selectedDate);
      case ChartDataType.activityLevel:
        return _adapter.getActivityLevelData(period, selectedDate);
      case ChartDataType.magnitudeActiveTime:
        return _adapter.getMagnitudeActiveTimeData(period, selectedDate);
      case ChartDataType.axisActiveTime:
        return _adapter.getAxisActiveTimeData(period, selectedDate);
      default:
        return [];
    }
  }

  /// Charge les données d'asymétrie
  Future<List<AsymmetryDataPoint>> _loadAsymmetryData(
    ChartDataType type,
    String period,
    DateTime? selectedDate,
    ArmSide affectedSide,
  ) async {
    switch (type) {
      case ChartDataType.stepsAsymmetry:
        return _adapter.getStepsAsymmetry(
          period,
          selectedDate,
          affectedSide: affectedSide,
        );
      case ChartDataType.magnitudeAsymmetry:
        return _adapter.getMagnitudeAsymmetry(
          period,
          selectedDate,
          affectedSide: affectedSide,
        );
      case ChartDataType.axisAsymmetry:
        return _adapter.getAxisAsymmetry(
          period,
          selectedDate,
          affectedSide: affectedSide,
        );
      default:
        return [];
    }
  }

  /// Change la période d'un graphique
  Future<void> _onChangePeriod(
    ChangePeriod event,
    Emitter<ChartState> emit,
  ) async {
    final currentState = state.getChartState(event.dataType);

    // Mettre à jour la période et invalider le cache
    emit(state.withChartData(
      event.dataType,
      currentState.copyWith(
        period: event.newPeriod,
        lastUpdated: null, // Invalider le cache
      ),
    ));

    // Recharger les données avec la nouvelle période
    add(LoadChartData(
      dataType: event.dataType,
      period: event.newPeriod,
      selectedDate: currentState.selectedDate,
    ));
  }

  /// Rafraîchit toutes les données
  Future<void> _onRefreshAllCharts(
    RefreshAllCharts event,
    Emitter<ChartState> emit,
  ) async {
    emit(state.copyWith(isRefreshing: true));

    // Invalider tous les caches
    final newChartData = <ChartDataType, ChartDataState>{};
    for (final entry in state.chartData.entries) {
      newChartData[entry.key] = entry.value.copyWith(lastUpdated: null);
    }
    emit(state.copyWith(chartData: newChartData));

    // Recharger chaque type de données
    for (final entry in state.chartData.entries) {
      add(LoadChartData(
        dataType: entry.key,
        period: entry.value.period,
        selectedDate: entry.value.selectedDate,
      ));
    }

    emit(state.copyWith(isRefreshing: false));
  }

  /// Rafraîchit un type spécifique de données
  Future<void> _onRefreshChartData(
    RefreshChartData event,
    Emitter<ChartState> emit,
  ) async {
    final currentState = state.getChartState(event.dataType);

    // Invalider le cache
    emit(state.withChartData(
      event.dataType,
      currentState.copyWith(lastUpdated: null),
    ));

    // Recharger si des données existent déjà
    if (currentState.hasData) {
      add(LoadChartData(
        dataType: event.dataType,
        period: currentState.period,
        selectedDate: currentState.selectedDate,
      ));
    }
  }

  /// Invalide le cache
  Future<void> _onInvalidateCache(
    InvalidateCache event,
    Emitter<ChartState> emit,
  ) async {
    if (event.dataType != null) {
      // Invalider un type spécifique
      final currentState = state.getChartState(event.dataType!);
      emit(state.withChartData(
        event.dataType!,
        currentState.copyWith(lastUpdated: null),
      ));
    } else {
      // Invalider tout le cache
      final newChartData = <ChartDataType, ChartDataState>{};
      for (final entry in state.chartData.entries) {
        newChartData[entry.key] = entry.value.copyWith(lastUpdated: null);
      }
      emit(state.copyWith(chartData: newChartData));
    }
  }

  /// Change le côté affecté pour les calculs d'asymétrie
  Future<void> _onChangeAffectedSide(
    ChangeAffectedSide event,
    Emitter<ChartState> emit,
  ) async {
    emit(state.copyWith(affectedSide: event.side));

    // Recharger les graphiques d'asymétrie
    for (final type in [
      ChartDataType.stepsAsymmetry,
      ChartDataType.magnitudeAsymmetry,
      ChartDataType.axisAsymmetry,
    ]) {
      final currentState = state.getChartState(type);
      if (currentState.hasData) {
        add(LoadChartData(
          dataType: type,
          period: currentState.period,
          selectedDate: currentState.selectedDate,
          affectedSide: event.side,
        ));
      }
    }
  }

  @override
  Future<void> close() {
    _refreshSubscription?.cancel();
    return super.close();
  }
}
