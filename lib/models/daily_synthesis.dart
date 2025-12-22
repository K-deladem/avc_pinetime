import 'arm_side.dart';

/// Synthèse quotidienne calculée
class DailySynthesis {
  final DateTime date;
  final ArmSide? dominantArm;
  final double asymmetryAverage;
  final int totalStepsLeft;
  final int totalStepsRight;
  final Duration connectedTimeLeft;
  final Duration connectedTimeRight;
  final Map<String, dynamic> recommendations; // Recommandations basées sur les données

  DailySynthesis({
    required this.date,
    this.dominantArm,
    required this.asymmetryAverage,
    required this.totalStepsLeft,
    required this.totalStepsRight,
    required this.connectedTimeLeft,
    required this.connectedTimeRight,
    required this.recommendations,
  });
}