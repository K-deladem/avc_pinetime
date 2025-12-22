import 'dart:math' as math;

import 'package:flutter/foundation.dart';

/// ============================================================================
/// CLASSE: MovementData (AMÉLIORÉE - Version Complète)
/// Description: Classe unique avec toutes les données et analyses de mouvement
/// ============================================================================

class MovementData {
  /// ========== PROPRIÉTÉS ORIGINALES ==========

  /// Timestamp en millisecondes
  final int timestampMs;

  /// Temps actif basé sur magnitude (ms)
  final int magnitudeActiveTime;

  /// Temps actif basé sur axes (ms)
  final int axisActiveTime;

  /// Détection de mouvement active
  final bool movementDetected;

  /// Tout mouvement détecté
  final bool anyMovement;

  /// Accélération X en g
  final double accelX;

  /// Accélération Y en g
  final double accelY;

  /// Accélération Z en g
  final double accelZ;

  /// ========== SEUILS D'ACCÉLÉRATION ==========
  static const double IMMOBILE_THRESHOLD = 0.1;
  static const double VERY_LOW_THRESHOLD = 0.5;
  static const double LOW_THRESHOLD = 1.0;
  static const double MODERATE_THRESHOLD = 2.0;
  static const double HIGH_THRESHOLD = 3.5;

  MovementData({
    required this.timestampMs,
    required this.magnitudeActiveTime,
    required this.axisActiveTime,
    required this.movementDetected,
    required this.anyMovement,
    required this.accelX,
    required this.accelY,
    required this.accelZ,
  });

  /// ========== CONSTRUCTEURS ==========

  /// Crée une instance à partir d'une map (sérialisation)
  factory MovementData.fromMap(Map<String, dynamic> map) {
    return MovementData(
      timestampMs: map['timestampMs'] as int,
      magnitudeActiveTime: map['magnitudeActiveTime'] as int,
      axisActiveTime: map['axisActiveTime'] as int,
      movementDetected: map['movementDetected'] as bool,
      anyMovement: map['anyMovement'] as bool,
      accelX: map['accelX'] as double,
      accelY: map['accelY'] as double,
      accelZ: map['accelZ'] as double,
    );
  }


  factory MovementData.fromBytes(List<int> bytes) {
    final buffer = ByteData.sublistView(Uint8List.fromList(bytes));

    return MovementData(
      timestampMs: buffer.getUint32(0, Endian.little),
      magnitudeActiveTime: buffer.getUint32(4, Endian.little),
      axisActiveTime: buffer.getUint32(8, Endian.little),
      movementDetected: buffer.getUint8(12) != 0,
      anyMovement: buffer.getUint8(13) != 0,

      //Conversion: int16 → double (en g)
      accelX: buffer.getInt16(14, Endian.little) / 100.0,
      accelY: buffer.getInt16(16, Endian.little) / 100.0,
      accelZ: buffer.getInt16(18, Endian.little) / 100.0,
    );
  }

  /// Convertit en map
  Map<String, dynamic> toMap() {
    return {
      'timestampMs': timestampMs,
      'magnitudeActiveTime': magnitudeActiveTime,
      'axisActiveTime': axisActiveTime,
      'movementDetected': movementDetected,
      'anyMovement': anyMovement,
      'accelX': accelX,
      'accelY': accelY,
      'accelZ': accelZ,
    };
  }


  /// ========== MÉTHODES ORIGINALES ==========

  /// Formate le temps actif en format lisible
  /// Exemple: "2 h 30 m" ou "45 s"
  String getAxisActiveTimeFormatted() {
    int seconds = axisActiveTime ~/ 1000;
    int minutes = seconds ~/ 60;
    int hours = minutes ~/ 60;

    if (hours > 0) {
      return "$hours h ${minutes % 60} m";
    } else if (minutes > 0) {
      return "$minutes m ${seconds % 60} s";
    } else {
      return "$seconds s";
    }
  }

  /// Formate le temps actif de magnitude en format lisible
  String getMagnitudeActiveTimeFormatted() {
    int seconds = magnitudeActiveTime ~/ 1000;
    int minutes = seconds ~/ 60;
    int hours = minutes ~/ 60;

    if (hours > 0) {
      return "$hours h ${minutes % 60} m";
    } else if (minutes > 0) {
      return "$minutes m ${seconds % 60} s";
    } else {
      return "$seconds s";
    }
  }

  /// Calcule la magnitude de l'accélération (en g)
  /// magnitude = sqrt(x² + y² + z²)
  double getAccelerationMagnitude() {
    return math.sqrt(accelX * accelX + accelY * accelY + accelZ * accelZ);
  }

  /// Détermine le niveau d'activité (0-100)
  int getActivityLevel() {
    final magnitude = getAccelerationMagnitude();

    if (magnitude < IMMOBILE_THRESHOLD) return 0;      // Immobile
    if (magnitude < VERY_LOW_THRESHOLD) return 25;     // Très faible
    if (magnitude < LOW_THRESHOLD) return 50;          // Faible
    if (magnitude < MODERATE_THRESHOLD) return 75;     // Modéré
    return 100;                                        // Élevé
  }

  /// Catégorise le niveau d'activité en texte lisible
  String getActivityCategory() {
    final level = getActivityLevel();

    switch (level) {
      case 0:
        return 'Immobile';
      case 25:
        return 'Très faible';
      case 50:
        return 'Faible';
      case 75:
        return 'Modéré';
      case 100:
        return 'Élevé';
      default:
        return 'Inconnu';
    }
  }

  /// ========== NOUVELLES MÉTHODES D'ANALYSE ==========

  /// Détecte le type de mouvement
  MovementType detectMovementType() {
    final magnitude = getAccelerationMagnitude();
    final isHighActivity = movementDetected && magnitude > MODERATE_THRESHOLD;
    final isRhythmic = _isRhythmicMovement();

    if (magnitude < IMMOBILE_THRESHOLD) {
      return MovementType.stationary;
    } else if (isRhythmic && isHighActivity) {
      return MovementType.running;
    } else if (isRhythmic) {
      return MovementType.walking;
    } else if (magnitude > LOW_THRESHOLD) {
      return MovementType.active;
    } else {
      return MovementType.idle;
    }
  }

  /// Vérifie si le mouvement est rythmique (walking/running)
  bool _isRhythmicMovement() {
    final axisVariance = (accelX.abs() + accelY.abs() + accelZ.abs()) / 3;
    return axisVariance > LOW_THRESHOLD && axisVariance < HIGH_THRESHOLD;
  }

  /// Variance des axes (pour détecter les tremblements)
  double getAxisVariance() {
    final mean = (accelX.abs() + accelY.abs() + accelZ.abs()) / 3;
    final variance = math.pow(accelX.abs() - mean, 2) +
        math.pow(accelY.abs() - mean, 2) +
        math.pow(accelZ.abs() - mean, 2);
    return math.sqrt(variance / 3);
  }

  /// Dominance d'un axe (0 = équilibré, 1 = un axe domine)
  double getAxisDominance() {
    final absX = accelX.abs();
    final absY = accelY.abs();
    final absZ = accelZ.abs();
    final magnitude = getAccelerationMagnitude();

    if (magnitude == 0) return 0;

    final maxAxis = [absX, absY, absZ].reduce(math.max);
    return maxAxis / magnitude;
  }

  /// Stabilité du mouvement (0-1, 1 = très stable)
  double getStability() {
    final variance = getAxisVariance();
    return math.exp(-variance).clamp(0.0, 1.0);
  }

  /// Énergie du mouvement (basée sur magnitude)
  double getMovementEnergy() {
    final magnitude = getAccelerationMagnitude();
    return magnitude * magnitude; // E = m*v²
  }

  /// Orientation dominante (X, Y, Z ou BALANCED)
  String getDominantAxis() {
    final absX = accelX.abs();
    final absY = accelY.abs();
    final absZ = accelZ.abs();

    if (absX > absY && absX > absZ) return 'X';
    if (absY > absX && absY > absZ) return 'Y';
    if (absZ > absX && absZ > absY) return 'Z';
    return 'BALANCED';
  }

  /// Intensité du mouvement (description)
  String getIntensityDescription() {
    final magnitude = getAccelerationMagnitude();

    if (magnitude < IMMOBILE_THRESHOLD) return 'Pas de mouvement';
    if (magnitude < VERY_LOW_THRESHOLD) return 'Très léger';
    if (magnitude < LOW_THRESHOLD) return 'Léger';
    if (magnitude < MODERATE_THRESHOLD) return 'Modéré';
    if (magnitude < HIGH_THRESHOLD) return 'Intense';
    return 'Très intense';
  }

  /// ========== SÉRIALISATION COMPLÈTE ==========

  /// JSON complet pour enregistrement en BD
  Map<String, dynamic> toJsonComplete() {
    final magnitude = getAccelerationMagnitude();

    return {
      'acceleration': {
        'x': accelX,
        'y': accelY,
        'z': accelZ,
        'magnitude': magnitude,
      },
      'activity': {
        'level': getActivityLevel(),
        'category': getActivityCategory(),
        'type': detectMovementType().name,
        'intensity': getIntensityDescription(),
      },
      'analysis': {
        'axisVariance': getAxisVariance(),
        'axisDominance': getAxisDominance(),
        'dominantAxis': getDominantAxis(),
        'stability': getStability(),
        'energy': getMovementEnergy(),
      },
      'timing': {
        'magnitudeActiveTime': magnitudeActiveTime,
        'axisActiveTime': axisActiveTime,
        'detected': movementDetected,
        'anyMovement': anyMovement,
        'timestampMs': timestampMs,
      },
    };
  }

  /// JSON compact pour réduire la taille en BD
  Map<String, dynamic> toJsonCompact() {
    return {
      'x': accelX,
      'y': accelY,
      'z': accelZ,
      'm': getAccelerationMagnitude(),
      'l': getActivityLevel(),
      'c': getActivityCategory()[0],
      't': detectMovementType().index,
      'e': getMovementEnergy(),
      'ts': timestampMs,
    };
  }

  /// ========== RÉSUMÉ ==========

  /// Résumé textuel
  String get summary {
    return 'Movement(time: ${getAxisActiveTimeFormatted()}, '
        'moving: $anyMovement, '
        'magnitude: ${getAccelerationMagnitude().toStringAsFixed(2)}g, '
        'type: ${detectMovementType().name}, '
        'stability: ${getStability().toStringAsFixed(2)})';
  }

  /// Résumé détaillé avec tous les paramètres
  String getDetailedSummary() {
    return '''
╔════════════════════════════════════════╗
║       MOUVEMENT DÉTAILLÉ               ║
╠════════════════════════════════════════╣
║ Accélération:
║   X: ${accelX.toStringAsFixed(2)} g
║   Y: ${accelY.toStringAsFixed(2)} g
║   Z: ${accelZ.toStringAsFixed(2)} g
║   Magnitude: ${getAccelerationMagnitude().toStringAsFixed(2)} g
║
║ Activité:
║   Niveau: ${getActivityLevel()}/100
║   Catégorie: ${getActivityCategory()}
║   Type: ${detectMovementType().name}
║   Intensité: ${getIntensityDescription()}
║
║ Analyse:
║   Stabilité: ${getStability().toStringAsFixed(2)}
║   Énergie: ${getMovementEnergy().toStringAsFixed(2)}
║   Variance: ${getAxisVariance().toStringAsFixed(2)}
║   Axe dominant: ${getDominantAxis()}
║
║ Timing:
║   Temps actif (axe): ${getAxisActiveTimeFormatted()}
║   Temps actif (magnitude): ${getMagnitudeActiveTimeFormatted()}
║   Détecté: $movementDetected
╚════════════════════════════════════════╝
    ''';
  }

  @override
  String toString() => summary;

  /// ========== ÉGALITÉ ET HASH ==========

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is MovementData &&
              runtimeType == other.runtimeType &&
              timestampMs == other.timestampMs &&
              accelX == other.accelX &&
              accelY == other.accelY &&
              accelZ == other.accelZ;

  @override
  int get hashCode =>
      timestampMs.hashCode ^
      accelX.hashCode ^
      accelY.hashCode ^
      accelZ.hashCode;
}

/// ============================================================================
/// ENUM: Types de mouvement
/// ============================================================================

enum MovementType {
  stationary,  // Immobile
  idle,        // Très peu de mouvement
  walking,     // Marche
  running,     // Course
  active,      // Activité physique générale
  unknown,     // Inconnu
}
