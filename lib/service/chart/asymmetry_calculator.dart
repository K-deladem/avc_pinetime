import '../../models/arm_side.dart';
import 'chart_models.dart';
import 'period_helper.dart';

/// Service for calculating asymmetry data
class AsymmetryCalculator {
  AsymmetryCalculator._();

  /// Aggregate asymmetry data from device info
  static List<AsymmetryDataPoint> aggregateFromDeviceInfo<T>(
    List<T> leftData,
    List<T> rightData,
    String period,
    double Function(T) valueExtractor,
    ArmSide affectedSide,
  ) {
    final Map<DateTime, Map<String, List<double>>> grouped = {};

    for (final data in leftData) {
      final timestamp = (data as dynamic).timestamp as DateTime;
      final groupedDate = PeriodHelper.groupDateByPeriod(timestamp, period);
      grouped.putIfAbsent(groupedDate, () => {'left': [], 'right': []});
      grouped[groupedDate]!['left']!.add(valueExtractor(data));
    }

    for (final data in rightData) {
      final timestamp = (data as dynamic).timestamp as DateTime;
      final groupedDate = PeriodHelper.groupDateByPeriod(timestamp, period);
      grouped.putIfAbsent(groupedDate, () => {'left': [], 'right': []});
      grouped[groupedDate]!['right']!.add(valueExtractor(data));
    }

    final points = <AsymmetryDataPoint>[];
    final sortedKeys = grouped.keys.toList()..sort();

    for (final date in sortedKeys) {
      final values = grouped[date]!;
      final leftAvg = values['left']!.isEmpty
          ? 0.0
          : values['left']!.reduce((a, b) => a + b) / values['left']!.length;
      final rightAvg = values['right']!.isEmpty
          ? 0.0
          : values['right']!.reduce((a, b) => a + b) / values['right']!.length;

      final total = leftAvg + rightAvg;
      final affectedAvg = affectedSide == ArmSide.left ? leftAvg : rightAvg;
      final asymmetryRatio = total > 0 ? (affectedAvg / total) * 100 : 50.0;
      final category = AsymmetryHelper.categorize(asymmetryRatio);

      points.add(AsymmetryDataPoint(
        timestamp: date,
        leftValue: leftAvg,
        rightValue: rightAvg,
        asymmetryRatio: asymmetryRatio,
        asymmetryCategory: category,
      ));
    }

    return points;
  }

  /// Aggregate asymmetry from movement data
  static List<AsymmetryDataPoint> aggregateFromMovement(
    List<Map<String, dynamic>> leftData,
    List<Map<String, dynamic>> rightData,
    String period,
    String fieldName,
    ArmSide affectedSide,
  ) {
    final leftDeltas = _calculateDeltasByPeriod(leftData, fieldName, period);
    final rightDeltas = _calculateDeltasByPeriod(rightData, fieldName, period);

    final Map<DateTime, Map<String, double>> grouped = {};

    for (final entry in leftDeltas.entries) {
      grouped.putIfAbsent(entry.key, () => {'left': 0.0, 'right': 0.0});
      grouped[entry.key]!['left'] = entry.value / 60000.0; // ms -> minutes
    }

    for (final entry in rightDeltas.entries) {
      grouped.putIfAbsent(entry.key, () => {'left': 0.0, 'right': 0.0});
      grouped[entry.key]!['right'] = entry.value / 60000.0;
    }

    final points = <AsymmetryDataPoint>[];
    final sortedKeys = grouped.keys.toList()..sort();

    for (final date in sortedKeys) {
      final values = grouped[date]!;
      final leftValue = values['left']!;
      final rightValue = values['right']!;
      final total = leftValue + rightValue;
      final affectedValue = affectedSide == ArmSide.left ? leftValue : rightValue;
      final asymmetryRatio = total > 0 ? (affectedValue / total) * 100 : 50.0;
      final category = AsymmetryHelper.categorize(asymmetryRatio);

      points.add(AsymmetryDataPoint(
        timestamp: date,
        leftValue: leftValue,
        rightValue: rightValue,
        asymmetryRatio: asymmetryRatio,
        asymmetryCategory: category,
      ));
    }

    return points;
  }

  /// Aggregate for gauge (single point with totals)
  /// - Jour: dernière valeur de la journée
  /// - Semaine: somme des dernières valeurs de chaque jour
  /// - Mois: somme des dernières valeurs de chaque jour
  static AsymmetryDataPoint aggregateForGauge(
    List<Map<String, dynamic>> leftData,
    List<Map<String, dynamic>> rightData,
    String fieldName,
    ArmSide affectedSide,
    String period,
  ) {
    double leftActiveTime;
    double rightActiveTime;

    if (period == 'Jour') {
      // Pour le jour: prendre la dernière valeur
      leftActiveTime = _getLatestValue(leftData, fieldName);
      rightActiveTime = _getLatestValue(rightData, fieldName);
    } else {
      // Pour semaine/mois: somme des dernières valeurs de chaque jour
      leftActiveTime = _sumLatestValuesByDay(leftData, fieldName);
      rightActiveTime = _sumLatestValuesByDay(rightData, fieldName);
    }

    final leftMinutes = leftActiveTime / 60000.0;
    final rightMinutes = rightActiveTime / 60000.0;

    final total = leftMinutes + rightMinutes;
    final affectedValue = affectedSide == ArmSide.left ? leftMinutes : rightMinutes;
    final asymmetryRatio = total > 0 ? (affectedValue / total) * 100 : 50.0;
    final category = AsymmetryHelper.categorize(asymmetryRatio);

    return AsymmetryDataPoint(
      timestamp: DateTime.now(),
      leftValue: leftMinutes,
      rightValue: rightMinutes,
      asymmetryRatio: asymmetryRatio,
      asymmetryCategory: category,
    );
  }

  /// Get the latest (most recent) value from cumulative data
  static double _getLatestValue(
    List<Map<String, dynamic>> data,
    String fieldName,
  ) {
    if (data.isEmpty) return 0.0;

    // Trier par timestamp pour obtenir le plus récent
    final sorted = List<Map<String, dynamic>>.from(data);
    sorted.sort((a, b) {
      final aTime = DateTime.parse(a['createdAt'] as String);
      final bTime = DateTime.parse(b['createdAt'] as String);
      return bTime.compareTo(aTime); // Ordre décroissant (plus récent en premier)
    });

    // Prendre la première valeur (la plus récente)
    final latest = sorted.first;
    final value = latest[fieldName];
    if (value == null) return 0.0;

    final intValue = (value is int) ? value : (value as double).toInt();

    // Valider que la valeur est raisonnable (< 24h en ms)
    if (intValue < 0 || intValue > 86400000) return 0.0;

    return intValue.toDouble();
  }

  /// Sum of latest values for each day
  /// Pour semaine/mois: groupe par jour et prend la dernière valeur de chaque jour
  static double _sumLatestValuesByDay(
    List<Map<String, dynamic>> data,
    String fieldName,
  ) {
    if (data.isEmpty) return 0.0;

    // Grouper par jour
    final byDay = <String, List<Map<String, dynamic>>>{};
    for (final entry in data) {
      final createdAt = entry['createdAt'] as String?;
      if (createdAt == null) continue;

      final timestamp = DateTime.parse(createdAt);
      final dayKey = '${timestamp.year}-${timestamp.month}-${timestamp.day}';

      byDay.putIfAbsent(dayKey, () => []);
      byDay[dayKey]!.add(entry);
    }

    // Pour chaque jour, prendre la dernière valeur et faire la somme
    double total = 0.0;
    for (final dayData in byDay.values) {
      final latestValue = _getLatestValue(dayData, fieldName);
      if (latestValue > 0 && latestValue <= 86400000) {
        total += latestValue;
      }
    }

    return total;
  }

  /// Get latest value by period
  /// Pour chaque période (heure/jour/mois), prend la dernière valeur reçue
  static Map<DateTime, double> _calculateDeltasByPeriod(
    List<Map<String, dynamic>> data,
    String fieldName,
    String period,
  ) {
    if (data.isEmpty) return {};

    // Grouper par période avec le timestamp complet pour trier
    final byPeriod = <DateTime, List<Map<String, dynamic>>>{};

    for (final entry in data) {
      final createdAt = entry['createdAt'] as String?;
      if (createdAt == null) continue;

      final timestamp = DateTime.parse(createdAt);
      final periodKey = PeriodHelper.groupDateByPeriod(timestamp, period);

      byPeriod.putIfAbsent(periodKey, () => []);
      byPeriod[periodKey]!.add(entry);
    }

    final result = <DateTime, double>{};

    for (final entry in byPeriod.entries) {
      final periodData = entry.value;
      if (periodData.isEmpty) continue;

      // Prendre la dernière valeur de cette période
      final latestValue = _getLatestValue(periodData, fieldName);

      if (latestValue > 0 && latestValue <= 86400000) {
        result[entry.key] = latestValue;
      }
    }

    return result;
  }

}
