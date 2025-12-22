import 'package:flutter_bloc_app_template/app/lang_helper.dart';
import 'package:flutter_bloc_app_template/app/theme_helper.dart';
import 'package:flutter_bloc_app_template/extension/notification_strategy.dart';
import 'package:flutter_bloc_app_template/extension/vibration_arm.dart';
import 'package:flutter_bloc_app_template/extension/vibration_mode.dart';
import 'package:flutter_bloc_app_template/models/app_settings.dart';
import 'package:flutter_bloc_app_template/models/arm_side.dart';
import 'package:flutter_bloc_app_template/models/connection_event.dart';
import 'package:flutter_bloc_app_template/models/watch_device.dart';
import 'package:infinitime_dfu_library/infinitime_dfu_library.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/device_info_data.dart';

class AppDatabase {
  // Singleton instance
  static final AppDatabase instance = AppDatabase._init();

  static Database? _database;
  static const String _databaseName = 'watch_database.db';

  AppDatabase._init();

  /// Accès à la base de données
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  /// Vérifie si la base de données est ouverte
  bool get isOpen => _database?.isOpen ?? false;

  /// Initialisation de la base de données
  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      onOpen: _onOpenDB,
    );
  }

  /// Callback lors de l'ouverture de la DB
  Future<void> _onOpenDB(Database db) async {
    await db.execute('PRAGMA synchronous = NORMAL');
    await db.execute('PRAGMA cache_size = -4000');
    await db.execute('PRAGMA foreign_keys = ON');

    // Migrer les anciennes données avec "gauche"/"droite" vers "left"/"right"
    await _migrateArmSideValues(db);

    // Ajouter le champ isFirstLaunch si nécessaire
    await _addIsFirstLaunchColumn(db);

    // Ajouter les champs de préférences de graphiques si nécessaire
    await _addChartPreferencesColumns(db);
  }

  /// Ajoute le champ isFirstLaunch à la table settings si il n'existe pas
  Future<void> _addIsFirstLaunchColumn(Database db) async {
    try {
      // Vérifier si la colonne existe déjà
      final result = await db.rawQuery('PRAGMA table_info(settings)');
      final hasIsFirstLaunch =
          result.any((column) => column['name'] == 'isFirstLaunch');

      if (!hasIsFirstLaunch) {
        await db.execute('''
          ALTER TABLE settings ADD COLUMN isFirstLaunch INTEGER DEFAULT 1
        ''');
        print('Column isFirstLaunch added to settings table');
      }
    } catch (e) {
      print('⚠️ Failed to add isFirstLaunch column (might already exist): $e');
    }
  }

  /// Ajoute les champs de préférences de graphiques à la table settings si ils n'existent pas
  Future<void> _addChartPreferencesColumns(Database db) async {
    try {
      final result = await db.rawQuery('PRAGMA table_info(settings)');
      final columns = result.map((column) => column['name'] as String).toList();

      final chartColumns = [
        'showAsymmetryGauge',
        'showBatteryComparison',
        'showAsymmetryHeatmap',
        'showStepsComparison',
      ];

      for (final columnName in chartColumns) {
        if (!columns.contains(columnName)) {
          await db.execute('''
            ALTER TABLE settings ADD COLUMN $columnName INTEGER DEFAULT 1
          ''');
          print('Column $columnName added to settings table');
        }
      }
    } catch (e) {
      print('⚠️ Failed to add chart preferences columns: $e');
    }
  }

  /// Migre les anciennes valeurs d'armSide de "gauche"/"droite" vers "left"/"right"
  Future<void> _migrateArmSideValues(Database db) async {
    try {
      // Migrer connection_events
      await db.execute('''
        UPDATE connection_events
        SET armSide = 'left'
        WHERE armSide = 'gauche' OR armSide LIKE '%gauche%'
      ''');

      await db.execute('''
        UPDATE connection_events
        SET armSide = 'right'
        WHERE armSide = 'droite' OR armSide LIKE '%droite%' OR armSide LIKE '%droit%'
      ''');

      // Migrer device_info_data si nécessaire
      await db.execute('''
        UPDATE device_info_data
        SET armSide = 'left'
        WHERE armSide = 'gauche' OR armSide LIKE '%gauche%'
      ''');

      await db.execute('''
        UPDATE device_info_data
        SET armSide = 'right'
        WHERE armSide = 'droite' OR armSide LIKE '%droite%' OR armSide LIKE '%droit%'
      ''');

      // Migrer movement_data
      await db.execute('''
        UPDATE movement_data
        SET armSide = 'left'
        WHERE armSide = 'gauche' OR armSide LIKE '%gauche%'
      ''');

      await db.execute('''
        UPDATE movement_data
        SET armSide = 'right'
        WHERE armSide = 'droite' OR armSide LIKE '%droite%' OR armSide LIKE '%droit%'
      ''');

      print('Migration armSide values completed successfully');
    } catch (e) {
      print('Migration armSide failed (might be already migrated): $e');
    }
  }

  /// Recharger la base de données
  Future<void> reloadDatabase() async {
    await close();
    _database = null;
    _database = await _initDB();
  }

  /// Supprime complètement la base de données
  Future<void> deleteAppDatabase() async {
    final db = await database;
    await db.close();
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);
    await deleteDatabase(path);
    _database = null;
  }

  /// Ferme proprement la base de données
  Future<void> close() async {
    final db = await _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }

  /// Crée la base de données et les tables nécessaires
  Future _createDB(Database db, int version) async {
    // Table watch_devices
    await db.execute('''
      CREATE TABLE watch_devices (
        id TEXT PRIMARY KEY,
        name TEXT,
        manufacturer TEXT,
        model TEXT,
        firmwareVersion TEXT,
        hardwareVersion TEXT,
        armSide TEXT,
        batteryLevel TEXT,
        isLastConnected INTEGER,
        lastConnectionTime TEXT,
        lastSyncTime TEXT
      )
    ''');

    // Table device_info_data (remplace battery_data, step_data, etc.)
    await db.execute('''
      CREATE TABLE device_info_data (
        id TEXT PRIMARY KEY,
        infoType TEXT NOT NULL,
        armSide TEXT NOT NULL,
        value REAL NOT NULL,
        timestamp TEXT NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_device_info_timestamp
      ON device_info_data(timestamp DESC)
    ''');

    await db.execute('''
      CREATE INDEX idx_device_info_arm_type_timestamp
      ON device_info_data(armSide, infoType, timestamp DESC)
    ''');

    // Table movement_data - COMPLÈTE (gardée au cas où)
    await db.execute('''
    CREATE TABLE movement_data (
      id TEXT PRIMARY KEY,
      armSide TEXT NOT NULL,
      accelX REAL NOT NULL,
      accelY REAL NOT NULL,
      accelZ REAL NOT NULL,
      magnitude REAL NOT NULL,
      activityLevel INTEGER NOT NULL,
      activityCategory TEXT NOT NULL,
      movementType TEXT,
      stability REAL,
      energy REAL,
      axisVariance REAL,
      axisDominance REAL,
      dominantAxis TEXT,
      intensityDescription TEXT,
      magnitudeActiveTime INTEGER,
      axisActiveTime INTEGER,
      movementDetected INTEGER,
      anyMovement INTEGER,
      timestamp TEXT NOT NULL,
      timestampMs INTEGER,
      rssi INTEGER,
      createdAt TEXT NOT NULL
    )
    ''');

    await db.execute('''
      CREATE INDEX idx_movement_timestamp 
      ON movement_data(timestamp DESC)
    ''');

    await db.execute('''
      CREATE INDEX idx_movement_arm_timestamp 
      ON movement_data(armSide, timestamp DESC)
    ''');

    await db.execute('''
      CREATE INDEX idx_movement_type 
      ON movement_data(movementType, armSide)
    ''');

    await db.execute('''
      CREATE INDEX idx_movement_activity 
      ON movement_data(activityLevel, armSide)
    ''');

    // Table settings
    await db.execute('''
      CREATE TABLE settings (
        id INTEGER PRIMARY KEY,
        isFirstLaunch INTEGER DEFAULT 1,
        userName TEXT,
        profileImagePath TEXT,
        collectionFrequency INTEGER,
        dailyObjective INTEGER,
        affectedSide TEXT,
        vibrationMode TEXT,
        vibrationTargetArm TEXT,
        checkFrequencyMin INTEGER,
        notificationStrategy TEXT,
        notificationsEnabled BOOLEAN,
        vibrationOnMs INTEGER,
        vibrationOffMs INTEGER,
        leftWatchName TEXT,
        rightWatchName TEXT,
        vibrationRepeat INTEGER,
        language TEXT,
        themeMode TEXT,
        showAsymmetryGauge INTEGER DEFAULT 1,
        showBatteryComparison INTEGER DEFAULT 1,
        showAsymmetryHeatmap INTEGER DEFAULT 1,
        showStepsComparison INTEGER DEFAULT 1,
        bluetoothScanTimeout INTEGER DEFAULT 15,
        bluetoothConnectionTimeout INTEGER DEFAULT 30,
        bluetoothMaxRetries INTEGER DEFAULT 5,
        dataRecordInterval INTEGER DEFAULT 2,
        movementRecordInterval INTEGER DEFAULT 30
      )
    ''');

    // Table connection_events
    await db.execute('''
      CREATE TABLE connection_events (
        id TEXT PRIMARY KEY,
        armSide TEXT NOT NULL,
        type TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        reason TEXT,
        durationSeconds INTEGER,
        errorMessage TEXT,
        batteryAtConnection INTEGER,
        rssiAtConnection INTEGER,
        createdAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_connection_timestamp 
      ON connection_events(timestamp DESC)
    ''');

    await db.execute('''
      CREATE INDEX idx_connection_arm_timestamp 
      ON connection_events(armSide, timestamp DESC)
    ''');

    await db.execute('''
      CREATE INDEX idx_connection_type 
      ON connection_events(type, armSide)
    ''');
  }

  // ============================================================================
  // WATCH DEVICES
  // ============================================================================

  Future<void> insertWatchDevice(WatchDevice device) async {
    final db = await instance.database;
    await db.insert('watch_devices', device.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<WatchDevice>> getAllWatchDevices() async {
    final db = await instance.database;
    final result = await db.query('watch_devices');
    return result.map((json) => WatchDevice.fromMap(json)).toList();
  }

  Future<WatchDevice?> getWatchDeviceById(String id) async {
    final db = await instance.database;
    final result =
        await db.query('watch_devices', where: 'id = ?', whereArgs: [id]);
    if (result.isNotEmpty) return WatchDevice.fromMap(result.first);
    return null;
  }

  Future<void> updateWatchDevice(WatchDevice device) async {
    final db = await instance.database;
    await db.update('watch_devices', device.toMap(),
        where: 'id = ?', whereArgs: [device.id]);
  }

  Future<WatchDevice?> getDeviceByArmSide(String armSide) async {
    final db = await instance.database;
    final result = await db.query(
      'watch_devices',
      where: 'armSide = ?',
      whereArgs: [armSide],
    );
    if (result.isNotEmpty) {
      return WatchDevice.fromMap(result.first);
    }
    return null;
  }

  Future<void> deleteWatchDevice(String id) async {
    final db = await instance.database;
    await db.delete('watch_devices', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteAllWatchDevices() async {
    final db = await instance.database;
    await db.delete('watch_devices');
  }

  // ============================================================================
  // DEVICE INFO DATA (battery, step, rssi)
  // ============================================================================

  /// Insert une donnée device_info (battery, step, rssi)
  Future<void> insertDeviceInfo({
    required String armSide,
    required String infoType, // 'battery', 'step', 'rssi'
    required double value,
    required DateTime timestamp,
  }) async {
    final db = await database;
    await db.insert(
      'device_info_data',
      {
        'id': '${armSide}_${infoType}_${timestamp.millisecondsSinceEpoch}',
        'infoType': infoType,
        'armSide': armSide,
        'value': value,
        'timestamp': timestamp.toIso8601String(),
        'createdAt': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Insert un batch de device_info
  Future<void> insertBatchDeviceInfo(
      List<Map<String, dynamic>> dataList) async {
    if (dataList.isEmpty) return;

    final db = await database;

    await db.transaction((txn) async {
      final batch = txn.batch();
      final createdAt = DateTime.now().toIso8601String();

      for (final data in dataList) {
        final timestamp = data['timestamp'] as DateTime;
        batch.insert(
          'device_info_data',
          {
            'id':
                '${data['armSide']}_${data['infoType']}_${timestamp.millisecondsSinceEpoch}',
            'infoType': data['infoType'],
            'armSide': data['armSide'],
            'value': data['value'],
            'timestamp': timestamp.toIso8601String(),
            'createdAt': createdAt,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      await batch.commit(noResult: true);
    });
  }

  /// Récupère les device_info par type et armSide
  Future<List<DeviceInfoData>> getDeviceInfo(
    String armSide,
    String infoType, {
    DateTime? startDate,
    DateTime? endDate,
    int limit = 100,
    int offset = 0,
  }) async {
    final db = await database;

    String where = 'armSide = ? AND infoType = ?';
    List<dynamic> whereArgs = [armSide, infoType];

    if (startDate != null) {
      where += ' AND timestamp >= ?';
      whereArgs.add(startDate.toIso8601String());
    }

    if (endDate != null) {
      where += ' AND timestamp <= ?';
      whereArgs.add(endDate.toIso8601String());
    }

    final result = await db.query(
      'device_info_data',
      where: where,
      whereArgs: whereArgs,
      orderBy: 'timestamp DESC',
      limit: limit,
      offset: offset,
    );

    // Convertit chaque ligne SQL → DeviceInfoData
    return result.map((row) => DeviceInfoData.fromMap(row)).toList();
  }

  /// Récupère le dernier enregistrement d'un type spécifique
  Future<DeviceInfoData?> getLatestDeviceInfo(
    String armSide,
    String infoType,
  ) async {
    final db = await database;

    final result = await db.query(
      'device_info_data',
      where: 'armSide = ? AND infoType = ?',
      whereArgs: [armSide, infoType],
      orderBy: 'timestamp DESC',
      limit: 1,
    );

    if (result.isEmpty) return null;

    return DeviceInfoData.fromMap(result.first);
  }

  /// Statistiques pour un type de device_info
  Future<Map<String, dynamic>> calculateDeviceInfoStats(
    String armSide,
    String infoType,
    DateTime date,
  ) async {
    final db = await database;

    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final result = await db.rawQuery('''
      SELECT
        COUNT(*) as count,
        MIN(value) as minValue,
        MAX(value) as maxValue,
        AVG(value) as avgValue,
        SUM(value) as totalValue
      FROM device_info_data
      WHERE armSide = ?
        AND infoType = ?
        AND timestamp >= ?
        AND timestamp < ?
    ''', [
      armSide,
      infoType,
      startOfDay.toIso8601String(),
      endOfDay.toIso8601String(),
    ]);

    final row = result.isNotEmpty ? result.first : {};

    return {
      'armSide': armSide,
      'infoType': infoType,
      'date': startOfDay,
      'minValue': _parseDouble(row['minValue']),
      'maxValue': _parseDouble(row['maxValue']),
      'avgValue': _parseDouble(row['avgValue']),
      'totalValue': _parseDouble(row['totalValue']),
      'recordCount': _parseInt(row['count']),
    };
  }

  /// Supprime toutes les device_info
  Future<void> clearAllDeviceInfo() async {
    final db = await database;
    await db.delete('device_info_data');
  }

  /// Supprime les anciennes device_info
  Future<int> deleteOldDeviceInfo(Duration retentionPeriod) async {
    final db = await database;
    final cutoffDate = DateTime.now().subtract(retentionPeriod);

    return db.delete(
      'device_info_data',
      where: 'timestamp < ?',
      whereArgs: [cutoffDate.toIso8601String()],
    );
  }

  // ============================================================================
  // MOVEMENT DATA - COMPLÈTE (gardée pour préserver les données existantes)
  // ============================================================================

  /// Insert une donnée de mouvement complète
  Future<void> insertMovementData(
    String armSide,
    MovementData movement, {
    int? rssi,
  }) async {
    final db = await database;
    await db.insert(
      'movement_data',
      {
        'id': '${armSide}_${movement.timestampMs}',
        'armSide': armSide,
        'accelX': movement.accelX,
        'accelY': movement.accelY,
        'accelZ': movement.accelZ,
        'magnitude': movement.getAccelerationMagnitude(),
        'activityLevel': movement.getActivityLevel(),
        'activityCategory': movement.getActivityCategory(),
        'movementType': movement.detectMovementType().name,
        'stability': movement.getStability(),
        'energy': movement.getMovementEnergy(),
        'axisVariance': movement.getAxisVariance(),
        'axisDominance': movement.getAxisDominance(),
        'dominantAxis': movement.getDominantAxis(),
        'intensityDescription': movement.getIntensityDescription(),
        'magnitudeActiveTime': movement.magnitudeActiveTime,
        'axisActiveTime': movement.axisActiveTime,
        'movementDetected': movement.movementDetected ? 1 : 0,
        'anyMovement': movement.anyMovement ? 1 : 0,
        'timestamp': DateTime.now().toIso8601String(),
        'timestampMs': movement.timestampMs,
        'rssi': rssi,
        'createdAt': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Insert un batch de données de mouvement complètes
  Future<void> insertBatchMovementData(
    String armSide,
    List<MovementData> movements, {
    int? rssi,
  }) async {
    if (movements.isEmpty) return;

    final db = await database;

    await db.transaction((txn) async {
      final batch = txn.batch();
      final createdAt = DateTime.now().toIso8601String();

      for (final movement in movements) {
        final actualTimestamp = DateTime.fromMillisecondsSinceEpoch(
          movement.timestampMs,
        ).toIso8601String();

        batch.insert(
          'movement_data',
          {
            'id': '${armSide}_${movement.timestampMs}',
            'armSide': armSide,
            'accelX': movement.accelX,
            'accelY': movement.accelY,
            'accelZ': movement.accelZ,
            'magnitude': movement.getAccelerationMagnitude(),
            'activityLevel': movement.getActivityLevel(),
            'activityCategory': movement.getActivityCategory(),
            'movementType': movement.detectMovementType().name,
            'stability': movement.getStability(),
            'energy': movement.getMovementEnergy(),
            'axisVariance': movement.getAxisVariance(),
            'axisDominance': movement.getAxisDominance(),
            'dominantAxis': movement.getDominantAxis(),
            'intensityDescription': movement.getIntensityDescription(),
            'magnitudeActiveTime': movement.magnitudeActiveTime,
            'axisActiveTime': movement.axisActiveTime,
            'movementDetected': movement.movementDetected ? 1 : 0,
            'anyMovement': movement.anyMovement ? 1 : 0,
            'timestamp': actualTimestamp,
            'timestampMs': movement.timestampMs,
            'rssi': rssi,
            'createdAt': createdAt,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      await batch.commit(noResult: true);
    });
  }

  /// Récupère les données de mouvement
  Future<List<Map<String, dynamic>>> getMovementData(
    String armSide, {
    DateTime? startDate,
    DateTime? endDate,
    int limit = 1000,
    int offset = 0,
  }) async {
    final db = await database;

    String where = 'armSide = ?';
    List<dynamic> whereArgs = [armSide];

    if (startDate != null) {
      where += ' AND timestamp >= ?';
      whereArgs.add(startDate.toIso8601String());
    }

    if (endDate != null) {
      where += ' AND timestamp <= ?';
      whereArgs.add(endDate.toIso8601String());
    }

    final result = await db.query(
      'movement_data',
      where: where,
      whereArgs: whereArgs,
      orderBy: 'timestamp DESC',
      limit: limit,
      offset: offset,
    );

    return result;
  }

  /// Comparaison entre les deux bras (focus sur magnitudeActiveTime et axisActiveTime)
  Future<Map<String, dynamic>> compareArmsMovement({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final db = await database;

    String where = '1=1';
    List<dynamic> whereArgs = [];

    if (startDate != null) {
      where += ' AND timestamp >= ?';
      whereArgs.add(startDate.toIso8601String());
    }

    if (endDate != null) {
      where += ' AND timestamp <= ?';
      whereArgs.add(endDate.toIso8601String());
    }

    final result = await db.rawQuery('''
      SELECT 
        armSide,
        COUNT(*) as recordCount,
        SUM(magnitudeActiveTime) as totalMagnitudeActiveTime,
        AVG(magnitudeActiveTime) as avgMagnitudeActiveTime,
        SUM(axisActiveTime) as totalAxisActiveTime,
        AVG(axisActiveTime) as avgAxisActiveTime
      FROM movement_data
      WHERE $where
      GROUP BY armSide
    ''', whereArgs);

    final Map<String, dynamic> comparison = {
      'left': {
        'recordCount': 0,
        'totalMagnitudeActiveTime': 0,
        'avgMagnitudeActiveTime': 0.0,
        'totalAxisActiveTime': 0,
        'avgAxisActiveTime': 0.0,
      },
      'right': {
        'recordCount': 0,
        'totalMagnitudeActiveTime': 0,
        'avgMagnitudeActiveTime': 0.0,
        'totalAxisActiveTime': 0,
        'avgAxisActiveTime': 0.0,
      },
    };

    for (final row in result) {
      final armSide = row['armSide'].toString();
      comparison[armSide] = {
        'recordCount': _parseInt(row['recordCount']),
        'totalMagnitudeActiveTime': _parseInt(row['totalMagnitudeActiveTime']),
        'avgMagnitudeActiveTime':
            _parseDouble(row['avgMagnitudeActiveTime']) ?? 0.0,
        'totalAxisActiveTime': _parseInt(row['totalAxisActiveTime']),
        'avgAxisActiveTime': _parseDouble(row['avgAxisActiveTime']) ?? 0.0,
      };
    }

    return comparison;
  }

  /// Statistiques journalières de mouvement
  Future<Map<String, dynamic>> getDailyMovementStats(
    String armSide,
    DateTime date,
  ) async {
    final db = await database;

    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final result = await db.rawQuery('''
      SELECT 
        COUNT(*) as recordCount,
        SUM(magnitudeActiveTime) as totalMagnitudeActiveTime,
        AVG(magnitudeActiveTime) as avgMagnitudeActiveTime,
        MAX(magnitudeActiveTime) as maxMagnitudeActiveTime,
        SUM(axisActiveTime) as totalAxisActiveTime,
        AVG(axisActiveTime) as avgAxisActiveTime,
        MAX(axisActiveTime) as maxAxisActiveTime,
        AVG(magnitude) as avgMagnitude,
        MAX(magnitude) as maxMagnitude,
        AVG(activityLevel) as avgActivityLevel
      FROM movement_data
      WHERE armSide = ? 
        AND timestamp >= ?
        AND timestamp < ?
    ''', [
      armSide,
      startOfDay.toIso8601String(),
      endOfDay.toIso8601String(),
    ]);

    if (result.isEmpty) {
      return {
        'date': date,
        'armSide': armSide,
        'recordCount': 0,
        'totalMagnitudeActiveTime': 0,
        'avgMagnitudeActiveTime': 0.0,
        'maxMagnitudeActiveTime': 0,
        'totalAxisActiveTime': 0,
        'avgAxisActiveTime': 0.0,
        'maxAxisActiveTime': 0,
        'avgMagnitude': 0.0,
        'maxMagnitude': 0.0,
        'avgActivityLevel': 0,
      };
    }

    final row = result.first;
    return {
      'date': date,
      'armSide': armSide,
      'recordCount': _parseInt(row['recordCount']),
      'totalMagnitudeActiveTime': _parseInt(row['totalMagnitudeActiveTime']),
      'avgMagnitudeActiveTime':
          _parseDouble(row['avgMagnitudeActiveTime']) ?? 0.0,
      'maxMagnitudeActiveTime': _parseInt(row['maxMagnitudeActiveTime']),
      'totalAxisActiveTime': _parseInt(row['totalAxisActiveTime']),
      'avgAxisActiveTime': _parseDouble(row['avgAxisActiveTime']) ?? 0.0,
      'maxAxisActiveTime': _parseInt(row['maxAxisActiveTime']),
      'avgMagnitude': _parseDouble(row['avgMagnitude']) ?? 0.0,
      'maxMagnitude': _parseDouble(row['maxMagnitude']) ?? 0.0,
      'avgActivityLevel': _parseInt(row['avgActivityLevel']),
    };
  }

  /// Supprime les anciennes données de mouvement
  Future<int> deleteOldMovementData(Duration retentionPeriod) async {
    final db = await database;
    final cutoffDate = DateTime.now().subtract(retentionPeriod);

    return db.delete(
      'movement_data',
      where: 'timestamp < ?',
      whereArgs: [cutoffDate.toIso8601String()],
    );
  }

  /// Vide toutes les données de mouvement
  Future<void> clearAllMovementData() async {
    final db = await database;
    await db.delete('movement_data');
  }

  // ============================================================================
  // SETTINGS
  // ============================================================================

  static final defaultSettings = AppSettings(
    userName: "Votre nom",
    profileImagePath: null,
    collectionFrequency: 30,
    dailyObjective: 80,
    affectedSide: ArmSide.left,
    vibrationMode: VibrationMode.doubleShort,
    vibrationTargetArm: VibrationArm.both,
    checkFrequencyMin: 10,
    notificationStrategy: NotificationStrategy.discreet,
    notificationsEnabled: true,
    vibrationOnMs: 200,
    vibrationOffMs: 100,
    leftWatchName: 'PineTime L',
    rightWatchName: 'PineTime R',
    vibrationRepeat: 2,
    language: AppLanguage.fr,
    themeMode: AppTheme.system,
    bluetoothScanTimeout: 15,
    bluetoothConnectionTimeout: 30,
    bluetoothMaxRetries: 5,
    dataRecordInterval: 2,
    movementRecordInterval: 30,
  );

  Future<AppSettings?> fetchSettings() async {
    final db = await instance.database;
    final maps = await db.query('settings', where: 'id = ?', whereArgs: [1]);
    if (maps.isNotEmpty) {
      return AppSettings.fromMap(maps.first);
    } else {
      await saveSettings(defaultSettings);
      return defaultSettings;
    }
  }

  Future<void> saveSettings(AppSettings settings) async {
    final db = await instance.database;
    await db.insert(
      'settings',
      settings.toMap()..['id'] = 1,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ============================================================================
  // CONNECTION EVENTS
  // ============================================================================

  Future<void> insertConnectionEvent(ConnectionEvent event) async {
    final db = await database;
    await db.insert(
      'connection_events',
      {
        ...event.toJson(),
        'createdAt': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<ConnectionEvent>> getConnectionHistory(
    String armSide, {
    DateTime? startDate,
    DateTime? endDate,
    int limit = 100,
  }) async {
    final db = await database;

    String where = 'armSide = ?';
    List<dynamic> whereArgs = [armSide];

    if (startDate != null) {
      where += ' AND timestamp >= ?';
      whereArgs.add(startDate.toIso8601String());
    }

    if (endDate != null) {
      where += ' AND timestamp <= ?';
      whereArgs.add(endDate.toIso8601String());
    }

    final result = await db.query(
      'connection_events',
      where: where,
      whereArgs: whereArgs,
      orderBy: 'timestamp DESC',
      limit: limit,
    );

    return result.map((row) => ConnectionEvent.fromJson(row)).toList();
  }

  Future<ConnectionEvent?> getLastConnection(String armSide) async {
    final db = await database;

    final result = await db.query(
      'connection_events',
      where: 'armSide = ? AND type = ?',
      whereArgs: [armSide, 'connected'],
      orderBy: 'timestamp DESC',
      limit: 1,
    );

    if (result.isEmpty) return null;
    return ConnectionEvent.fromJson(result.first);
  }

  Future<ConnectionEvent?> getLastDisconnection(String armSide) async {
    final db = await database;

    final result = await db.query(
      'connection_events',
      where: 'armSide = ? AND type = ?',
      whereArgs: [armSide, 'disconnected'],
      orderBy: 'timestamp DESC',
      limit: 1,
    );

    if (result.isEmpty) return null;
    return ConnectionEvent.fromJson(result.first);
  }

  Future<List<ConnectionEvent>> getDailyConnectionEvents(
    String armSide,
    DateTime date,
  ) async {
    final db = await database;

    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final result = await db.query(
      'connection_events',
      where: 'armSide = ? AND timestamp >= ? AND timestamp < ?',
      whereArgs: [
        armSide,
        startOfDay.toIso8601String(),
        endOfDay.toIso8601String()
      ],
      orderBy: 'timestamp ASC',
    );

    return result.map((row) => ConnectionEvent.fromJson(row)).toList();
  }

  Future<ConnectionStatistics> calculateConnectionStats(
    String armSide, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final db = await database;

    String where = 'armSide = ?';
    List<dynamic> whereArgs = [armSide];

    if (startDate != null) {
      where += ' AND timestamp >= ?';
      whereArgs.add(startDate.toIso8601String());
    }

    if (endDate != null) {
      where += ' AND timestamp <= ?';
      whereArgs.add(endDate.toIso8601String());
    }

    final result = await db.query(
      'connection_events',
      where: where,
      whereArgs: whereArgs,
      orderBy: 'timestamp ASC',
    );

    final events = result.map((row) => ConnectionEvent.fromJson(row)).toList();

    int totalConnections = 0;
    int totalDisconnections = 0;
    int failedAttempts = 0;
    Duration totalConnectedTime = Duration.zero;
    Duration longestConnection = Duration.zero;
    DateTime? lastConnected;
    DateTime? lastDisconnected;

    for (final event in events) {
      switch (event.type) {
        case ConnectionEventType.connected:
          totalConnections++;
          lastConnected = event.timestamp;
          break;
        case ConnectionEventType.disconnected:
          totalDisconnections++;
          lastDisconnected = event.timestamp;
          if (event.durationSeconds != null) {
            final duration = Duration(seconds: event.durationSeconds!);
            totalConnectedTime += duration;
            if (duration > longestConnection) {
              longestConnection = duration;
            }
          }
          break;
        case ConnectionEventType.connectionFailed:
          failedAttempts++;
          break;
        case ConnectionEventType.reconnecting:
          break;
      }
    }

    final averageDuration = totalConnections > 0
        ? Duration(seconds: totalConnectedTime.inSeconds ~/ totalConnections)
        : Duration.zero;

    final totalTime = endDate != null && startDate != null
        ? endDate.difference(startDate)
        : const Duration(days: 1);
    final uptime = totalConnectedTime.inSeconds / totalTime.inSeconds;

    return ConnectionStatistics(
      armSide: armSide,
      totalConnections: totalConnections,
      totalDisconnections: totalDisconnections,
      averageConnectionDuration: averageDuration,
      longestConnectionDuration: longestConnection,
      failedConnectionAttempts: failedAttempts,
      lastConnected: lastConnected,
      lastDisconnected: lastDisconnected,
      uptime: uptime.clamp(0.0, 1.0),
    );
  }

  Future<int> deleteConnectionOldEvents(Duration retentionPeriod) async {
    final db = await database;
    final cutoffDate = DateTime.now().subtract(retentionPeriod);

    return db.delete(
      'connection_events',
      where: 'timestamp < ?',
      whereArgs: [cutoffDate.toIso8601String()],
    );
  }

  Future<void> clearAllConnectionEvents() async {
    final db = await database;
    await db.delete('connection_events');
  }

  // ============================================================================
  // UTILITY METHODS
  // ============================================================================

  double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  /// Supprime les anciennes données (toutes tables)
  Future<int> deleteOldSensorData(Duration retentionPeriod) async {
    int totalDeleted = 0;
    totalDeleted += await deleteOldDeviceInfo(retentionPeriod);
    totalDeleted += await deleteOldMovementData(retentionPeriod);
    totalDeleted += await deleteConnectionOldEvents(retentionPeriod);
    return totalDeleted;
  }
}
