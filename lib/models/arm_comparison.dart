import 'arm_side.dart';

/// Comparaison instantanée entre les deux bras
class ArmComparison {
  final ArmSide side;
  final DateTime timestamp;
  final double? battery;
  final int? steps;

  // Métriques calculées
  final double? asymmetryScore; // 0-100, 0 = symétrique parfait
  final String? dominantArm; // "left", "right", "balanced"
  final double? activityDifference; // Différence d'activité en %

  ArmComparison({
    required this.side,
    required this.timestamp,
    this.battery,
    this.steps,
    this.asymmetryScore,
    this.dominantArm,
    this.activityDifference,
  });
}



