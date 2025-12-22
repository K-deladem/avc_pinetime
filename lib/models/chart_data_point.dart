/// Point de données pour graphique
class ChartDataPoint {
  final DateTime timestamp;
  final double? leftValue;
  final double? rightValue;
  final double? difference;
  final double? ratio;

  ChartDataPoint({
    required this.timestamp,
    this.leftValue,
    this.rightValue,
    this.difference,
    this.ratio,
  });
}