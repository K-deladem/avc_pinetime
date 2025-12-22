// models/sensor_metrics.dart

/// Modèle unifié pour les métriques de capteurs (pas, batterie, etc.)
class SensorMetrics {
  final DateTime timestamp;
  final double value;
  final String type; // 'steps', 'battery', 'motion', etc.
  final String? side; // 'left', 'right', ou null

  SensorMetrics({
    required this.timestamp,
    required this.value,
    required this.type,
    this.side,
  });

  factory SensorMetrics.fromMap(Map<String, dynamic> map) {
    return SensorMetrics(
      timestamp: map['timestamp'] is DateTime
          ? map['timestamp']
          : DateTime.parse(map['timestamp']),
      value: (map['value'] ?? 0.0).toDouble(),
      type: map['type'] ?? 'unknown',
      side: map['side'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'value': value,
      'type': type,
      'side': side,
    };
  }

  @override
  String toString() => 'SensorMetrics($type: $value at $timestamp${side != null ? ", side: $side" : ""})';
}

/// Modèle pour les données agrégées par période
class AggregatedSensorData {
  final DateTime periodStart;
  final DateTime periodEnd;
  final double? leftValue;
  final double? rightValue;
  final double? combinedValue; // Pour données non latéralisées (batterie, etc.)

  AggregatedSensorData({
    required this.periodStart,
    required this.periodEnd,
    this.leftValue,
    this.rightValue,
    this.combinedValue,
  });

  /// Calcule la valeur totale (gauche + droite ou combinée)
  double get totalValue {
    if (combinedValue != null) return combinedValue!;
    return (leftValue ?? 0.0) + (rightValue ?? 0.0);
  }

  /// Calcule le score d'asymétrie (0-100) pour données latéralisées
  /// 0 = droite uniquement, 50 = égalité, 100 = gauche uniquement
  double get asymmetryScore {
    final left = leftValue ?? 0.0;
    final right = rightValue ?? 0.0;
    final total = left + right;

    if (total == 0) return 50.0;
    return (left / total) * 100.0;
  }

  /// Retourne la description de l'asymétrie
  String get asymmetryDescription {
    final score = asymmetryScore;
    if (score < 30) return 'Dominance droite forte';
    if (score < 45) return 'Dominance droite modérée';
    if (score < 55) return 'Équilibré';
    if (score < 70) return 'Dominance gauche modérée';
    return 'Dominance gauche forte';
  }

  Map<String, dynamic> toMap() {
    return {
      'periodStart': periodStart.toIso8601String(),
      'periodEnd': periodEnd.toIso8601String(),
      'leftValue': leftValue,
      'rightValue': rightValue,
      'combinedValue': combinedValue,
      'totalValue': totalValue,
      'asymmetryScore': asymmetryScore,
    };
  }

  @override
  String toString() {
    return 'AggregatedSensorData(period: $periodStart -> $periodEnd, '
        'total: $totalValue${leftValue != null ? ", asymmetry: ${asymmetryScore.toStringAsFixed(1)}%" : ""})';
  }
}

/// Modèle pour les données de motion brutes
class RawMotionData {
  final DateTime timestamp;
  final int x;
  final int y;
  final int z;
  final String side; // 'left' ou 'right'

  RawMotionData({
    required this.timestamp,
    required this.x,
    required this.y,
    required this.z,
    required this.side,
  });

  /// Calcule la magnitude brute
  double get rawMagnitude {
    return (x * x + y * y + z * z).toDouble();
  }

  factory RawMotionData.fromMap(Map<String, dynamic> map) {
    return RawMotionData(
      timestamp: map['timestamp'] is DateTime
          ? map['timestamp']
          : DateTime.parse(map['timestamp']),
      x: (map['x'] ?? 0) as int,
      y: (map['y'] ?? 0) as int,
      z: (map['z'] ?? 0) as int,
      side: map['side'] ?? 'unknown',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'x': x,
      'y': y,
      'z': z,
      'side': side,
      'rawMagnitude': rawMagnitude,
    };
  }
}

/// Modèle pour les données de motion traitées (après filtrage)
class ProcessedMotionData {
  final DateTime timestamp;
  final double magnitude;
  final double smoothedMagnitude;
  final double axisVariance;
  final int activityLevel; // 0-100
  final String side; // 'left' ou 'right'

  // Temps actifs (cumulés)
  final int magnitudeActiveTimeMs;
  final int axisActiveTimeMs;

  ProcessedMotionData({
    required this.timestamp,
    required this.magnitude,
    required this.smoothedMagnitude,
    required this.axisVariance,
    required this.activityLevel,
    required this.side,
    this.magnitudeActiveTimeMs = 0,
    this.axisActiveTimeMs = 0,
  });

  factory ProcessedMotionData.fromMap(Map<String, dynamic> map) {
    return ProcessedMotionData(
      timestamp: map['timestamp'] is DateTime
          ? map['timestamp']
          : DateTime.parse(map['timestamp']),
      magnitude: (map['magnitude'] ?? 0.0).toDouble(),
      smoothedMagnitude: (map['smoothedMagnitude'] ?? 0.0).toDouble(),
      axisVariance: (map['axisVariance'] ?? 0.0).toDouble(),
      activityLevel: (map['activityLevel'] ?? 0) as int,
      side: map['side'] ?? 'unknown',
      magnitudeActiveTimeMs: (map['magnitudeActiveTimeMs'] ?? 0) as int,
      axisActiveTimeMs: (map['axisActiveTimeMs'] ?? 0) as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'magnitude': magnitude,
      'smoothedMagnitude': smoothedMagnitude,
      'axisVariance': axisVariance,
      'activityLevel': activityLevel,
      'side': side,
      'magnitudeActiveTimeMs': magnitudeActiveTimeMs,
      'axisActiveTimeMs': axisActiveTimeMs,
    };
  }

  /// Retourne la catégorie d'activité
  String get activityCategory {
    if (activityLevel < 10) return 'Immobile';
    if (activityLevel < 30) return 'Très faible';
    if (activityLevel < 50) return 'Faible';
    if (activityLevel < 70) return 'Modéré';
    if (activityLevel < 90) return 'Élevé';
    return 'Très élevé';
  }

  @override
  String toString() {
    return 'ProcessedMotionData($side: mag=${magnitude.toStringAsFixed(2)}, '
        'level=$activityLevel, $activityCategory)';
  }
}

/// Modèle pour les statistiques de motion traitées
class ProcessedMotionStats {
  final String armSide;
  final DateTime date;
  final double avgMagnitude;
  final double maxMagnitude;
  final double minMagnitude;
  final int avgActivityLevel;
  final int maxActivityLevel;
  final int totalMagnitudeActiveTimeMs;
  final int totalAxisActiveTimeMs;
  final int recordCount;

  ProcessedMotionStats({
    required this.armSide,
    required this.date,
    required this.avgMagnitude,
    required this.maxMagnitude,
    required this.minMagnitude,
    required this.avgActivityLevel,
    required this.maxActivityLevel,
    required this.totalMagnitudeActiveTimeMs,
    required this.totalAxisActiveTimeMs,
    required this.recordCount,
  });

  Map<String, dynamic> toMap() {
    return {
      'armSide': armSide,
      'date': date.toIso8601String(),
      'avgMagnitude': avgMagnitude,
      'maxMagnitude': maxMagnitude,
      'minMagnitude': minMagnitude,
      'avgActivityLevel': avgActivityLevel,
      'maxActivityLevel': maxActivityLevel,
      'totalMagnitudeActiveTimeMs': totalMagnitudeActiveTimeMs,
      'totalAxisActiveTimeMs': totalAxisActiveTimeMs,
      'recordCount': recordCount,
    };
  }

  @override
  String toString() {
    return 'ProcessedMotionStats($armSide on ${date.toIso8601String()}: '
        'avgMag=${avgMagnitude.toStringAsFixed(2)}, '
        'avgLevel=$avgActivityLevel, records=$recordCount)';
  }
}
