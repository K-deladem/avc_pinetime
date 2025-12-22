// service/data_simulator.dart
//
//  SIMULATEUR DE DONNÉES - À RETIRER EN PRODUCTION
//
// Ce fichier génère de fausses données pour tester les graphiques.
// Pour retirer le simulateur, supprimez simplement ce fichier et
// retirez les appels à DataSimulator dans votre code.

import 'dart:math';
import 'package:flutter_bloc_app_template/app/app_database.dart';

class DataSimulator {
  final AppDatabase _db = AppDatabase.instance;
  final Random _random = Random();

  /// Génère des données de test pour une période donnée
  Future<void> generateTestData({
    DateTime? startDate,
    DateTime? endDate,
    int dataPointsPerDay = 24,
  }) async {
    final start = startDate ?? DateTime.now().subtract(const Duration(days: 30));
    final end = endDate ?? DateTime.now();

    print('📊 SIMULATEUR: Génération de données de test...');
    print('   Période: ${start.toString().split('.')[0]} -> ${end.toString().split('.')[0]}');

    // Générer les données pour chaque jour
    DateTime current = start;
    int totalPoints = 0;

    while (current.isBefore(end)) {
      await _generateDayData(current, dataPointsPerDay);
      totalPoints += dataPointsPerDay * 2; // 2 bras
      current = current.add(const Duration(days: 1));
    }

    print(' SIMULATEUR: $totalPoints points de données générés avec succès!');
  }

  /// Génère les données pour un jour spécifique
  Future<void> _generateDayData(DateTime date, int pointsPerDay) async {
    for (int i = 0; i < pointsPerDay; i++) {
      final timestamp = date.add(Duration(hours: i));

      // Générer les données pour le bras gauche
      await _insertDeviceInfoData('left', timestamp);
      await _insertMovementData('left', timestamp);

      // Générer les données pour le bras droit
      await _insertDeviceInfoData('right', timestamp);
      await _insertMovementData('right', timestamp);
    }
  }

  /// Insère des données device_info (batterie, pas, etc.)
  Future<void> _insertDeviceInfoData(String armSide, DateTime timestamp) async {
    final db = await _db.database;
    final now = DateTime.now();

    // Générer batterie (diminue progressivement)
    final hourOfDay = timestamp.hour;
    final batteryBase = 100 - (hourOfDay * 3); // Diminue de ~3% par heure
    final battery = (batteryBase + _random.nextInt(10) - 5).clamp(10, 100);

    await db.insert('device_info_data', {
      'id': '${armSide}_battery_${timestamp.millisecondsSinceEpoch}',
      'infoType': 'battery',
      'armSide': armSide,
      'value': battery.toDouble(),
      'timestamp': timestamp.toIso8601String(),
      'createdAt': now.toIso8601String(),
    });

    // Générer nombre de pas (augmente pendant la journée)
    final stepsBase = hourOfDay * 400; // ~400 pas par heure
    final steps = stepsBase + _random.nextInt(200);

    await db.insert('device_info_data', {
      'id': '${armSide}_steps_${timestamp.millisecondsSinceEpoch}',
      'infoType': 'steps',
      'armSide': armSide,
      'value': steps.toDouble(),
      'timestamp': timestamp.toIso8601String(),
      'createdAt': now.toIso8601String(),
    });

    // Générer fréquence cardiaque (varie selon l'heure)
    final isActiveTime = hourOfDay >= 8 && hourOfDay <= 20;
    final hrBase = isActiveTime ? 75 : 65;
    final heartRate = hrBase + _random.nextInt(30) - 15;

    await db.insert('device_info_data', {
      'id': '${armSide}_heartRate_${timestamp.millisecondsSinceEpoch}',
      'infoType': 'heartRate',
      'armSide': armSide,
      'value': heartRate.toDouble(),
      'timestamp': timestamp.toIso8601String(),
      'createdAt': now.toIso8601String(),
    });
  }

  /// Insère des données de mouvement
  Future<void> _insertMovementData(String armSide, DateTime timestamp) async {
    final db = await _db.database;
    final now = DateTime.now();

    // Créer une asymétrie subtile entre les bras
    final asymmetryFactor = armSide == 'left' ? 1.1 : 0.9;

    // Générer magnitude (activité générale)
    final isActiveTime = timestamp.hour >= 8 && timestamp.hour <= 20;
    final magnitudeBase = isActiveTime ? 150.0 : 50.0;
    final magnitude = (magnitudeBase * asymmetryFactor) + _random.nextDouble() * 50;

    // Générer temps actif basé sur magnitude (en secondes)
    final magnitudeActiveTime = isActiveTime
        ? (1800 + _random.nextInt(1800)) * asymmetryFactor  // 30-60 min
        : (_random.nextInt(600)) * asymmetryFactor;          // 0-10 min

    // Générer temps actif basé sur axes
    final axisActiveTime = magnitudeActiveTime * 0.8; // ~80% du temps magnitude

    // Calculer le niveau d'activité (0-4)
    final activityLevel = isActiveTime
        ? (2 + _random.nextInt(2)) // 2-3 pendant journée
        : _random.nextInt(2);        // 0-1 pendant nuit

    // Valeurs des axes X, Y, Z
    final x = (_random.nextDouble() - 0.5) * 2000 * asymmetryFactor;
    final y = (_random.nextDouble() - 0.5) * 2000 * asymmetryFactor;
    final z = (_random.nextDouble() - 0.5) * 2000 * asymmetryFactor;

    // Catégorie d'activité
    final activityCategory = activityLevel <= 1 ? 'sedentary' :
                             activityLevel == 2 ? 'light' :
                             activityLevel == 3 ? 'moderate' : 'vigorous';

    await db.insert('movement_data', {
      'id': '${armSide}_movement_${timestamp.millisecondsSinceEpoch}',
      'armSide': armSide,
      'accelX': x,
      'accelY': y,
      'accelZ': z,
      'magnitude': magnitude,
      'activityLevel': activityLevel,
      'activityCategory': activityCategory,
      'movementType': isActiveTime ? 'walking' : 'resting',
      'stability': 0.5 + (_random.nextDouble() * 0.5), // 0.5-1.0
      'energy': magnitude * 0.7,
      'axisVariance': _random.nextDouble() * 100,
      'axisDominance': _random.nextDouble(),
      'dominantAxis': ['x', 'y', 'z'][_random.nextInt(3)],
      'intensityDescription': activityCategory,
      'magnitudeActiveTime': magnitudeActiveTime.toInt(),
      'axisActiveTime': axisActiveTime.toInt(),
      'movementDetected': isActiveTime ? 1 : 0,
      'anyMovement': magnitude > 50 ? 1 : 0,
      'timestamp': timestamp.toIso8601String(),
      'timestampMs': timestamp.millisecondsSinceEpoch,
      'rssi': -50 - _random.nextInt(40), // -50 à -90 dBm
      'createdAt': now.toIso8601String(),
    });
  }

  /// Nettoie toutes les données de test
  Future<void> clearAllData() async {
    final db = await _db.database;

    print('🗑️  SIMULATEUR: Suppression de toutes les données...');

    await db.delete('device_info_data');
    await db.delete('movement_data');

    print(' SIMULATEUR: Toutes les données ont été supprimées');
  }

  /// Génère des données avec un pattern d'asymétrie spécifique
  Future<void> generateAsymmetryPattern({
    DateTime? startDate,
    DateTime? endDate,
    double leftDominance = 0.6, // 0.5 = équilibré, >0.5 = gauche dominant
  }) async {
    final start = startDate ?? DateTime.now().subtract(const Duration(days: 7));
    final end = endDate ?? DateTime.now();

    print('📊 SIMULATEUR: Génération avec asymétrie...');
    print('   Dominance gauche: ${(leftDominance * 100).toStringAsFixed(0)}%');

    DateTime current = start;

    while (current.isBefore(end)) {
      for (int hour = 0; hour < 24; hour++) {
        final timestamp = DateTime(
          current.year,
          current.month,
          current.day,
          hour,
        );

        // Facteurs d'asymétrie
        final leftFactor = leftDominance * 2;
        final rightFactor = (1 - leftDominance) * 2;

        await _insertAsymmetricData('left', timestamp, leftFactor);
        await _insertAsymmetricData('right', timestamp, rightFactor);
      }

      current = current.add(const Duration(days: 1));
    }

    print(' SIMULATEUR: Données asymétriques générées!');
  }

  Future<void> _insertAsymmetricData(
    String armSide,
    DateTime timestamp,
    double factor,
  ) async {
    final db = await _db.database;
    final now = DateTime.now();

    // Steps avec asymétrie
    final steps = (5000 * factor + _random.nextInt(1000)).toInt();
    await db.insert('device_info_data', {
      'id': '${armSide}_steps_asym_${timestamp.millisecondsSinceEpoch}',
      'infoType': 'steps',
      'armSide': armSide,
      'value': steps.toDouble(),
      'timestamp': timestamp.toIso8601String(),
      'createdAt': now.toIso8601String(),
    });

    // Movement data avec asymétrie
    final magnitude = 100.0 * factor + _random.nextDouble() * 20;
    final activeTime = (3600 * factor + _random.nextInt(600)).toInt();
    final activityLevel = (3 * factor).clamp(0, 4).toInt();

    final activityCategory = activityLevel <= 1 ? 'sedentary' :
                             activityLevel == 2 ? 'light' :
                             activityLevel == 3 ? 'moderate' : 'vigorous';

    await db.insert('movement_data', {
      'id': '${armSide}_movement_asym_${timestamp.millisecondsSinceEpoch}',
      'armSide': armSide,
      'accelX': (_random.nextDouble() - 0.5) * 1000 * factor,
      'accelY': (_random.nextDouble() - 0.5) * 1000 * factor,
      'accelZ': (_random.nextDouble() - 0.5) * 1000 * factor,
      'magnitude': magnitude,
      'activityLevel': activityLevel,
      'activityCategory': activityCategory,
      'movementType': 'walking',
      'stability': 0.5 + (_random.nextDouble() * 0.5),
      'energy': magnitude * 0.7,
      'axisVariance': _random.nextDouble() * 100,
      'axisDominance': _random.nextDouble(),
      'dominantAxis': ['x', 'y', 'z'][_random.nextInt(3)],
      'intensityDescription': activityCategory,
      'magnitudeActiveTime': activeTime,
      'axisActiveTime': (activeTime * 0.8).toInt(),
      'movementDetected': 1,
      'anyMovement': magnitude > 50 ? 1 : 0,
      'timestamp': timestamp.toIso8601String(),
      'timestampMs': timestamp.millisecondsSinceEpoch,
      'rssi': -50 - _random.nextInt(40),
      'createdAt': now.toIso8601String(),
    });
  }

  /// Affiche les statistiques des données actuelles
  Future<void> showDataStats() async {
    final db = await _db.database;

    final deviceInfoCount = await db.query(
      'device_info_data',
      columns: ['COUNT(*) as count'],
    );

    final movementCount = await db.query(
      'movement_data',
      columns: ['COUNT(*) as count'],
    );

    final leftCount = await db.query(
      'device_info_data',
      where: 'armSide = ?',
      whereArgs: ['left'],
      columns: ['COUNT(*) as count'],
    );

    final rightCount = await db.query(
      'device_info_data',
      where: 'armSide = ?',
      whereArgs: ['right'],
      columns: ['COUNT(*) as count'],
    );

    print('\n📊 STATISTIQUES DES DONNÉES:');
    print('   Device Info: ${deviceInfoCount.first['count']}');
    print('   Movement Data: ${movementCount.first['count']}');
    print('   Bras Gauche: ${leftCount.first['count']}');
    print('   Bras Droit: ${rightCount.first['count']}');
    print('');
  }
}
