// service/chart_data_adapter.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc_app_template/app/app_database.dart';
import 'package:flutter_bloc_app_template/models/arm_side.dart';
import 'package:flutter_bloc_app_template/ui/home/chart/reusable_comparison_chart.dart';

/// Service d'adaptation pour convertir les données DB en données pour graphiques
///
/// Ce service facilite l'utilisation du ReusableComparisonChart en fournissant
/// des méthodes prêtes à l'emploi pour chaque type de capteur
class ChartDataAdapter {
  final AppDatabase _db = AppDatabase.instance;

  // ========== PÉRIODES ==========

  DateTime _getStartDate(String period, DateTime? selectedDate) {
    final now = selectedDate ?? DateTime.now();
    switch (period) {
      case 'Jour':
        return DateTime(now.year, now.month, now.day);
      case 'Semaine':
        final weekday = now.weekday;
        final monday = now.subtract(Duration(days: weekday - 1));
        return DateTime(monday.year, monday.month, monday.day);
      case 'Mois':
        // Pour "Mois", afficher toute l'année (12 mois)
        return DateTime(now.year, 1, 1);
      default:
        return DateTime(now.year, now.month, now.day);
    }
  }

  DateTime _getEndDate(String period, DateTime? selectedDate) {
    final start = _getStartDate(period, selectedDate);
    switch (period) {
      case 'Jour':
        return start.add(const Duration(days: 1));
      case 'Semaine':
        return start.add(const Duration(days: 7));
      case 'Mois':
        // Pour "Mois", fin de l'année (12 mois)
        return DateTime(start.year + 1, 1, 1);
      default:
        return start.add(const Duration(days: 1));
    }
  }

  // ========== ADAPTATEURS PAR TYPE ==========

  /// Adaptateur pour les PAS (steps)
  Future<List<ChartDataPoint>> getStepsData(
    String period,
    DateTime? selectedDate,
  ) async {
    final start = _getStartDate(period, selectedDate);
    final end = _getEndDate(period, selectedDate);

    final leftData = await _db.getDeviceInfo(
      'left',
      'steps',
      startDate: start,
      endDate: end,
      limit: 1000,
    );

    final rightData = await _db.getDeviceInfo(
      'right',
      'steps',
      startDate: start,
      endDate: end,
      limit: 1000,
    );

    // Agréger par période
    return _aggregateStepsData(leftData, rightData, period);
  }

  /// Adaptateur pour la BATTERIE
  Future<List<ChartDataPoint>> getBatteryData(
    String period,
    DateTime? selectedDate,
  ) async {
    final start = _getStartDate(period, selectedDate);
    final end = _getEndDate(period, selectedDate);

    final leftData = await _db.getDeviceInfo(
      'left',
      'battery',
      startDate: start,
      endDate: end,
      limit: 1000,
    );

    final rightData = await _db.getDeviceInfo(
      'right',
      'battery',
      startDate: start,
      endDate: end,
      limit: 1000,
    );

    return _aggregateBatteryData(leftData, rightData, period);
  }

  /// Adaptateur pour MOTION MAGNITUDE
  Future<List<ChartDataPoint>> getMotionMagnitudeData(
    String period,
    DateTime? selectedDate,
  ) async {
    final start = _getStartDate(period, selectedDate);
    final end = _getEndDate(period, selectedDate);

    final leftData = await _db.getMovementData(
      'left',
      startDate: start,
      endDate: end,
      limit: 1000,
    );

    final rightData = await _db.getMovementData(
      'right',
      startDate: start,
      endDate: end,
      limit: 1000,
    );

    return _aggregateMovementData(leftData, rightData, period, 'magnitude');
  }

  /// Adaptateur pour ACTIVITY LEVEL
  Future<List<ChartDataPoint>> getActivityLevelData(
    String period,
    DateTime? selectedDate,
  ) async {
    final start = _getStartDate(period, selectedDate);
    final end = _getEndDate(period, selectedDate);

    final leftData = await _db.getMovementData(
      'left',
      startDate: start,
      endDate: end,
      limit: 1000,
    );

    final rightData = await _db.getMovementData(
      'right',
      startDate: start,
      endDate: end,
      limit: 1000,
    );

    return _aggregateMovementData(leftData, rightData, period, 'activityLevel');
  }

  /// Adaptateur pour MAGNITUDE ACTIVE TIME
  Future<List<ChartDataPoint>> getMagnitudeActiveTimeData(
    String period,
    DateTime? selectedDate,
  ) async {
    final start = _getStartDate(period, selectedDate);
    final end = _getEndDate(period, selectedDate);

    final leftData = await _db.getMovementData(
      'left',
      startDate: start,
      endDate: end,
      limit: 1000,
    );

    final rightData = await _db.getMovementData(
      'right',
      startDate: start,
      endDate: end,
      limit: 1000,
    );

    return _aggregateMovementData(leftData, rightData, period, 'magnitudeActiveTime');
  }

  /// Adaptateur pour AXIS ACTIVE TIME
  Future<List<ChartDataPoint>> getAxisActiveTimeData(
    String period,
    DateTime? selectedDate,
  ) async {
    final start = _getStartDate(period, selectedDate);
    final end = _getEndDate(period, selectedDate);

    final leftData = await _db.getMovementData(
      'left',
      startDate: start,
      endDate: end,
      limit: 1000,
    );

    final rightData = await _db.getMovementData(
      'right',
      startDate: start,
      endDate: end,
      limit: 1000,
    );

    return _aggregateMovementData(leftData, rightData, period, 'axisActiveTime');
  }


  // ========== MÉTHODES D'AGRÉGATION ==========

  List<ChartDataPoint> _aggregateStepsData(
    List<dynamic> leftData,
    List<dynamic> rightData,
    String period,
  ) {
    final Map<DateTime, Map<String, List<double>>> grouped = {};

    // Grouper gauche
    for (final data in leftData) {
      final groupedDate = _groupDateByPeriod(data.timestamp, period);
      grouped.putIfAbsent(groupedDate, () => {'left': [], 'right': []});
      grouped[groupedDate]!['left']!.add(data.value);
    }

    // Grouper droite
    for (final data in rightData) {
      final groupedDate = _groupDateByPeriod(data.timestamp, period);
      grouped.putIfAbsent(groupedDate, () => {'left': [], 'right': []});
      grouped[groupedDate]!['right']!.add(data.value);
    }

    // Générer des points fixes selon la période
    final points = <ChartDataPoint>[];
    final now = DateTime.now();

    switch (period) {
      case 'Jour':
        // 24 heures (0-23h)
        for (int hour = 0; hour < 24; hour++) {
          final timestamp = DateTime(now.year, now.month, now.day, hour);
          final values = grouped[timestamp] ?? {'left': [], 'right': []};
          points.add(ChartDataPoint(
            timestamp: timestamp,
            leftValue: values['left']!.isEmpty
                ? 0.0
                : values['left']!.reduce((a, b) => a + b) / values['left']!.length,
            rightValue: values['right']!.isEmpty
                ? 0.0
                : values['right']!.reduce((a, b) => a + b) / values['right']!.length,
          ));
        }
        break;

      case 'Semaine':
        // 7 jours de la semaine (Lun-Dim)
        final weekday = now.weekday;
        final monday = now.subtract(Duration(days: weekday - 1));
        for (int day = 0; day < 7; day++) {
          final timestamp = DateTime(monday.year, monday.month, monday.day + day);
          final values = grouped[timestamp] ?? {'left': [], 'right': []};
          points.add(ChartDataPoint(
            timestamp: timestamp,
            leftValue: values['left']!.isEmpty
                ? 0.0
                : values['left']!.reduce((a, b) => a + b) / values['left']!.length,
            rightValue: values['right']!.isEmpty
                ? 0.0
                : values['right']!.reduce((a, b) => a + b) / values['right']!.length,
          ));
        }
        break;

      case 'Mois':
        // 12 derniers mois
        for (int i = 11; i >= 0; i--) {
          final monthDate = DateTime(now.year, now.month - i, 1);
          final values = grouped[monthDate] ?? {'left': [], 'right': []};
          points.add(ChartDataPoint(
            timestamp: monthDate,
            leftValue: values['left']!.isEmpty
                ? 0.0
                : values['left']!.reduce((a, b) => a + b) / values['left']!.length,
            rightValue: values['right']!.isEmpty
                ? 0.0
                : values['right']!.reduce((a, b) => a + b) / values['right']!.length,
          ));
        }
        break;

      default:
        // Fallback au comportement par défaut
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
    }

    return points;
  }

  List<ChartDataPoint> _aggregateBatteryData(
    List<dynamic> leftData,
    List<dynamic> rightData,
    String period,
  ) {
    final Map<DateTime, Map<String, List<double>>> grouped = {};

    for (final data in leftData) {
      final groupedDate = _groupDateByPeriod(data.timestamp, period);
      grouped.putIfAbsent(groupedDate, () => {'left': [], 'right': []});
      grouped[groupedDate]!['left']!.add(data.value);
    }

    for (final data in rightData) {
      final groupedDate = _groupDateByPeriod(data.timestamp, period);
      grouped.putIfAbsent(groupedDate, () => {'left': [], 'right': []});
      grouped[groupedDate]!['right']!.add(data.value);
    }

    // Générer des points fixes selon la période
    final points = <ChartDataPoint>[];
    final now = DateTime.now();

    switch (period) {
      case 'Jour':
        // 24 heures (0-23h)
        for (int hour = 0; hour < 24; hour++) {
          final timestamp = DateTime(now.year, now.month, now.day, hour);
          final values = grouped[timestamp] ?? {'left': [], 'right': []};
          points.add(ChartDataPoint(
            timestamp: timestamp,
            leftValue: values['left']!.isEmpty
                ? 0.0
                : values['left']!.reduce((a, b) => a + b) / values['left']!.length,
            rightValue: values['right']!.isEmpty
                ? 0.0
                : values['right']!.reduce((a, b) => a + b) / values['right']!.length,
          ));
        }
        break;

      case 'Semaine':
        // 7 jours de la semaine (Lun-Dim)
        final weekday = now.weekday;
        final monday = now.subtract(Duration(days: weekday - 1));
        for (int day = 0; day < 7; day++) {
          final timestamp = DateTime(monday.year, monday.month, monday.day + day);
          final values = grouped[timestamp] ?? {'left': [], 'right': []};
          points.add(ChartDataPoint(
            timestamp: timestamp,
            leftValue: values['left']!.isEmpty
                ? 0.0
                : values['left']!.reduce((a, b) => a + b) / values['left']!.length,
            rightValue: values['right']!.isEmpty
                ? 0.0
                : values['right']!.reduce((a, b) => a + b) / values['right']!.length,
          ));
        }
        break;

      case 'Mois':
        // 12 derniers mois
        for (int i = 11; i >= 0; i--) {
          final monthDate = DateTime(now.year, now.month - i, 1);
          final values = grouped[monthDate] ?? {'left': [], 'right': []};
          points.add(ChartDataPoint(
            timestamp: monthDate,
            leftValue: values['left']!.isEmpty
                ? 0.0
                : values['left']!.reduce((a, b) => a + b) / values['left']!.length,
            rightValue: values['right']!.isEmpty
                ? 0.0
                : values['right']!.reduce((a, b) => a + b) / values['right']!.length,
          ));
        }
        break;

      default:
        // Fallback au comportement par défaut
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
    }

    return points;
  }

  /// Agrégation pour les données de mouvement
  List<ChartDataPoint> _aggregateMovementData(
    List<Map<String, dynamic>> leftData,
    List<Map<String, dynamic>> rightData,
    String period,
    String fieldName,
  ) {
    final Map<DateTime, Map<String, List<double>>> grouped = {};

    // Grouper les données gauche
    for (final data in leftData) {
      final timestamp = DateTime.parse(data['timestamp'] as String);
      final groupedDate = _groupDateByPeriod(timestamp, period);
      grouped.putIfAbsent(groupedDate, () => {'left': [], 'right': []});

      final value = data[fieldName];
      if (value != null) {
        final doubleValue = (value is int) ? value.toDouble() : (value as double);
        grouped[groupedDate]!['left']!.add(doubleValue);
      }
    }

    // Grouper les données droite
    for (final data in rightData) {
      final timestamp = DateTime.parse(data['timestamp'] as String);
      final groupedDate = _groupDateByPeriod(timestamp, period);
      grouped.putIfAbsent(groupedDate, () => {'left': [], 'right': []});

      final value = data[fieldName];
      if (value != null) {
        final doubleValue = (value is int) ? value.toDouble() : (value as double);
        grouped[groupedDate]!['right']!.add(doubleValue);
      }
    }

    // Créer les points de données
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



  DateTime _groupDateByPeriod(DateTime date, String period) {
    switch (period) {
      case 'Jour':
        return DateTime(date.year, date.month, date.day, date.hour);
      case 'Semaine':
        // Grouper par jour pour la vue semaine
        return DateTime(date.year, date.month, date.day);
      case 'Mois':
        // Grouper par mois pour la vue année (12 mois)
        return DateTime(date.year, date.month, 1);
      default:
        return DateTime(date.year, date.month, date.day);
    }
  }

  // ========== ADAPTATEURS POUR ASYMÉTRIE ==========

  /// Adaptateur pour ASYMÉTRIE DES PAS
  /// Calcul du ratio membre atteint/total en pourcentage
  Future<List<AsymmetryDataPoint>> getStepsAsymmetry(
    String period,
    DateTime? selectedDate, {
    ArmSide affectedSide = ArmSide.left,
  }) async {
    final start = _getStartDate(period, selectedDate);
    final end = _getEndDate(period, selectedDate);

    final leftData = await _db.getDeviceInfo(
      'left',
      'steps',
      startDate: start,
      endDate: end,
      limit: 1000,
    );

    final rightData = await _db.getDeviceInfo(
      'right',
      'steps',
      startDate: start,
      endDate: end,
      limit: 1000,
    );

    return _aggregateAsymmetryData(
      leftData,
      rightData,
      period,
      (data) => data.value.toDouble(),
      affectedSide,
    );
  }

  /// Adaptateur pour ASYMÉTRIE MAGNITUDE ACTIVE TIME
  /// Calcul du ratio membre atteint/total pour le temps actif basé sur magnitude
  Future<List<AsymmetryDataPoint>> getMagnitudeAsymmetry(
    String period,
    DateTime? selectedDate, {
        ArmSide affectedSide = ArmSide.left,
  }) async {
    final start = _getStartDate(period, selectedDate);
    final end = _getEndDate(period, selectedDate);

    final leftData = await _db.getMovementData(
      'left',
      startDate: start,
      endDate: end,
      limit: 1000,
    );

    final rightData = await _db.getMovementData(
      'right',
      startDate: start,
      endDate: end,
      limit: 1000,
    );

    final asymmetryData = _aggregateAsymmetryDataFromMovement(
      leftData,
      rightData,
      period,
      'magnitudeActiveTime',
      affectedSide,
    );

    // Normaliser pour avoir des abscisses fixes
    return _normalizeAsymmetryDataPoints(asymmetryData, period, selectedDate);
  }

  /// Adaptateur pour ASYMÉTRIE AXIS ACTIVE TIME
  /// Calcul du ratio membre atteint/total pour le temps actif basé sur axes
  Future<List<AsymmetryDataPoint>> getAxisAsymmetry(
    String period,
    DateTime? selectedDate, {
        ArmSide affectedSide = ArmSide.left,
  }) async {
    final start = _getStartDate(period, selectedDate);
    final end = _getEndDate(period, selectedDate);

    final leftData = await _db.getMovementData(
      'left',
      startDate: start,
      endDate: end,
      limit: 1000,
    );

    final rightData = await _db.getMovementData(
      'right',
      startDate: start,
      endDate: end,
      limit: 1000,
    );

    final asymmetryData = _aggregateAsymmetryDataFromMovement(
      leftData,
      rightData,
      period,
      'axisActiveTime',
      affectedSide,
    );

    // Normaliser pour avoir des abscisses fixes
    return _normalizeAsymmetryDataPoints(asymmetryData, period, selectedDate);
  }

  /// Adaptateur pour visualiser les VALEURS GAUCHE/DROITE du mouvement
  /// Retourne les données formatées pour ReusableComparisonChart
  /// leftValue = temps actif bras gauche (en minutes)
  /// rightValue = temps actif bras droit (en minutes)
  Future<List<ChartDataPoint>> getAsymmetryRatioData(
    String period,
    DateTime? selectedDate, {
    ArmSide affectedSide = ArmSide.left,
  }) async {
    // Récupérer les données d'asymétrie
    final asymmetryData = await getMagnitudeAsymmetry(
      period,
      selectedDate,
      affectedSide: affectedSide,
    );

    // Convertir en ChartDataPoint avec les valeurs réelles gauche/droite
    final chartData = asymmetryData.map((point) {
      return ChartDataPoint(
        timestamp: point.timestamp,
        leftValue: point.leftValue,   // Valeur bras gauche
        rightValue: point.rightValue,  // Valeur bras droit
      );
    }).toList();

    // Normaliser pour avoir des abscisses fixes
    return _normalizeDataPoints(chartData, period, selectedDate);
  }

  /// Méthode générique d'agrégation pour l'asymétrie
  ///
  /// Formule asymétrie : (membre atteint / (gauche + droite)) × 100
  /// - 50% = équilibré
  List<AsymmetryDataPoint> _aggregateAsymmetryData<T>(
    List<T> leftData,
    List<T> rightData,
    String period,
    double Function(T) valueExtractor,
    ArmSide affectedSide,
  ) {
    final Map<DateTime, Map<String, List<double>>> grouped = {};

    // Grouper gauche
    for (final data in leftData) {
      final timestamp = (data as dynamic).timestamp as DateTime;
      final groupedDate = _groupDateByPeriod(timestamp, period);
      grouped.putIfAbsent(groupedDate, () => {'left': [], 'right': []});
      grouped[groupedDate]!['left']!.add(valueExtractor(data));
    }

    // Grouper droite
    for (final data in rightData) {
      final timestamp = (data as dynamic).timestamp as DateTime;
      final groupedDate = _groupDateByPeriod(timestamp, period);
      grouped.putIfAbsent(groupedDate, () => {'left': [], 'right': []});
      grouped[groupedDate]!['right']!.add(valueExtractor(data));
    }

    // Convertir en AsymmetryDataPoint
    final points = <AsymmetryDataPoint>[];
    final sortedKeys = grouped.keys.toList()..sort();

    for (final date in sortedKeys) {
      final values = grouped[date]!;

      // Calculer les moyennes
      final leftAvg = values['left']!.isEmpty
          ? 0.0
          : values['left']!.reduce((a, b) => a + b) / values['left']!.length;
      final rightAvg = values['right']!.isEmpty
          ? 0.0
          : values['right']!.reduce((a, b) => a + b) / values['right']!.length;

      // Calculer l'asymétrie (ratio membre atteint / total)
      // 50% = équilibré
      final total = leftAvg + rightAvg;
      final affectedAvg = affectedSide == ArmSide.left ? leftAvg : rightAvg;
      final asymmetryRatio = total > 0 ? (affectedAvg / total) * 100 : 50.0;

      // Catégoriser l'asymétrie
      final category = _categorizeAsymmetry(asymmetryRatio);

      points.add(AsymmetryDataPoint(
        timestamp: date,
        leftValue: leftAvg,
        rightValue: rightAvg,
        asymmetryRatio: asymmetryRatio,
        asymmetryCategory: category,
      ));
    }

    return points;
  }

  /// Catégorise l'asymétrie selon le ratio
  /// Note: ratio = (droite / total) × 100
  /// 0% = tout à gauche, 50% = équilibré, 100% = tout à droite
  AsymmetryCategory _categorizeAsymmetry(double ratio) {
    if (ratio >= 45 && ratio <= 55) {
      return AsymmetryCategory.balanced;
    } else if (ratio > 55 && ratio <= 65) {
      return AsymmetryCategory.rightModerate;
    } else if (ratio > 65) {
      return AsymmetryCategory.rightStrong;
    } else if (ratio < 45 && ratio >= 35) {
      return AsymmetryCategory.leftModerate;
    } else {
      return AsymmetryCategory.leftStrong;
    }
  }

  /// Méthode d'agrégation pour les données de movement_data
  ///
  /// Cette méthode traite les données brutes de movement_data
  /// Calcul: (membre atteint / total) × 100
  List<AsymmetryDataPoint> _aggregateAsymmetryDataFromMovement(
    List<Map<String, dynamic>> leftData,
    List<Map<String, dynamic>> rightData,
    String period,
    String fieldName, // 'magnitudeActiveTime' ou 'axisActiveTime'
      ArmSide affectedSide, // 'left' ou 'right'
  ) {
    final Map<DateTime, Map<String, List<double>>> grouped = {};

    // Grouper gauche
    for (final data in leftData) {
      final timestamp = DateTime.parse(data['timestamp'] as String);
      final groupedDate = _groupDateByPeriod(timestamp, period);
      grouped.putIfAbsent(groupedDate, () => {'left': [], 'right': []});

      // Récupérer la valeur du champ (peut être null)
      final value = data[fieldName];
      if (value != null) {
        final doubleValue = (value is int) ? value.toDouble() : (value as double);
        grouped[groupedDate]!['left']!.add(doubleValue / 60.0); // Convertir secondes en minutes
      }
    }

    // Grouper droite
    for (final data in rightData) {
      final timestamp = DateTime.parse(data['timestamp'] as String);
      final groupedDate = _groupDateByPeriod(timestamp, period);
      grouped.putIfAbsent(groupedDate, () => {'left': [], 'right': []});

      final value = data[fieldName];
      if (value != null) {
        final doubleValue = (value is int) ? value.toDouble() : (value as double);
        grouped[groupedDate]!['right']!.add(doubleValue / 60.0);
      }
    }

    // Convertir en AsymmetryDataPoint
    final points = <AsymmetryDataPoint>[];
    final sortedKeys = grouped.keys.toList()..sort();

    for (final date in sortedKeys) {
      final values = grouped[date]!;

      // Calculer les moyennes
      final leftAvg = values['left']!.isEmpty
          ? 0.0
          : values['left']!.reduce((a, b) => a + b) / values['left']!.length;
      final rightAvg = values['right']!.isEmpty
          ? 0.0
          : values['right']!.reduce((a, b) => a + b) / values['right']!.length;

      // Calculer l'asymétrie (ratio membre atteint / total)
      // 50% = équilibré
      final total = leftAvg + rightAvg;
      final affectedAvg = affectedSide == ArmSide.left ? leftAvg : rightAvg;
      final asymmetryRatio = total > 0 ? (affectedAvg / total) * 100 : 50.0;

      // Catégoriser l'asymétrie
      final category = _categorizeAsymmetry(asymmetryRatio);

      points.add(AsymmetryDataPoint(
        timestamp: date,
        leftValue: leftAvg,
        rightValue: rightAvg,
        asymmetryRatio: asymmetryRatio,
        asymmetryCategory: category,
      ));
    }

    return points;
  }

  /// Normalise les données en ajoutant les points manquants avec valeurs nulles
  /// pour avoir des abscisses fixes (toujours 24h, 7j ou 30-31j)
  List<ChartDataPoint> _normalizeDataPoints(
    List<ChartDataPoint> data,
    String period,
    DateTime? selectedDate,
  ) {
    if (data.isEmpty) return data;

    final start = _getStartDate(period, selectedDate);
    final end = _getEndDate(period, selectedDate);

    // Créer un map avec timestamp => data pour un accès rapide
    final dataMap = <DateTime, ChartDataPoint>{};
    for (final point in data) {
      dataMap[point.timestamp] = point;
    }

    // Générer tous les points attendus selon la période
    final normalizedPoints = <ChartDataPoint>[];
    DateTime current = start;

    switch (period) {
      case 'Jour':
        // 24 points (1 par heure)
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
        // 7 points (1 par jour)
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
        // 12 points (1 par mois de l'année)
        while (current.isBefore(end)) {
          final existing = dataMap[current];
          normalizedPoints.add(ChartDataPoint(
            timestamp: current,
            leftValue: existing?.leftValue,
            rightValue: existing?.rightValue,
          ));
          // Passer au mois suivant
          current = DateTime(current.year, current.month + 1, 1);
        }
        break;

      default:
        return data;
    }

    return normalizedPoints;
  }

  /// Normalise les données d'asymétrie en ajoutant les points manquants
  /// pour avoir des abscisses fixes (toujours 24h, 7j ou 12 mois)
  List<AsymmetryDataPoint> _normalizeAsymmetryDataPoints(
    List<AsymmetryDataPoint> data,
    String period,
    DateTime? selectedDate,
  ) {
    if (data.isEmpty) return data;

    final start = _getStartDate(period, selectedDate);
    final end = _getEndDate(period, selectedDate);

    // Créer un map avec timestamp => data pour un accès rapide
    final dataMap = <DateTime, AsymmetryDataPoint>{};
    for (final point in data) {
      dataMap[point.timestamp] = point;
    }

    // Générer tous les points attendus selon la période
    final normalizedPoints = <AsymmetryDataPoint>[];
    DateTime current = start;

    switch (period) {
      case 'Jour':
        // 24 points (1 par heure : 0h, 1h, 2h, ..., 23h)
        while (current.isBefore(end)) {
          final existing = dataMap[current];
          normalizedPoints.add(AsymmetryDataPoint(
            timestamp: current,
            leftValue: existing?.leftValue ?? 0.0,
            rightValue: existing?.rightValue ?? 0.0,
            asymmetryRatio: existing?.asymmetryRatio ?? 50.0, // 50% = équilibré par défaut
            asymmetryCategory: existing?.asymmetryCategory ?? AsymmetryCategory.balanced,
          ));
          current = current.add(const Duration(hours: 1));
        }
        break;

      case 'Semaine':
        // 7 points (Lun, Mar, Mer, Jeu, Ven, Sam, Dim)
        while (current.isBefore(end)) {
          final existing = dataMap[current];
          normalizedPoints.add(AsymmetryDataPoint(
            timestamp: current,
            leftValue: existing?.leftValue ?? 0.0,
            rightValue: existing?.rightValue ?? 0.0,
            asymmetryRatio: existing?.asymmetryRatio ?? 50.0, // 50% = équilibré par défaut
            asymmetryCategory: existing?.asymmetryCategory ?? AsymmetryCategory.balanced,
          ));
          current = current.add(const Duration(days: 1));
        }
        break;

      case 'Mois':
        // 12 points (1 par mois de l'année : Jan, Fév, Mar, ..., Déc)
        while (current.isBefore(end)) {
          final existing = dataMap[current];
          normalizedPoints.add(AsymmetryDataPoint(
            timestamp: current,
            leftValue: existing?.leftValue ?? 0.0,
            rightValue: existing?.rightValue ?? 0.0,
            asymmetryRatio: existing?.asymmetryRatio ?? 50.0, // 50% = équilibré par défaut
            asymmetryCategory: existing?.asymmetryCategory ?? AsymmetryCategory.balanced,
          ));
          // Passer au mois suivant
          current = DateTime(current.year, current.month + 1, 1);
        }
        break;

      default:
        return data;
    }

    return normalizedPoints;
  }
}

/// Classe pour représenter un point de données d'asymétrie
class AsymmetryDataPoint {
  final DateTime timestamp;
  final double leftValue;
  final double rightValue;
  final double asymmetryRatio; // Pourcentage gauche (0-100%)
  final AsymmetryCategory asymmetryCategory;

  AsymmetryDataPoint({
    required this.timestamp,
    required this.leftValue,
    required this.rightValue,
    required this.asymmetryRatio,
    required this.asymmetryCategory,
  });

  /// Obtenir le score d'asymétrie (-50 à +50)
  /// Négatif = dominance gauche, Positif = dominance droite
  double get asymmetryScore => asymmetryRatio - 50.0;
}

/// Catégories d'asymétrie
enum AsymmetryCategory {
  balanced, // Équilibré (45-55%)
  leftModerate, // Dominance gauche modérée (55-65%)
  leftStrong, // Dominance gauche forte (>65%)
  rightModerate, // Dominance droite modérée (35-45%)
  rightStrong, // Dominance droite forte (<35%)
}

extension AsymmetryCategoryExtension on AsymmetryCategory {
  String get label {
    switch (this) {
      case AsymmetryCategory.balanced:
        return 'Équilibré';
      case AsymmetryCategory.leftModerate:
        return 'Dominance gauche modérée';
      case AsymmetryCategory.leftStrong:
        return 'Dominance gauche forte';
      case AsymmetryCategory.rightModerate:
        return 'Dominance droite modérée';
      case AsymmetryCategory.rightStrong:
        return 'Dominance droite forte';
    }
  }

  Color get color {
    switch (this) {
      case AsymmetryCategory.balanced:
        return Colors.green;
      case AsymmetryCategory.leftModerate:
      case AsymmetryCategory.rightModerate:
        return Colors.orange;
      case AsymmetryCategory.leftStrong:
      case AsymmetryCategory.rightStrong:
        return Colors.red;
    }
  }
}
