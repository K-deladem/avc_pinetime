// ============================================================================
// SERVICE: COMPARISON & SYNTHESIS SERVICE
// Description: Service pour comparer et synthétiser les données des deux bras
// ============================================================================

import 'package:flutter_bloc_app_template/app/app_database.dart';
import 'package:flutter_bloc_app_template/models/arm_side.dart';
import 'package:flutter_bloc_app_template/models/chart_data_point.dart';
import 'package:flutter_bloc_app_template/models/connection_event.dart';
import 'package:flutter_bloc_app_template/models/battery_data.dart';
import 'package:flutter_bloc_app_template/models/daily_synthesis.dart';
import 'package:flutter_bloc_app_template/models/step_data.dart';
import 'dart:math' show sqrt;

import '../models/arm_comparison.dart';


// ============================================================================
// SERVICE DE COMPARAISON ET SYNTHÈSE
// ============================================================================

class ComparisonSynthesisService {
  final AppDatabase _db = AppDatabase.instance;

  // ========== CACHE EN MÉMOIRE ==========
  // Évite de recalculer constamment les mêmes données
  final Map<String, CachedData> _cache = {};
  static const Duration _cacheValidity = Duration(minutes: 5);

  // ========== SINGLETON ==========
  static final ComparisonSynthesisService _instance =
  ComparisonSynthesisService._internal();

  factory ComparisonSynthesisService() => _instance;

  ComparisonSynthesisService._internal();

  // ============================================================================
  // COMPARAISON EN TEMPS RÉEL
  // ============================================================================

  /// Compare les dernières valeurs des deux bras
  Future<Map<String, ArmComparison>> getCurrentComparison() async {
    final cacheKey = 'current_comparison';

    // Vérifier le cache
    if (_isCacheValid(cacheKey)) {
      return _cache[cacheKey]!.data as Map<String, ArmComparison>;
    }

    // Récupérer les dernières valeurs pour chaque bras en utilisant les nouvelles méthodes
    final leftBattery = await _db.getLatestDeviceInfo('left', 'battery');
    final rightBattery = await _db.getLatestDeviceInfo('right', 'battery');

    final leftSteps = await _db.getLatestDeviceInfo('left', 'steps');
    final rightSteps = await _db.getLatestDeviceInfo('right', 'steps');


    final comparison = <String, ArmComparison>{};

    // Comparer battery
    if (leftBattery != null && rightBattery != null) {
      final leftValue = leftBattery.value.toDouble();
      final rightValue = rightBattery.value.toDouble();
      final asymmetry = _calculateAsymmetry(leftValue, rightValue);
      final dominant = _determineDominant(leftValue, rightValue, 'battery');
      final difference = ((leftValue - rightValue).abs() /
          ((leftValue + rightValue) / 2) * 100);

      comparison['battery'] = ArmComparison(
        side: ArmSide.left,
        timestamp: leftBattery.timestamp,
        battery: leftValue,
        asymmetryScore: asymmetry,
        dominantArm: dominant,
        activityDifference: difference,
      );
    }



    // Comparer steps
    if (leftSteps != null && rightSteps != null) {
      final leftValue = leftSteps.value.toDouble();
      final rightValue = rightSteps.value.toDouble();
      final asymmetry = _calculateAsymmetry(leftValue, rightValue);
      final dominant = _determineDominant(leftValue, rightValue, 'steps');
      final difference = ((leftValue - rightValue).abs() /
          ((leftValue + rightValue) / 2) * 100);

      comparison['steps'] = ArmComparison(
        side: ArmSide.left,
        timestamp: leftSteps.timestamp,
        steps: leftValue.toInt(),
        asymmetryScore: asymmetry,
        dominantArm: dominant,
        activityDifference: difference,
      );
    }



    // Mettre en cache
    _cache[cacheKey] = CachedData(
      data: comparison,
      timestamp: DateTime.now(),
    );

    return comparison;
  }

  // ============================================================================
  // SYNTHÈSE QUOTIDIENNE
  // ============================================================================

  /// Génère une synthèse quotidienne complète
  Future<DailySynthesis> getDailySynthesis(DateTime date) async {
    final cacheKey = 'daily_synthesis_${date.toIso8601String().split('T')[0]}';

    if (_isCacheValid(cacheKey)) {
      return _cache[cacheKey]!.data as DailySynthesis;
    }

    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    // Récupérer toutes les données de la journée avec les nouvelles méthodes
    final leftSteps = await _db.getDeviceInfo('left', 'steps',
      startDate: startOfDay, endDate: endOfDay,
    );

    final rightSteps = await _db.getDeviceInfo(
      'right',
      'steps',
      startDate: startOfDay,
      endDate: endOfDay,
    );


    // Récupérer événements de connexion
    final leftConnections = await _db.getDailyConnectionEvents('left', date);
    final rightConnections = await _db.getDailyConnectionEvents('right', date);

    // Calculer les métriques avec les nouvelles données typées
    final int totalStepsLeft = leftSteps.isNotEmpty ? leftSteps.last.value.toInt() : 0;
    final int totalStepsRight = rightSteps.isNotEmpty ? rightSteps.last.value.toInt() : 0;

    final connectedTimeLeft = _calculateConnectedTime(leftConnections);
    final connectedTimeRight = _calculateConnectedTime(rightConnections);

    // Calculer asymétrie moyenne
    final stepAsymmetry = _calculateAsymmetry(
      totalStepsLeft.toDouble(),
      totalStepsRight.toDouble(),
    );

    final asymmetryAverage = (stepAsymmetry ) / 2;

    // Déterminer bras dominant
    final dominantArm = totalStepsLeft > totalStepsRight
        ? ArmSide.left
        : (totalStepsRight > totalStepsLeft ? ArmSide.right : null);

    // Générer recommandations
    final recommendations = _generateRecommendations(
      asymmetryAverage: asymmetryAverage,
      stepsLeft: totalStepsLeft,
      stepsRight: totalStepsRight,
    );

    final synthesis = DailySynthesis(
      date: startOfDay,
      dominantArm: dominantArm,
      asymmetryAverage: asymmetryAverage,
      totalStepsLeft: totalStepsLeft,
      totalStepsRight: totalStepsRight,
      connectedTimeLeft: connectedTimeLeft,
      connectedTimeRight: connectedTimeRight,
      recommendations: recommendations,
    );

    // Mettre en cache (plus long pour synthèse quotidienne)
    _cache[cacheKey] = CachedData(
      data: synthesis,
      timestamp: DateTime.now(),
      validity: const Duration(hours: 1), // Cache 1 heure pour synthèse
    );

    return synthesis;
  }

  // ============================================================================
  // DONNÉES POUR GRAPHIQUES
  // ============================================================================

  /// Génère les données pour un graphique de comparaison
  Future<List<ChartDataPoint>> getChartData({
    required String sensorType,
    required DateTime startDate,
    required DateTime endDate,
    Duration? samplingInterval, // Intervalle d'échantillonnage (ex: 1 heure)
  }) async {
    final cacheKey = 'chart_${sensorType}_${startDate.millisecondsSinceEpoch}_${endDate.millisecondsSinceEpoch}';

    if (_isCacheValid(cacheKey)) {
      return _cache[cacheKey]!.data as List<ChartDataPoint>;
    }

    // Récupérer les données brutes selon le type de capteur
    List<dynamic> leftData;
    List<dynamic> rightData;

    switch (sensorType) {
      case 'battery':
        leftData = await _db.getDeviceInfo('left','battery', startDate: startDate, endDate: endDate, limit: 10000);
        rightData = await _db.getDeviceInfo('right','battery', startDate: startDate, endDate: endDate, limit: 10000);
        break;
      case 'steps':
        leftData = await _db.getDeviceInfo('left','steps', startDate: startDate, endDate: endDate, limit: 10000);
        rightData = await _db.getDeviceInfo('right','steps', startDate: startDate, endDate: endDate, limit: 10000);
        break;

      default:
        // Pour types inconnus, retourner liste vide
        leftData = [];
        rightData = [];
    }

    // Agréger par intervalle si nécessaire
    List<ChartDataPoint> points;
    if (samplingInterval != null) {
      points = _aggregateByInterval(
        leftData: leftData,
        rightData: rightData,
        sensorType: sensorType,
        interval: samplingInterval,
        startDate: startDate,
        endDate: endDate,
      );
    } else {
      points = _mergeDataPoints(leftData, rightData, sensorType);
    }

    // Mettre en cache
    _cache[cacheKey] = CachedData(
      data: points,
      timestamp: DateTime.now(),
    );

    return points;
  }

  /// Génère un graphique d'asymétrie dans le temps
  Future<List<ChartDataPoint>> getAsymmetryTrend({
    required String sensorType,
    required DateTime startDate,
    required DateTime endDate,
    Duration interval = const Duration(hours: 1),
  }) async {
    final chartData = await getChartData(
      sensorType: sensorType,
      startDate: startDate,
      endDate: endDate,
      samplingInterval: interval,
    );

    // Calculer l'asymétrie pour chaque point
    return chartData.map((point) {
      if (point.leftValue != null && point.rightValue != null) {
        final asymmetry = _calculateAsymmetry(
          point.leftValue!,
          point.rightValue!,
        );
        return ChartDataPoint(
          timestamp: point.timestamp,
          leftValue: point.leftValue,
          rightValue: point.rightValue,
          difference: (point.leftValue! - point.rightValue!).abs(),
          ratio: asymmetry,
        );
      }
      return point;
    }).toList();
  }

  // ============================================================================
  // STATISTIQUES AVANCÉES
  // ============================================================================

  /// Calcule des statistiques comparatives sur une période
  Future<Map<String, dynamic>> getComparativeStats({
    required Duration period,
    DateTime? endDate,
  }) async {
    final end = endDate ?? DateTime.now();
    final start = end.subtract(period);

    final stats = <String, dynamic>{};

    // Steps
    final leftSteps = await _db.getDeviceInfo('left','steps', startDate: start, endDate: end);
    final rightSteps = await _db.getDeviceInfo('right','steps', startDate: start, endDate: end);

    if (leftSteps.isNotEmpty && rightSteps.isNotEmpty) {
      final leftValues = leftSteps.map((d) => d.value.toDouble()).toList();
      final rightValues = rightSteps.map((d) => d.value.toDouble()).toList();

      stats['steps'] = {
        'left': {
          'min': leftValues.reduce((a, b) => a < b ? a : b),
          'max': leftValues.reduce((a, b) => a > b ? a : b),
          'avg': leftValues.reduce((a, b) => a + b) / leftValues.length,
          'count': leftValues.length,
        },
        'right': {
          'min': rightValues.reduce((a, b) => a < b ? a : b),
          'max': rightValues.reduce((a, b) => a > b ? a : b),
          'avg': rightValues.reduce((a, b) => a + b) / rightValues.length,
          'count': rightValues.length,
        },
        'comparison': {
          'avgDifference': ((leftValues.reduce((a, b) => a + b) / leftValues.length) -
              (rightValues.reduce((a, b) => a + b) / rightValues.length)).abs(),
          'correlationScore': _calculateCorrelation(leftValues, rightValues),
        },
      };
    }

    return stats;
  }

  /// Détecte les anomalies dans la symétrie
  Future<List<Map<String, dynamic>>> detectAnomalies({
    required Duration period,
    double asymmetryThreshold = 30.0, // Seuil d'asymétrie anormale (%)
  }) async {
    final end = DateTime.now();
    final start = end.subtract(period);
    final anomalies = <Map<String, dynamic>>[];

    // Détecter anomalies pour steps
    final leftSteps = await _db.getDeviceInfo('left','steps', startDate: start, endDate: end);
    final rightSteps = await _db.getDeviceInfo('right','steps', startDate: start, endDate: end);

    for (var i = 0; i < leftSteps.length && i < rightSteps.length; i++) {
      final leftValue = leftSteps[i].value.toDouble();
      final rightValue = rightSteps[i].value.toDouble();
      final asymmetry = _calculateAsymmetry(leftValue, rightValue);

      if (asymmetry > asymmetryThreshold) {
        anomalies.add({
          'timestamp': leftSteps[i].timestamp,
          'sensorType': 'steps',
          'leftValue': leftValue,
          'rightValue': rightValue,
          'asymmetry': asymmetry,
          'severity': asymmetry > 50 ? 'high' : 'medium',
        });
      }
    }



    return anomalies;
  }

  // ============================================================================
  // MÉTHODES UTILITAIRES
  // ============================================================================

  /// Calcule le score d'asymétrie (0-100)
  double _calculateAsymmetry(double left, double right) {
    if (left == 0 && right == 0) return 0;
    final max = left > right ? left : right;
    final min = left < right ? left : right;
    return ((max - min) / max * 100).clamp(0, 100);
  }

  /// Détermine le bras dominant
  String _determineDominant(double left, double right, String sensorType) {
    const threshold = 5.0; // 5% de différence minimum
    final diff = ((left - right).abs() / ((left + right) / 2) * 100);

    if (diff < threshold) return 'balanced';

    // Pour les pas, plus = dominant
    if (sensorType == 'steps') {
      return left > right ? 'left' : 'right';
    }

    // Pour HR, plus proche de la normale = dominant
    const normalHr = 70.0;
    return (left - normalHr).abs() < (right - normalHr).abs() ? 'left' : 'right';
  }


  /// Calcule le temps de connexion total
  Duration _calculateConnectedTime(List<dynamic> events) {
    int totalSeconds = 0;
    for (final event in events) {
      if (event.type == ConnectionEventType.disconnected &&
          event.durationSeconds != null) {
        totalSeconds += (event.durationSeconds as num).toInt();
      }
    }
    return Duration(seconds: totalSeconds);
  }

  /// Fusionne les données des deux bras par timestamp
  List<ChartDataPoint> _mergeDataPoints(
      List<dynamic> leftData,
      List<dynamic> rightData,
      String sensorType,
      ) {
    final points = <ChartDataPoint>[];
    final Map<DateTime, ChartDataPoint> pointMap = {};

    // Extraire la valeur selon le type de capteur
    double _extractValue(dynamic data, String sensorType) {
      if (data is BatteryData) return data.level.toDouble();
      if (data is StepData) return data.stepCount.toDouble();
      return 0.0;
    }

    DateTime _extractTimestamp(dynamic data) {
      if (data is BatteryData) return data.timestamp;
      if (data is StepData) return data.timestamp;
      return DateTime.now();
    }

    // Ajouter les données gauches
    for (final data in leftData) {
      final timestamp = _extractTimestamp(data);
      pointMap[timestamp] = ChartDataPoint(
        timestamp: timestamp,
        leftValue: _extractValue(data, sensorType),
        rightValue: null,
      );
    }

    // Ajouter les données droites
    for (final data in rightData) {
      final timestamp = _extractTimestamp(data);
      if (pointMap.containsKey(timestamp)) {
        pointMap[timestamp] = ChartDataPoint(
          timestamp: timestamp,
          leftValue: pointMap[timestamp]!.leftValue,
          rightValue: _extractValue(data, sensorType),
        );
      } else {
        pointMap[timestamp] = ChartDataPoint(
          timestamp: timestamp,
          leftValue: null,
          rightValue: _extractValue(data, sensorType),
        );
      }
    }

    // Convertir en liste triée
    points.addAll(pointMap.values);
    points.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    return points;
  }

  /// Agrège les données par intervalle
  List<ChartDataPoint> _aggregateByInterval({
    required List<dynamic> leftData,
    required List<dynamic> rightData,
    required String sensorType,
    required Duration interval,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final points = <ChartDataPoint>[];
    var currentTime = startDate;

    // Extraire la valeur selon le type de capteur
    double _extractValue(dynamic data, String sensorType) {
      if (data is BatteryData) return data.level.toDouble();
      if (data is StepData) return data.stepCount.toDouble();
      return 0.0;
    }

    DateTime _extractTimestamp(dynamic data) {
      if (data is BatteryData) return data.timestamp;
      if (data is StepData) return data.timestamp;
      return DateTime.now();
    }

    while (currentTime.isBefore(endDate)) {
      final nextTime = currentTime.add(interval);

      // Filtrer les données dans cet intervalle
      final leftInInterval = leftData.where((d) {
        final timestamp = _extractTimestamp(d);
        return timestamp.isAfter(currentTime) && timestamp.isBefore(nextTime);
      }).toList();

      final rightInInterval = rightData.where((d) {
        final timestamp = _extractTimestamp(d);
        return timestamp.isAfter(currentTime) && timestamp.isBefore(nextTime);
      }).toList();

      // Calculer les moyennes
      final leftAvg = leftInInterval.isNotEmpty
          ? leftInInterval.map((d) => _extractValue(d, sensorType)).reduce((a, b) => a + b) / leftInInterval.length
          : null;

      final rightAvg = rightInInterval.isNotEmpty
          ? rightInInterval.map((d) => _extractValue(d, sensorType)).reduce((a, b) => a + b) / rightInInterval.length
          : null;

      if (leftAvg != null || rightAvg != null) {
        points.add(ChartDataPoint(
          timestamp: currentTime,
          leftValue: leftAvg,
          rightValue: rightAvg,
        ));
      }

      currentTime = nextTime;
    }

    return points;
  }

  /// Calcule une corrélation simple entre deux séries
  double _calculateCorrelation(List<double> left, List<double> right) {
    if (left.length != right.length || left.isEmpty) return 0.0;

    final n = left.length;
    final leftMean = left.reduce((a, b) => a + b) / n;
    final rightMean = right.reduce((a, b) => a + b) / n;

    double numerator = 0;
    double leftDenom = 0;
    double rightDenom = 0;

    for (var i = 0; i < n; i++) {
      final leftDiff = left[i] - leftMean;
      final rightDiff = right[i] - rightMean;
      numerator += leftDiff * rightDiff;
      leftDenom += leftDiff * leftDiff;
      rightDenom += rightDiff * rightDiff;
    }

    if (leftDenom == 0 || rightDenom == 0) return 0.0;

    return numerator / (sqrt(leftDenom) * sqrt(rightDenom));
  }

  /// Génère des recommandations basées sur les données
  Map<String, dynamic> _generateRecommendations({
    required double asymmetryAverage,
    required int stepsLeft,
    required int stepsRight,
  }) {
    final recommendations = <String, dynamic>{
      'alerts': <String>[],
      'suggestions': <String>[],
      'severity': 'normal',
    };

    // Vérifier asymétrie critique
    if (asymmetryAverage > 40) {
      recommendations['alerts'].add(
        'Asymétrie élevée détectée (${asymmetryAverage.toStringAsFixed(1)}%). '
            'Consultez un professionnel de santé.',
      );
      recommendations['severity'] = 'high';
    } else if (asymmetryAverage > 25) {
      recommendations['suggestions'].add(
        'Asymétrie modérée. Essayez d\'équilibrer vos activités.',
      );
      recommendations['severity'] = 'medium';
    }

    // Vérifier différence de pas
    final stepDiff = (stepsLeft - stepsRight).abs();
    if (stepDiff > 1000) {
      final dominant = stepsLeft > stepsRight ? 'gauche' : 'droit';
      recommendations['suggestions'].add(
        'Différence de $stepDiff pas. Bras $dominant plus actif.',
      );
    }


    return recommendations;
  }

  /// Vide le cache
  void clearCache() {
    _cache.clear();
  }

  /// Vide un élément spécifique du cache
  void clearCacheItem(String key) {
    _cache.remove(key);
  }

  /// Vérifie si le cache est valide
  bool _isCacheValid(String key) {
    if (!_cache.containsKey(key)) return false;
    final cached = _cache[key]!;
    final validity = cached.validity ?? _cacheValidity;
    return DateTime.now().difference(cached.timestamp) < validity;
  }
}

// ============================================================================
// CLASSE UTILITAIRE POUR LE CACHE
// ============================================================================

class CachedData {
  final dynamic data;
  final DateTime timestamp;
  final Duration? validity;

  CachedData({
    required this.data,
    required this.timestamp,
    this.validity,
  });
}

