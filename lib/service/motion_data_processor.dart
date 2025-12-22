// service/motion_data_processor.dart

import 'dart:collection';
import 'dart:math' as math;
import 'package:flutter_bloc_app_template/models/sensor_metrics.dart';

/// ============================================================================
/// SERVICE: MotionDataProcessor
/// Description: Traitement optimisé des données brutes d'accéléromètre
/// ============================================================================
///
/// Ce service implémente un pipeline complet de traitement :
/// 1. Réception des données brutes (x, y, z)
/// 2. Filtrage du bruit (filtre médian + passe-bas)
/// 3. Calcul de la magnitude
/// 4. Lissage des valeurs
/// 5. Détection d'activité
/// 6. Génération des données traitées finales
///
/// Optimisé pour smartphone (peu de ressources)
/// ============================================================================

class MotionDataProcessor {
  // ========== CONSTANTES DE CONFIGURATION ==========

  /// Taille de la fenêtre pour le filtre médian (doit être impair)
  static const int MEDIAN_WINDOW_SIZE = 5;

  /// Coefficient du filtre passe-bas (0-1, plus petit = plus de lissage)
  /// alpha = 0.3 signifie 30% nouvelle valeur + 70% ancienne valeur
  static const double LOW_PASS_ALPHA = 0.3;

  /// Taille de la fenêtre pour la moyenne mobile
  static const int MOVING_AVERAGE_WINDOW = 10;

  /// Seuils d'activité (en unités d'accéléromètre)
  static const double ACTIVITY_THRESHOLD_LOW = 100.0;
  static const double ACTIVITY_THRESHOLD_MEDIUM = 500.0;
  static const double ACTIVITY_THRESHOLD_HIGH = 1000.0;
  static const double ACTIVITY_THRESHOLD_VERY_HIGH = 2000.0;

  /// Seuil de mouvement pour magnitudeActiveTime
  static const double MAGNITUDE_ACTIVE_THRESHOLD = 200.0;

  /// Seuil de mouvement pour axisActiveTime (sur un axe individuel)
  static const int AXIS_ACTIVE_THRESHOLD = 50;

  /// Intervalle entre les échantillons (en millisecondes)
  static const int SAMPLING_INTERVAL_MS = 100; // 10 Hz

  // ========== BUFFERS ET ÉTAT ==========

  /// Buffer circulaire pour le filtre médian (par côté)
  final Map<String, Queue<RawMotionData>> _medianBuffers = {
    'left': Queue<RawMotionData>(),
    'right': Queue<RawMotionData>(),
  };

  /// Buffer pour la moyenne mobile (par côté)
  final Map<String, Queue<double>> _movingAverageBuffers = {
    'left': Queue<double>(),
    'right': Queue<double>(),
  };

  /// Dernière valeur filtrée (pour le filtre passe-bas)
  final Map<String, double> _lastFilteredValue = {
    'left': 0.0,
    'right': 0.0,
  };

  /// Cumul du temps actif par côté (en millisecondes)
  final Map<String, int> _magnitudeActiveTime = {
    'left': 0,
    'right': 0,
  };

  final Map<String, int> _axisActiveTime = {
    'left': 0,
    'right': 0,
  };

  /// Timestamp de la dernière mesure (pour calculer les temps actifs)
  final Map<String, DateTime?> _lastTimestamp = {
    'left': null,
    'right': null,
  };

  // ========== MÉTHODE PRINCIPALE ==========

  /// Traite des données brutes et retourne des données traitées
  ///
  /// Cette méthode applique tout le pipeline de traitement
  ProcessedMotionData processRawData(RawMotionData rawData) {
    final side = rawData.side;

    // ÉTAPE 1: Ajouter au buffer médian
    _addToMedianBuffer(rawData);

    // ÉTAPE 2: Appliquer le filtre médian
    final medianFiltered = _applyMedianFilter(side);
    if (medianFiltered == null) {
      // Pas assez de données, retourner valeur par défaut
      return _createDefaultProcessedData(rawData);
    }

    // ÉTAPE 3: Calculer la magnitude brute
    final rawMagnitude = math.sqrt(
      medianFiltered.x * medianFiltered.x +
          medianFiltered.y * medianFiltered.y +
          medianFiltered.z * medianFiltered.z,
    );

    // ÉTAPE 4: Appliquer le filtre passe-bas
    final lowPassFiltered = _applyLowPassFilter(side, rawMagnitude);

    // ÉTAPE 5: Appliquer la moyenne mobile pour le lissage final
    final smoothedMagnitude = _applyMovingAverage(side, lowPassFiltered);

    // ÉTAPE 6: Calculer la variance des axes
    final axisVariance = _calculateAxisVariance(medianFiltered);

    // ÉTAPE 7: Déterminer le niveau d'activité (0-100)
    final activityLevel = _calculateActivityLevel(smoothedMagnitude);

    // ÉTAPE 8: Mettre à jour les temps actifs
    _updateActiveTime(side, smoothedMagnitude, medianFiltered, rawData.timestamp);

    // ÉTAPE 9: Créer et retourner les données traitées
    return ProcessedMotionData(
      timestamp: rawData.timestamp,
      magnitude: lowPassFiltered,
      smoothedMagnitude: smoothedMagnitude,
      axisVariance: axisVariance,
      activityLevel: activityLevel,
      side: side,
      magnitudeActiveTimeMs: _magnitudeActiveTime[side]!,
      axisActiveTimeMs: _axisActiveTime[side]!,
    );
  }

  // ========== FILTRES ==========

  /// Ajoute une donnée au buffer médian
  void _addToMedianBuffer(RawMotionData data) {
    final buffer = _medianBuffers[data.side]!;

    buffer.add(data);

    // Garder uniquement les N dernières valeurs
    while (buffer.length > MEDIAN_WINDOW_SIZE) {
      buffer.removeFirst();
    }
  }

  /// Applique le filtre médian pour réduire les pics de bruit
  ///
  /// Le filtre médian est excellent pour éliminer les valeurs aberrantes
  /// tout en préservant les transitions rapides
  RawMotionData? _applyMedianFilter(String side) {
    final buffer = _medianBuffers[side]!;

    if (buffer.length < MEDIAN_WINDOW_SIZE) {
      return null; // Pas assez de données
    }

    // Extraire les valeurs x, y, z
    final xValues = buffer.map((d) => d.x).toList()..sort();
    final yValues = buffer.map((d) => d.y).toList()..sort();
    final zValues = buffer.map((d) => d.z).toList()..sort();

    // Calculer la médiane
    final medianIndex = MEDIAN_WINDOW_SIZE ~/ 2;

    return RawMotionData(
      timestamp: buffer.last.timestamp,
      x: xValues[medianIndex],
      y: yValues[medianIndex],
      z: zValues[medianIndex],
      side: side,
    );
  }

  /// Applique un filtre passe-bas pour lisser les variations rapides
  ///
  /// Formule : valeur_filtrée = alpha × nouvelle_valeur + (1 - alpha) × ancienne_valeur
  ///
  /// Ce filtre réduit le bruit haute fréquence tout en permettant
  /// aux changements lents de passer
  double _applyLowPassFilter(String side, double newValue) {
    final lastValue = _lastFilteredValue[side]!;

    // Si c'est la première valeur, l'utiliser directement
    if (lastValue == 0.0) {
      _lastFilteredValue[side] = newValue;
      return newValue;
    }

    // Appliquer le filtre
    final filtered = LOW_PASS_ALPHA * newValue + (1.0 - LOW_PASS_ALPHA) * lastValue;

    _lastFilteredValue[side] = filtered;
    return filtered;
  }

  /// Applique une moyenne mobile pour un lissage supplémentaire
  ///
  /// La moyenne mobile calcule la moyenne des N dernières valeurs
  double _applyMovingAverage(String side, double value) {
    final buffer = _movingAverageBuffers[side]!;

    buffer.add(value);

    // Garder uniquement les N dernières valeurs
    while (buffer.length > MOVING_AVERAGE_WINDOW) {
      buffer.removeFirst();
    }

    // Calculer la moyenne
    if (buffer.isEmpty) return value;

    final sum = buffer.fold<double>(0.0, (acc, val) => acc + val);
    return sum / buffer.length;
  }

  // ========== CALCULS D'ANALYSE ==========

  /// Calcule la variance des axes (mesure de la stabilité du mouvement)
  ///
  /// Une variance élevée indique un mouvement irrégulier
  /// Une variance faible indique un mouvement stable
  double _calculateAxisVariance(RawMotionData data) {
    final mean = (data.x.abs() + data.y.abs() + data.z.abs()) / 3.0;

    final variance = (math.pow(data.x.abs() - mean, 2) +
            math.pow(data.y.abs() - mean, 2) +
            math.pow(data.z.abs() - mean, 2)) /
        3.0;

    return math.sqrt(variance);
  }

  /// Calcule le niveau d'activité (0-100) basé sur la magnitude
  ///
  /// Utilise des seuils progressifs pour catégoriser l'intensité
  int _calculateActivityLevel(double magnitude) {
    if (magnitude < ACTIVITY_THRESHOLD_LOW) {
      // Immobile ou très faible
      return (magnitude / ACTIVITY_THRESHOLD_LOW * 10).round().clamp(0, 10);
    } else if (magnitude < ACTIVITY_THRESHOLD_MEDIUM) {
      // Faible
      final normalized = (magnitude - ACTIVITY_THRESHOLD_LOW) /
          (ACTIVITY_THRESHOLD_MEDIUM - ACTIVITY_THRESHOLD_LOW);
      return (10 + normalized * 30).round().clamp(10, 40);
    } else if (magnitude < ACTIVITY_THRESHOLD_HIGH) {
      // Modéré
      final normalized = (magnitude - ACTIVITY_THRESHOLD_MEDIUM) /
          (ACTIVITY_THRESHOLD_HIGH - ACTIVITY_THRESHOLD_MEDIUM);
      return (40 + normalized * 30).round().clamp(40, 70);
    } else if (magnitude < ACTIVITY_THRESHOLD_VERY_HIGH) {
      // Élevé
      final normalized = (magnitude - ACTIVITY_THRESHOLD_HIGH) /
          (ACTIVITY_THRESHOLD_VERY_HIGH - ACTIVITY_THRESHOLD_HIGH);
      return (70 + normalized * 20).round().clamp(70, 90);
    } else {
      // Très élevé
      return 100;
    }
  }

  /// Met à jour les temps actifs (magnitudeActiveTime et axisActiveTime)
  void _updateActiveTime(
    String side,
    double magnitude,
    RawMotionData data,
    DateTime currentTimestamp,
  ) {
    final lastTime = _lastTimestamp[side];

    if (lastTime != null) {
      final elapsed = currentTimestamp.difference(lastTime).inMilliseconds;

      // Vérifier si la magnitude dépasse le seuil
      if (magnitude >= MAGNITUDE_ACTIVE_THRESHOLD) {
        _magnitudeActiveTime[side] = _magnitudeActiveTime[side]! + elapsed;
      }

      // Vérifier si au moins un axe dépasse le seuil
      if (data.x.abs() >= AXIS_ACTIVE_THRESHOLD ||
          data.y.abs() >= AXIS_ACTIVE_THRESHOLD ||
          data.z.abs() >= AXIS_ACTIVE_THRESHOLD) {
        _axisActiveTime[side] = _axisActiveTime[side]! + elapsed;
      }
    }

    _lastTimestamp[side] = currentTimestamp;
  }

  // ========== UTILITAIRES ==========

  /// Crée des données traitées par défaut (quand pas assez de données)
  ProcessedMotionData _createDefaultProcessedData(RawMotionData rawData) {
    return ProcessedMotionData(
      timestamp: rawData.timestamp,
      magnitude: 0.0,
      smoothedMagnitude: 0.0,
      axisVariance: 0.0,
      activityLevel: 0,
      side: rawData.side,
      magnitudeActiveTimeMs: _magnitudeActiveTime[rawData.side]!,
      axisActiveTimeMs: _axisActiveTime[rawData.side]!,
    );
  }

  /// Réinitialise tous les buffers et compteurs pour un côté
  void resetSide(String side) {
    _medianBuffers[side]?.clear();
    _movingAverageBuffers[side]?.clear();
    _lastFilteredValue[side] = 0.0;
    _magnitudeActiveTime[side] = 0;
    _axisActiveTime[side] = 0;
    _lastTimestamp[side] = null;
  }

  /// Réinitialise complètement le processeur
  void resetAll() {
    resetSide('left');
    resetSide('right');
  }

  /// Obtient les temps actifs actuels
  Map<String, Map<String, int>> getActiveTimestats() {
    return {
      'left': {
        'magnitudeActiveTimeMs': _magnitudeActiveTime['left']!,
        'axisActiveTimeMs': _axisActiveTime['left']!,
      },
      'right': {
        'magnitudeActiveTimeMs': _magnitudeActiveTime['right']!,
        'axisActiveTimeMs': _axisActiveTime['right']!,
      },
    };
  }

  // ========== TRAITEMENT PAR BATCH ==========

  /// Traite un lot de données brutes en une seule fois
  ///
  /// Plus performant pour traiter plusieurs échantillons d'un coup
  List<ProcessedMotionData> processBatch(List<RawMotionData> rawDataList) {
    final results = <ProcessedMotionData>[];

    for (final rawData in rawDataList) {
      results.add(processRawData(rawData));
    }

    return results;
  }
}

/// ============================================================================
/// RÉSUMÉ DES VARIABLES FINALES À STOCKER EN BASE DE DONNÉES
/// ============================================================================
///
/// Pour optimiser les performances, stocker UNIQUEMENT ces champs :
///
/// TABLE: processed_motion_data
/// --------------------------------
/// - id                     : TEXT (PRIMARY KEY)
/// - timestamp              : TEXT (ISO 8601)
/// - side                   : TEXT ('left' ou 'right')
/// - smoothed_magnitude     : REAL (magnitude lissée finale)
/// - activity_level         : INTEGER (0-100)
/// - magnitude_active_time  : INTEGER (millisecondes cumulées)
/// - axis_active_time       : INTEGER (millisecondes cumulées)
///
/// NE PAS STOCKER :
/// - Les données brutes (x, y, z) → trop volumineuses
/// - Les valeurs intermédiaires de filtrage
/// - La magnitude non lissée
/// - L'axisVariance (sauf si nécessaire pour analyse approfondie)
///
/// ============================================================================
