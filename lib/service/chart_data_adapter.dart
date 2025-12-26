// service/chart_data_adapter.dart
//
// REFACTORISÉ: La logique lourde est maintenant dans les modules chart/:
// - chart/period_helper.dart - Calculs de périodes
// - chart/data_aggregator.dart - Agrégation des données
// - chart/asymmetry_calculator.dart - Calculs d'asymétrie
// - chart/data_normalizer.dart - Normalisation des points
// - chart/chart_models.dart - Modèles (AsymmetryDataPoint, AsymmetryCategory)

import 'package:flutter_bloc_app_template/app/app_database.dart';
import 'package:flutter_bloc_app_template/models/arm_side.dart';
import 'package:flutter_bloc_app_template/ui/home/chart/reusable_comparison_chart.dart';

import 'chart/asymmetry_calculator.dart';
import 'chart/chart_models.dart';
import 'chart/data_aggregator.dart';
import 'chart/data_normalizer.dart';
import 'chart/period_helper.dart';

// Re-export pour compatibilité avec le code existant
export 'chart/chart_models.dart';

/// Service d'adaptation pour convertir les données DB en données pour graphiques
///
/// Ce service facilite l'utilisation du ReusableComparisonChart en fournissant
/// des méthodes prêtes à l'emploi pour chaque type de capteur
class ChartDataAdapter {
  final AppDatabase _db = AppDatabase.instance;

  // ========== ADAPTATEURS PAR TYPE ==========

  /// Adaptateur pour les PAS (steps)
  Future<List<ChartDataPoint>> getStepsData(
    String period,
    DateTime? selectedDate,
  ) async {
    final start = PeriodHelper.getStartDate(period, selectedDate);
    final end = PeriodHelper.getEndDate(period, selectedDate);

    final results = await Future.wait([
      _db.getDeviceInfo('left', 'steps', startDate: start, endDate: end, limit: 1000),
      _db.getDeviceInfo('right', 'steps', startDate: start, endDate: end, limit: 1000),
    ]);

    return DataAggregator.aggregateStepsData(results[0], results[1], period);
  }

  /// Adaptateur pour la BATTERIE
  Future<List<ChartDataPoint>> getBatteryData(
    String period,
    DateTime? selectedDate,
  ) async {
    final start = PeriodHelper.getStartDate(period, selectedDate);
    final end = PeriodHelper.getEndDate(period, selectedDate);

    final results = await Future.wait([
      _db.getDeviceInfo('left', 'battery', startDate: start, endDate: end, limit: 1000),
      _db.getDeviceInfo('right', 'battery', startDate: start, endDate: end, limit: 1000),
    ]);

    return DataAggregator.aggregateBatteryData(results[0], results[1], period);
  }

  /// Adaptateur pour MOTION MAGNITUDE
  Future<List<ChartDataPoint>> getMotionMagnitudeData(
    String period,
    DateTime? selectedDate,
  ) async {
    final start = PeriodHelper.getStartDate(period, selectedDate);
    final end = PeriodHelper.getEndDate(period, selectedDate);

    final results = await Future.wait([
      _db.getMovementData('left', startDate: start, endDate: end, limit: 1000),
      _db.getMovementData('right', startDate: start, endDate: end, limit: 1000),
    ]);

    return DataAggregator.aggregateMovementData(results[0], results[1], period, 'magnitude');
  }

  /// Adaptateur pour ACTIVITY LEVEL
  Future<List<ChartDataPoint>> getActivityLevelData(
    String period,
    DateTime? selectedDate,
  ) async {
    final start = PeriodHelper.getStartDate(period, selectedDate);
    final end = PeriodHelper.getEndDate(period, selectedDate);

    final results = await Future.wait([
      _db.getMovementData('left', startDate: start, endDate: end, limit: 1000),
      _db.getMovementData('right', startDate: start, endDate: end, limit: 1000),
    ]);

    return DataAggregator.aggregateMovementData(results[0], results[1], period, 'activityLevel');
  }

  /// Adaptateur pour MAGNITUDE ACTIVE TIME
  Future<List<ChartDataPoint>> getMagnitudeActiveTimeData(
    String period,
    DateTime? selectedDate,
  ) async {
    final start = PeriodHelper.getStartDate(period, selectedDate);
    final end = PeriodHelper.getEndDate(period, selectedDate);

    final results = await Future.wait([
      _db.getMovementData('left', startDate: start, endDate: end, limit: 1000),
      _db.getMovementData('right', startDate: start, endDate: end, limit: 1000),
    ]);

    return DataAggregator.aggregateMovementData(results[0], results[1], period, 'magnitudeActiveTime');
  }

  /// Adaptateur pour AXIS ACTIVE TIME
  Future<List<ChartDataPoint>> getAxisActiveTimeData(
    String period,
    DateTime? selectedDate,
  ) async {
    final start = PeriodHelper.getStartDate(period, selectedDate);
    final end = PeriodHelper.getEndDate(period, selectedDate);

    final results = await Future.wait([
      _db.getMovementData('left', startDate: start, endDate: end, limit: 1000),
      _db.getMovementData('right', startDate: start, endDate: end, limit: 1000),
    ]);

    return DataAggregator.aggregateMovementData(results[0], results[1], period, 'axisActiveTime');
  }

  // ========== ADAPTATEURS POUR ASYMÉTRIE ==========

  /// Adaptateur pour ASYMÉTRIE DES PAS
  Future<List<AsymmetryDataPoint>> getStepsAsymmetry(
    String period,
    DateTime? selectedDate, {
    ArmSide affectedSide = ArmSide.left,
  }) async {
    final start = PeriodHelper.getStartDate(period, selectedDate);
    final end = PeriodHelper.getEndDate(period, selectedDate);

    final results = await Future.wait([
      _db.getDeviceInfo('left', 'steps', startDate: start, endDate: end, limit: 1000),
      _db.getDeviceInfo('right', 'steps', startDate: start, endDate: end, limit: 1000),
    ]);

    return AsymmetryCalculator.aggregateFromDeviceInfo(
      results[0],
      results[1],
      period,
      (data) => data.value.toDouble(),
      affectedSide,
    );
  }

  /// Adaptateur pour ASYMÉTRIE MAGNITUDE ACTIVE TIME (pour graphique area)
  Future<List<AsymmetryDataPoint>> getMagnitudeAsymmetry(
    String period,
    DateTime? selectedDate, {
    ArmSide affectedSide = ArmSide.left,
  }) async {
    final start = PeriodHelper.getStartDate(period, selectedDate);
    final end = PeriodHelper.getEndDate(period, selectedDate);

    final results = await Future.wait([
      _db.getMovementData('left', startDate: start, endDate: end, limit: 10000),
      _db.getMovementData('right', startDate: start, endDate: end, limit: 10000),
    ]);

    final asymmetryData = AsymmetryCalculator.aggregateFromMovement(
      results[0],
      results[1],
      period,
      'magnitudeActiveTime',
      affectedSide,
    );

    return DataNormalizer.normalizeAsymmetryData(asymmetryData, period, selectedDate);
  }

  /// Adaptateur pour ASYMÉTRIE AXIS ACTIVE TIME (pour graphique area)
  Future<List<AsymmetryDataPoint>> getAxisAsymmetry(
    String period,
    DateTime? selectedDate, {
    ArmSide affectedSide = ArmSide.left,
  }) async {
    final start = PeriodHelper.getStartDate(period, selectedDate);
    final end = PeriodHelper.getEndDate(period, selectedDate);

    final results = await Future.wait([
      _db.getMovementData('left', startDate: start, endDate: end, limit: 10000),
      _db.getMovementData('right', startDate: start, endDate: end, limit: 10000),
    ]);

    final asymmetryData = AsymmetryCalculator.aggregateFromMovement(
      results[0],
      results[1],
      period,
      'axisActiveTime',
      affectedSide,
    );

    return DataNormalizer.normalizeAsymmetryData(asymmetryData, period, selectedDate);
  }

  /// Adaptateur pour ASYMÉTRIE MAGNITUDE ACTIVE TIME (pour JAUGE uniquement)
  Future<List<AsymmetryDataPoint>> getMagnitudeAsymmetryForGauge(
    String period,
    DateTime? selectedDate, {
    ArmSide affectedSide = ArmSide.left,
  }) async {
    final start = PeriodHelper.getStartDate(period, selectedDate);
    final end = PeriodHelper.getEndDate(period, selectedDate);

    final results = await Future.wait([
      _db.getMovementData('left', startDate: start, endDate: end, limit: 10000),
      _db.getMovementData('right', startDate: start, endDate: end, limit: 10000),
    ]);

    return [AsymmetryCalculator.aggregateForGauge(
      results[0],
      results[1],
      'magnitudeActiveTime',
      affectedSide,
      period,
    )];
  }

  /// Adaptateur pour ASYMÉTRIE AXIS ACTIVE TIME (pour JAUGE uniquement)
  Future<List<AsymmetryDataPoint>> getAxisAsymmetryForGauge(
    String period,
    DateTime? selectedDate, {
    ArmSide affectedSide = ArmSide.left,
  }) async {
    final start = PeriodHelper.getStartDate(period, selectedDate);
    final end = PeriodHelper.getEndDate(period, selectedDate);

    final results = await Future.wait([
      _db.getMovementData('left', startDate: start, endDate: end, limit: 10000),
      _db.getMovementData('right', startDate: start, endDate: end, limit: 10000),
    ]);

    return [AsymmetryCalculator.aggregateForGauge(
      results[0],
      results[1],
      'axisActiveTime',
      affectedSide,
      period,
    )];
  }

  /// Adaptateur pour visualiser les VALEURS GAUCHE/DROITE du mouvement
  Future<List<ChartDataPoint>> getAsymmetryRatioData(
    String period,
    DateTime? selectedDate, {
    ArmSide affectedSide = ArmSide.left,
  }) async {
    final asymmetryData = await getMagnitudeAsymmetry(
      period,
      selectedDate,
      affectedSide: affectedSide,
    );

    final chartData = asymmetryData.map((point) {
      return ChartDataPoint(
        timestamp: point.timestamp,
        leftValue: point.leftValue,
        rightValue: point.rightValue,
      );
    }).toList();

    return DataNormalizer.normalizeChartData(chartData, period, selectedDate);
  }
}
