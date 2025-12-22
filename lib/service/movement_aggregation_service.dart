// service/movement_aggregation_service.dart

import 'package:flutter_bloc_app_template/app/app_database.dart';
import 'package:flutter_bloc_app_template/models/arm_side.dart';
import 'package:flutter_bloc_app_template/models/movement_metrics.dart';

/// Service pour agréger les données de mouvement selon différentes périodes
class MovementAggregationService {
  final AppDatabase _db = AppDatabase.instance;

  /// Récupère les données agrégées pour une période donnée
  ///
  /// [filterType] : 'day', 'week', 'month'
  /// [selectedDate] : Date sélectionnée (par défaut aujourd'hui)
  Future<List<AggregatedMovementData>> getAggregatedData({
    required String filterType,
    DateTime? selectedDate,
  }) async {
    final date = selectedDate ?? DateTime.now();

    switch (filterType) {
      case 'day':
        return _aggregateByHour(date);
      case 'week':
        return _aggregateByDay(date);
      case 'month':
        return _aggregateByMonth(date);
      default:
        return _aggregateByDay(date);
    }
  }

  /// Agrège les données par heure pour un jour donné
  Future<List<AggregatedMovementData>> _aggregateByHour(DateTime day) async {
    final List<AggregatedMovementData> result = [];
    final startOfDay = DateTime(day.year, day.month, day.day);

    for (int hour = 0; hour < 24; hour++) {
      final periodStart = startOfDay.add(Duration(hours: hour));
      final periodEnd = periodStart.add(const Duration(hours: 1));

      final leftData = await _getMovementDataForPeriod(
        ArmSide.left,
        periodStart,
        periodEnd,
      );

      final rightData = await _getMovementDataForPeriod(
        ArmSide.right,
        periodStart,
        periodEnd,
      );

      result.add(AggregatedMovementData(
        periodStart: periodStart,
        periodEnd: periodEnd,
        leftMetrics: leftData,
        rightMetrics: rightData,
      ));
    }

    return result;
  }

  /// Agrège les données par jour pour une semaine donnée
  Future<List<AggregatedMovementData>> _aggregateByDay(DateTime date) async {
    final List<AggregatedMovementData> result = [];

    // Trouver le lundi de la semaine
    final weekday = date.weekday;
    final monday = date.subtract(Duration(days: weekday - 1));
    final startOfWeek = DateTime(monday.year, monday.month, monday.day);

    for (int day = 0; day < 7; day++) {
      final periodStart = startOfWeek.add(Duration(days: day));
      final periodEnd = periodStart.add(const Duration(days: 1));

      final leftData = await _getMovementDataForPeriod(
        ArmSide.left,
        periodStart,
        periodEnd,
      );

      final rightData = await _getMovementDataForPeriod(
        ArmSide.right,
        periodStart,
        periodEnd,
      );

      result.add(AggregatedMovementData(
        periodStart: periodStart,
        periodEnd: periodEnd,
        leftMetrics: leftData,
        rightMetrics: rightData,
      ));
    }

    return result;
  }

  /// Agrège les données par mois pour une année donnée
  Future<List<AggregatedMovementData>> _aggregateByMonth(DateTime date) async {
    final List<AggregatedMovementData> result = [];
    final year = date.year;

    for (int month = 1; month <= 12; month++) {
      final periodStart = DateTime(year, month, 1);
      final periodEnd = month == 12
          ? DateTime(year + 1, 1, 1)
          : DateTime(year, month + 1, 1);

      final leftData = await _getMovementDataForPeriod(
        ArmSide.left,
        periodStart,
        periodEnd,
      );

      final rightData = await _getMovementDataForPeriod(
        ArmSide.right,
        periodStart,
        periodEnd,
      );

      result.add(AggregatedMovementData(
        periodStart: periodStart,
        periodEnd: periodEnd,
        leftMetrics: leftData,
        rightMetrics: rightData,
      ));
    }

    return result;
  }

  /// Récupère et agrège les données de mouvement pour une période spécifique
  ///
  /// IMPORTANT: Cette méthode simule l'agrégation à partir des données MovementData
  /// car magnitudeActiveTime et axisActiveTime sont disponibles dans la table movements
  Future<MovementMetrics?> _getMovementDataForPeriod(
    ArmSide side,
    DateTime start,
    DateTime end,
  ) async {
    try {
      // Requête SQL pour agréger les données de mouvement
      final result = await _db.database.then((db) => db.rawQuery('''
        SELECT
          SUM(magnitudeActiveTime) as totalMagnitudeTime,
          SUM(axisActiveTime) as totalAxisTime,
          COUNT(*) as recordCount
        FROM movement_data
        WHERE armSide = ?
          AND timestamp >= ?
          AND timestamp < ?
      ''', [
        side.name,
        start.toIso8601String(),
        end.toIso8601String(),
      ]));

      if (result.isEmpty || result.first['recordCount'] == 0) {
        return null;
      }

      final record = result.first;
      final magnitudeTime = (record['totalMagnitudeTime'] ?? 0.0) as num;
      final axisTime = (record['totalAxisTime'] ?? 0.0) as num;

      return MovementMetrics(
        timestamp: start,
        magnitudeActiveTimeMs: magnitudeTime.toDouble(),
        axisActiveTimeMs: axisTime.toDouble(),
        side: side.name,
      );
    } catch (e) {
      print('Erreur lors de la récupération des données de mouvement: $e');
      return null;
    }
  }

  /// Récupère les totaux sur une période complète (pour résumés)
  Future<Map<String, MovementMetrics?>> getTotalsForPeriod({
    required DateTime start,
    required DateTime end,
  }) async {
    final leftData = await _getMovementDataForPeriod(ArmSide.left, start, end);
    final rightData = await _getMovementDataForPeriod(ArmSide.right, start, end);

    return {
      'left': leftData,
      'right': rightData,
    };
  }

  /// Calcule les statistiques détaillées pour une période
  Future<Map<String, dynamic>> getDetailedStats({
    required DateTime start,
    required DateTime end,
  }) async {
    final totals = await getTotalsForPeriod(start: start, end: end);

    final leftMag = totals['left']?.magnitudeActiveTimeMs ?? 0.0;
    final rightMag = totals['right']?.magnitudeActiveTimeMs ?? 0.0;
    final leftAxis = totals['left']?.axisActiveTimeMs ?? 0.0;
    final rightAxis = totals['right']?.axisActiveTimeMs ?? 0.0;

    final totalMag = leftMag + rightMag;
    final totalAxis = leftAxis + rightAxis;

    final magScore = totalMag > 0 ? (leftMag / totalMag) * 100 : 50.0;
    final axisScore = totalAxis > 0 ? (leftAxis / totalAxis) * 100 : 50.0;

    return {
      'magnitude': {
        'left': leftMag,
        'right': rightMag,
        'total': totalMag,
        'asymmetryScore': magScore,
        'leftPercentage': totalMag > 0 ? (leftMag / totalMag) * 100 : 0.0,
        'rightPercentage': totalMag > 0 ? (rightMag / totalMag) * 100 : 0.0,
      },
      'axis': {
        'left': leftAxis,
        'right': rightAxis,
        'total': totalAxis,
        'asymmetryScore': axisScore,
        'leftPercentage': totalAxis > 0 ? (leftAxis / totalAxis) * 100 : 0.0,
        'rightPercentage': totalAxis > 0 ? (rightAxis / totalAxis) * 100 : 0.0,
      },
    };
  }

  /// Stream en temps réel des données agrégées
  Stream<List<AggregatedMovementData>> getAggregatedDataStream({
    required String filterType,
    DateTime? selectedDate,
  }) async* {
    // Émet les données initiales
    yield await getAggregatedData(
      filterType: filterType,
      selectedDate: selectedDate,
    );

    // Met à jour toutes les 30 secondes
    await for (final _ in Stream.periodic(const Duration(seconds: 30))) {
      yield await getAggregatedData(
        filterType: filterType,
        selectedDate: selectedDate,
      );
    }
  }
}
