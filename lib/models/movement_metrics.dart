// models/movement_metrics.dart

/// Modèle pour stocker les métriques agrégées de mouvement
class MovementMetrics {
  final DateTime timestamp;
  final double magnitudeActiveTimeMs;
  final double axisActiveTimeMs;
  final String side; // 'left' ou 'right'

  MovementMetrics({
    required this.timestamp,
    required this.magnitudeActiveTimeMs,
    required this.axisActiveTimeMs,
    required this.side,
  });

  factory MovementMetrics.fromMap(Map<String, dynamic> map) {
    return MovementMetrics(
      timestamp: map['timestamp'] is DateTime
          ? map['timestamp']
          : DateTime.parse(map['timestamp']),
      magnitudeActiveTimeMs: (map['magnitudeActiveTimeMs'] ?? 0.0).toDouble(),
      axisActiveTimeMs: (map['axisActiveTimeMs'] ?? 0.0).toDouble(),
      side: map['side'] ?? 'unknown',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'magnitudeActiveTimeMs': magnitudeActiveTimeMs,
      'axisActiveTimeMs': axisActiveTimeMs,
      'side': side,
    };
  }

  /// Formatte le temps en heures, minutes, secondes
  String formatTime(double milliseconds) {
    final seconds = (milliseconds / 1000).round();
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m ${secs}s';
    } else {
      return '${secs}s';
    }
  }

  String get magnitudeActiveTimeFormatted => formatTime(magnitudeActiveTimeMs);
  String get axisActiveTimeFormatted => formatTime(axisActiveTimeMs);

  @override
  String toString() => 'MovementMetrics($side, mag: $magnitudeActiveTimeMs, axis: $axisActiveTimeMs)';
}

/// Modèle pour les données agrégées par période
class AggregatedMovementData {
  final DateTime periodStart;
  final DateTime periodEnd;
  final MovementMetrics? leftMetrics;
  final MovementMetrics? rightMetrics;

  AggregatedMovementData({
    required this.periodStart,
    required this.periodEnd,
    this.leftMetrics,
    this.rightMetrics,
  });

  /// Calcule le score d'asymétrie pour magnitudeActiveTime (0-100)
  /// 0 = droite uniquement, 50 = égalité, 100 = gauche uniquement
  double get magnitudeAsymmetryScore {
    final leftValue = leftMetrics?.magnitudeActiveTimeMs ?? 0.0;
    final rightValue = rightMetrics?.magnitudeActiveTimeMs ?? 0.0;
    final total = leftValue + rightValue;

    if (total == 0) return 50.0; // Aucune donnée = égalité
    return (leftValue / total) * 100.0;
  }

  /// Calcule le score d'asymétrie pour axisActiveTime (0-100)
  double get axisAsymmetryScore {
    final leftValue = leftMetrics?.axisActiveTimeMs ?? 0.0;
    final rightValue = rightMetrics?.axisActiveTimeMs ?? 0.0;
    final total = leftValue + rightValue;

    if (total == 0) return 50.0;
    return (leftValue / total) * 100.0;
  }

  /// Retourne une description textuelle de l'asymétrie magnitude
  String get magnitudeAsymmetryDescription {
    final score = magnitudeAsymmetryScore;
    if (score < 30) return 'Dominance droite forte';
    if (score < 45) return 'Dominance droite modérée';
    if (score < 55) return 'Équilibré';
    if (score < 70) return 'Dominance gauche modérée';
    return 'Dominance gauche forte';
  }

  /// Retourne une description textuelle de l'asymétrie axis
  String get axisAsymmetryDescription {
    final score = axisAsymmetryScore;
    if (score < 30) return 'Dominance droite forte';
    if (score < 45) return 'Dominance droite modérée';
    if (score < 55) return 'Équilibré';
    if (score < 70) return 'Dominance gauche modérée';
    return 'Dominance gauche forte';
  }

  /// Différence absolue en pourcentage
  double get magnitudeDifferencePercent {
    return (magnitudeAsymmetryScore - 50.0).abs();
  }

  double get axisDifferencePercent {
    return (axisAsymmetryScore - 50.0).abs();
  }

  Map<String, dynamic> toMap() {
    return {
      'periodStart': periodStart.toIso8601String(),
      'periodEnd': periodEnd.toIso8601String(),
      'leftMetrics': leftMetrics?.toMap(),
      'rightMetrics': rightMetrics?.toMap(),
      'magnitudeAsymmetryScore': magnitudeAsymmetryScore,
      'axisAsymmetryScore': axisAsymmetryScore,
    };
  }

  @override
  String toString() {
    return 'AggregatedMovementData(period: $periodStart -> $periodEnd, '
        'magScore: ${magnitudeAsymmetryScore.toStringAsFixed(1)}%, '
        'axisScore: ${axisAsymmetryScore.toStringAsFixed(1)}%)';
  }
}
