import '../../ui/home/chart/reusable_comparison_chart.dart';
import 'chart_models.dart';
import 'period_helper.dart';

/// Service for normalizing chart data points
class DataNormalizer {
  DataNormalizer._();

  /// Normalize data points to fixed intervals
  static List<ChartDataPoint> normalizeChartData(
    List<ChartDataPoint> data,
    String period,
    DateTime? selectedDate,
  ) {
    if (data.isEmpty) return data;

    final start = PeriodHelper.getStartDate(period, selectedDate);
    final end = PeriodHelper.getEndDate(period, selectedDate);

    final dataMap = <DateTime, ChartDataPoint>{};
    for (final point in data) {
      dataMap[point.timestamp] = point;
    }

    final normalizedPoints = <ChartDataPoint>[];
    DateTime current = start;

    switch (period) {
      case 'Jour':
        while (current.isBefore(end)) {
          final existing = dataMap[current];
          normalizedPoints.add(ChartDataPoint(
            timestamp: current,
            leftValue: existing?.leftValue,
            rightValue: existing?.rightValue,
          ));
          current = current.add(const Duration(hours: 1));
        }
        break;

      case 'Semaine':
        while (current.isBefore(end)) {
          final existing = dataMap[current];
          normalizedPoints.add(ChartDataPoint(
            timestamp: current,
            leftValue: existing?.leftValue,
            rightValue: existing?.rightValue,
          ));
          current = current.add(const Duration(days: 1));
        }
        break;

      case 'Mois':
        while (current.isBefore(end)) {
          final existing = dataMap[current];
          normalizedPoints.add(ChartDataPoint(
            timestamp: current,
            leftValue: existing?.leftValue,
            rightValue: existing?.rightValue,
          ));
          current = DateTime(current.year, current.month + 1, 1);
        }
        break;

      default:
        return data;
    }

    return normalizedPoints;
  }

  /// Normalize asymmetry data points to fixed intervals
  static List<AsymmetryDataPoint> normalizeAsymmetryData(
    List<AsymmetryDataPoint> data,
    String period,
    DateTime? selectedDate,
  ) {
    if (data.isEmpty) return data;

    final start = PeriodHelper.getStartDate(period, selectedDate);
    final end = PeriodHelper.getEndDate(period, selectedDate);

    final dataMap = <DateTime, AsymmetryDataPoint>{};
    for (final point in data) {
      dataMap[point.timestamp] = point;
    }

    final normalizedPoints = <AsymmetryDataPoint>[];
    DateTime current = start;

    switch (period) {
      case 'Jour':
        while (current.isBefore(end)) {
          final existing = dataMap[current];
          normalizedPoints.add(AsymmetryDataPoint(
            timestamp: current,
            leftValue: existing?.leftValue ?? 0.0,
            rightValue: existing?.rightValue ?? 0.0,
            asymmetryRatio: existing?.asymmetryRatio ?? 50.0,
            asymmetryCategory: existing?.asymmetryCategory ?? AsymmetryCategory.balanced,
          ));
          current = current.add(const Duration(hours: 1));
        }
        break;

      case 'Semaine':
        while (current.isBefore(end)) {
          final existing = dataMap[current];
          normalizedPoints.add(AsymmetryDataPoint(
            timestamp: current,
            leftValue: existing?.leftValue ?? 0.0,
            rightValue: existing?.rightValue ?? 0.0,
            asymmetryRatio: existing?.asymmetryRatio ?? 50.0,
            asymmetryCategory: existing?.asymmetryCategory ?? AsymmetryCategory.balanced,
          ));
          current = current.add(const Duration(days: 1));
        }
        break;

      case 'Mois':
        while (current.isBefore(end)) {
          final existing = dataMap[current];
          normalizedPoints.add(AsymmetryDataPoint(
            timestamp: current,
            leftValue: existing?.leftValue ?? 0.0,
            rightValue: existing?.rightValue ?? 0.0,
            asymmetryRatio: existing?.asymmetryRatio ?? 50.0,
            asymmetryCategory: existing?.asymmetryCategory ?? AsymmetryCategory.balanced,
          ));
          current = DateTime(current.year, current.month + 1, 1);
        }
        break;

      default:
        return data;
    }

    return normalizedPoints;
  }
}
