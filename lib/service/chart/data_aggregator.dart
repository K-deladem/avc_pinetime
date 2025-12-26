import '../../ui/home/chart/reusable_comparison_chart.dart';
import 'period_helper.dart';

/// Service for aggregating chart data
class DataAggregator {
  DataAggregator._();

  /// Aggregate steps data (cumulatif - prend la dernière valeur de chaque période)
  static List<ChartDataPoint> aggregateStepsData(
    List<dynamic> leftData,
    List<dynamic> rightData,
    String period,
  ) {
    final grouped = _groupDataWithLatest(leftData, rightData, period);
    return _generateFixedPointsFromLatest(grouped, period);
  }

  /// Aggregate battery data
  static List<ChartDataPoint> aggregateBatteryData(
    List<dynamic> leftData,
    List<dynamic> rightData,
    String period,
  ) {
    final grouped = _groupData(leftData, rightData, period);
    return _generateFixedPoints(grouped, period);
  }

  /// Aggregate movement data
  static List<ChartDataPoint> aggregateMovementData(
    List<Map<String, dynamic>> leftData,
    List<Map<String, dynamic>> rightData,
    String period,
    String fieldName,
  ) {
    // Champs cumulatifs qui nécessitent un calcul de delta
    final cumulativeFields = ['magnitudeActiveTime', 'axisActiveTime'];
    final isCumulative = cumulativeFields.contains(fieldName);

    if (isCumulative) {
      return _aggregateCumulativeData(leftData, rightData, period, fieldName);
    }

    return _aggregateAverageData(leftData, rightData, period, fieldName);
  }

  /// Group data by period
  static Map<DateTime, Map<String, List<double>>> _groupData(
    List<dynamic> leftData,
    List<dynamic> rightData,
    String period,
  ) {
    final Map<DateTime, Map<String, List<double>>> grouped = {};

    // Grouper gauche
    for (final data in leftData) {
      final groupedDate = PeriodHelper.groupDateByPeriod(data.timestamp, period);
      grouped.putIfAbsent(groupedDate, () => {'left': [], 'right': []});
      grouped[groupedDate]!['left']!.add(data.value);
    }

    // Grouper droite
    for (final data in rightData) {
      final groupedDate = PeriodHelper.groupDateByPeriod(data.timestamp, period);
      grouped.putIfAbsent(groupedDate, () => {'left': [], 'right': []});
      grouped[groupedDate]!['right']!.add(data.value);
    }

    return grouped;
  }

  /// Generate fixed points based on period
  static List<ChartDataPoint> _generateFixedPoints(
    Map<DateTime, Map<String, List<double>>> grouped,
    String period,
  ) {
    final points = <ChartDataPoint>[];
    final now = DateTime.now();

    switch (period) {
      case 'Jour':
        for (int hour = 0; hour < 24; hour++) {
          final timestamp = DateTime(now.year, now.month, now.day, hour);
          final values = grouped[timestamp] ?? {'left': [], 'right': []};
          points.add(_createChartPoint(timestamp, values));
        }
        break;

      case 'Semaine':
        final weekday = now.weekday;
        final monday = now.subtract(Duration(days: weekday - 1));
        for (int day = 0; day < 7; day++) {
          final timestamp = DateTime(monday.year, monday.month, monday.day + day);
          final values = grouped[timestamp] ?? {'left': [], 'right': []};
          points.add(_createChartPoint(timestamp, values));
        }
        break;

      case 'Mois':
        for (int i = 11; i >= 0; i--) {
          final monthDate = DateTime(now.year, now.month - i, 1);
          final values = grouped[monthDate] ?? {'left': [], 'right': []};
          points.add(_createChartPoint(monthDate, values));
        }
        break;

      default:
        final sortedKeys = grouped.keys.toList()..sort();
        for (final date in sortedKeys) {
          points.add(_createChartPoint(date, grouped[date]!));
        }
    }

    return points;
  }

  static ChartDataPoint _createChartPoint(
    DateTime timestamp,
    Map<String, List<double>> values,
  ) {
    return ChartDataPoint(
      timestamp: timestamp,
      leftValue: values['left']!.isEmpty
          ? 0.0
          : values['left']!.reduce((a, b) => a + b) / values['left']!.length,
      rightValue: values['right']!.isEmpty
          ? 0.0
          : values['right']!.reduce((a, b) => a + b) / values['right']!.length,
    );
  }

  /// Group data by period and keep entries with timestamp for later sorting
  static Map<DateTime, Map<String, List<_TimestampedValue>>> _groupDataWithLatest(
    List<dynamic> leftData,
    List<dynamic> rightData,
    String period,
  ) {
    final Map<DateTime, Map<String, List<_TimestampedValue>>> grouped = {};

    // Grouper gauche
    for (final data in leftData) {
      final groupedDate = PeriodHelper.groupDateByPeriod(data.timestamp, period);
      grouped.putIfAbsent(groupedDate, () => {'left': [], 'right': []});
      grouped[groupedDate]!['left']!.add(_TimestampedValue(data.timestamp, data.value));
    }

    // Grouper droite
    for (final data in rightData) {
      final groupedDate = PeriodHelper.groupDateByPeriod(data.timestamp, period);
      grouped.putIfAbsent(groupedDate, () => {'left': [], 'right': []});
      grouped[groupedDate]!['right']!.add(_TimestampedValue(data.timestamp, data.value));
    }

    return grouped;
  }

  /// Generate fixed points using latest value for each period
  static List<ChartDataPoint> _generateFixedPointsFromLatest(
    Map<DateTime, Map<String, List<_TimestampedValue>>> grouped,
    String period,
  ) {
    final points = <ChartDataPoint>[];
    final now = DateTime.now();

    switch (period) {
      case 'Jour':
        for (int hour = 0; hour < 24; hour++) {
          final timestamp = DateTime(now.year, now.month, now.day, hour);
          final values = grouped[timestamp] ?? {'left': [], 'right': []};
          points.add(_createChartPointFromLatest(timestamp, values));
        }
        break;

      case 'Semaine':
        final weekday = now.weekday;
        final monday = now.subtract(Duration(days: weekday - 1));
        for (int day = 0; day < 7; day++) {
          final timestamp = DateTime(monday.year, monday.month, monday.day + day);
          final values = grouped[timestamp] ?? {'left': [], 'right': []};
          points.add(_createChartPointFromLatest(timestamp, values));
        }
        break;

      case 'Mois':
        for (int i = 11; i >= 0; i--) {
          final monthDate = DateTime(now.year, now.month - i, 1);
          final values = grouped[monthDate] ?? {'left': [], 'right': []};
          points.add(_createChartPointFromLatest(monthDate, values));
        }
        break;

      default:
        final sortedKeys = grouped.keys.toList()..sort();
        for (final date in sortedKeys) {
          points.add(_createChartPointFromLatest(date, grouped[date]!));
        }
    }

    return points;
  }

  /// Create chart point using latest value (not average)
  static ChartDataPoint _createChartPointFromLatest(
    DateTime timestamp,
    Map<String, List<_TimestampedValue>> values,
  ) {
    return ChartDataPoint(
      timestamp: timestamp,
      leftValue: _getLatestFromList(values['left']!),
      rightValue: _getLatestFromList(values['right']!),
    );
  }

  /// Get latest value from timestamped list
  static double _getLatestFromList(List<_TimestampedValue> values) {
    if (values.isEmpty) return 0.0;

    // Trier par timestamp décroissant et prendre le premier
    values.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return values.first.value;
  }

  /// Aggregate cumulative data (like active time)
  static List<ChartDataPoint> _aggregateCumulativeData(
    List<Map<String, dynamic>> leftData,
    List<Map<String, dynamic>> rightData,
    String period,
    String fieldName,
  ) {
    final leftDeltas = _calculateDeltas(leftData, fieldName);
    final rightDeltas = _calculateDeltas(rightData, fieldName);

    final Map<DateTime, Map<String, List<double>>> grouped = {};

    for (final entry in leftDeltas.entries) {
      final groupedDate = PeriodHelper.groupDateByPeriod(entry.key, period);
      grouped.putIfAbsent(groupedDate, () => {'left': [], 'right': []});
      grouped[groupedDate]!['left']!.add(entry.value);
    }

    for (final entry in rightDeltas.entries) {
      final groupedDate = PeriodHelper.groupDateByPeriod(entry.key, period);
      grouped.putIfAbsent(groupedDate, () => {'left': [], 'right': []});
      grouped[groupedDate]!['right']!.add(entry.value);
    }

    final points = <ChartDataPoint>[];
    final sortedKeys = grouped.keys.toList()..sort();

    for (final date in sortedKeys) {
      final values = grouped[date]!;
      points.add(ChartDataPoint(
        timestamp: date,
        leftValue: values['left']!.isEmpty
            ? 0.0
            : values['left']!.reduce((a, b) => a + b),
        rightValue: values['right']!.isEmpty
            ? 0.0
            : values['right']!.reduce((a, b) => a + b),
      ));
    }

    return points;
  }

  /// Aggregate average data
  static List<ChartDataPoint> _aggregateAverageData(
    List<Map<String, dynamic>> leftData,
    List<Map<String, dynamic>> rightData,
    String period,
    String fieldName,
  ) {
    final Map<DateTime, Map<String, List<double>>> grouped = {};

    for (final data in leftData) {
      final createdAt = data['createdAt'] as String?;
      if (createdAt == null) continue;
      final timestamp = DateTime.parse(createdAt);
      final groupedDate = PeriodHelper.groupDateByPeriod(timestamp, period);
      grouped.putIfAbsent(groupedDate, () => {'left': [], 'right': []});

      final value = data[fieldName];
      if (value != null) {
        final doubleValue = (value is int) ? value.toDouble() : (value as double);
        grouped[groupedDate]!['left']!.add(doubleValue);
      }
    }

    for (final data in rightData) {
      final createdAt = data['createdAt'] as String?;
      if (createdAt == null) continue;
      final timestamp = DateTime.parse(createdAt);
      final groupedDate = PeriodHelper.groupDateByPeriod(timestamp, period);
      grouped.putIfAbsent(groupedDate, () => {'left': [], 'right': []});

      final value = data[fieldName];
      if (value != null) {
        final doubleValue = (value is int) ? value.toDouble() : (value as double);
        grouped[groupedDate]!['right']!.add(doubleValue);
      }
    }

    final points = <ChartDataPoint>[];
    final sortedKeys = grouped.keys.toList()..sort();

    for (final date in sortedKeys) {
      final values = grouped[date]!;
      points.add(ChartDataPoint(
        timestamp: date,
        leftValue: values['left']!.isEmpty
            ? 0.0
            : values['left']!.reduce((a, b) => a + b) / values['left']!.length,
        rightValue: values['right']!.isEmpty
            ? 0.0
            : values['right']!.reduce((a, b) => a + b) / values['right']!.length,
      ));
    }

    return points;
  }

  /// Calculate deltas for cumulative values
  static Map<DateTime, double> _calculateDeltas(
    List<Map<String, dynamic>> data,
    String fieldName,
  ) {
    if (data.isEmpty) return {};

    final byHour = <DateTime, List<int>>{};

    for (final entry in data) {
      final createdAt = entry['createdAt'] as String?;
      if (createdAt == null) continue;

      final timestamp = DateTime.parse(createdAt);
      final hourKey = DateTime(timestamp.year, timestamp.month, timestamp.day, timestamp.hour);

      final value = entry[fieldName];
      if (value == null) continue;

      final intValue = (value is int) ? value : (value as double).toInt();

      byHour.putIfAbsent(hourKey, () => []);
      byHour[hourKey]!.add(intValue);
    }

    final deltas = <DateTime, double>{};

    for (final entry in byHour.entries) {
      final values = entry.value;
      if (values.isEmpty) continue;

      final minVal = values.reduce((a, b) => a < b ? a : b);
      final maxVal = values.reduce((a, b) => a > b ? a : b);
      final activeTime = maxVal - minVal;

      // Ignorer les valeurs négatives ou > 1 heure
      if (activeTime > 0 && activeTime <= 3600000) {
        deltas[entry.key] = activeTime.toDouble();
      }
    }

    return deltas;
  }
}

/// Helper class for storing value with timestamp
class _TimestampedValue {
  final DateTime timestamp;
  final double value;

  _TimestampedValue(this.timestamp, this.value);
}
