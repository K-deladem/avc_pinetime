import 'package:infinitime_dfu_library/infinitime_dfu_library.dart';

import '../../../app/app_database.dart';
import '../../../models/arm_side.dart';
import '../../../models/movement_sampling_settings.dart';
import '../../../utils/app_logger.dart';

/// Handler pour la gestion des données de capteurs (battery, steps, RSSI, movement)
class SensorDataHandler {
  final AppDatabase _db;

  // Buffer sizes
  static const int maxDeviceInfoBufferSize = 50;
  static const int maxMovementBufferSize = 100;

  // Buffers
  final Map<ArmSide, List<Map<String, dynamic>>> _deviceInfoBuffer = {
    ArmSide.left: [],
    ArmSide.right: [],
  };

  final Map<ArmSide, List<MovementData>> _movementBuffer = {
    ArmSide.left: [],
    ArmSide.right: [],
  };

  // Tracking pour le sampling
  final Map<ArmSide, DateTime?> _lastMovementSampleTime = {
    ArmSide.left: null,
    ArmSide.right: null,
  };

  final Map<ArmSide, double?> _lastMovementMagnitude = {
    ArmSide.left: null,
    ArmSide.right: null,
  };

  // Buffer d'agrégation
  final Map<ArmSide, List<MovementData>> _movementAggregateBuffer = {
    ArmSide.left: [],
    ArmSide.right: [],
  };

  // Tracking des dernières valeurs cumulatives pour calcul des deltas
  final Map<ArmSide, int?> _lastMagnitudeActiveTime = {
    ArmSide.left: null,
    ArmSide.right: null,
  };

  final Map<ArmSide, int?> _lastAxisActiveTime = {
    ArmSide.left: null,
    ArmSide.right: null,
  };

  // Tracking pour enregistrement intelligent
  final Map<ArmSide, Map<String, DateTime>> _lastRecordTime = {
    ArmSide.left: {},
    ArmSide.right: {},
  };

  final Map<ArmSide, Map<String, dynamic>> _lastRecordedValue = {
    ArmSide.left: {},
    ArmSide.right: {},
  };

  MovementSamplingSettings _samplingSettings = const MovementSamplingSettings();

  SensorDataHandler({required AppDatabase database}) : _db = database;

  /// Met à jour les paramètres de sampling
  void updateSamplingSettings(MovementSamplingSettings settings) {
    _samplingSettings = settings;
  }

  /// Obtient la taille actuelle des buffers
  Map<String, Map<String, int>> getBufferSizes() {
    return {
      'left': {
        'device_info': _deviceInfoBuffer[ArmSide.left]?.length ?? 0,
        'movement': _movementBuffer[ArmSide.left]?.length ?? 0,
      },
      'right': {
        'device_info': _deviceInfoBuffer[ArmSide.right]?.length ?? 0,
        'movement': _movementBuffer[ArmSide.right]?.length ?? 0,
      },
    };
  }

  // ========== BUFFERING METHODS ==========

  /// Buffer une donnée device_info (battery, steps, rssi)
  void bufferDeviceInfo(ArmSide side, String infoType, double value) {
    final buffer = _deviceInfoBuffer[side];
    if (buffer == null) {
      AppLogger.error('Device info buffer not initialized for $side');
      return;
    }

    // Protection OOM
    if (buffer.length >= maxDeviceInfoBufferSize) {
      AppLogger.warning('Device info buffer full, flushing...');
      flushDeviceInfoBuffer(side);
    }

    buffer.add({
      'armSide': side.name,
      'infoType': infoType,
      'value': value,
      'timestamp': DateTime.now(),
    });

    // Flush automatique toutes les 5 entrées
    if (buffer.length >= 5) {
      flushDeviceInfoBuffer(side);
    }
  }

  /// Buffer une donnée de mouvement avec filtrage
  void bufferMovement(ArmSide side, MovementData movement, int? rssi) {
    final buffer = _movementBuffer[side];
    if (buffer == null) {
      AppLogger.error('Movement buffer not initialized for $side');
      return;
    }

    // Appliquer le filtrage
    if (!_shouldSampleMovement(side, movement)) {
      return;
    }

    // Protection OOM
    if (buffer.length >= maxMovementBufferSize) {
      AppLogger.warning('Movement buffer full, flushing...');
      flushMovementBuffer(side, rssi);
    }

    // Calculer les deltas
    final lastMag = _lastMagnitudeActiveTime[side];
    final lastAxis = _lastAxisActiveTime[side];

    if (lastMag != null && lastAxis != null) {
      final magnitudeDelta = movement.magnitudeActiveTime >= lastMag
          ? movement.magnitudeActiveTime - lastMag
          : movement.magnitudeActiveTime;
      final axisDelta = movement.axisActiveTime >= lastAxis
          ? movement.axisActiveTime - lastAxis
          : movement.axisActiveTime;

      AppLogger.debug(
          'Delta calculated: magDelta=${magnitudeDelta}ms, axisDelta=${axisDelta}ms');
    }

    _lastMagnitudeActiveTime[side] = movement.magnitudeActiveTime;
    _lastAxisActiveTime[side] = movement.axisActiveTime;

    buffer.add(movement);

    // Flush automatique
    final flushThreshold = _samplingSettings.maxSamplesPerFlush ~/ 6;
    if (buffer.length >= flushThreshold) {
      flushMovementBuffer(side, rssi);
    }
  }

  /// Vérifie si l'échantillon doit être gardé
  bool _shouldSampleMovement(ArmSide side, MovementData movement) {
    final now = DateTime.now();
    final lastSampleTime = _lastMovementSampleTime[side];
    final lastMagnitude = _lastMovementMagnitude[side];
    final currentMagnitude = movement.getAccelerationMagnitude();

    switch (_samplingSettings.mode) {
      case MovementSamplingMode.all:
        _lastMovementSampleTime[side] = now;
        _lastMovementMagnitude[side] = currentMagnitude;
        return true;

      case MovementSamplingMode.interval:
        if (lastSampleTime == null) {
          _lastMovementSampleTime[side] = now;
          _lastMovementMagnitude[side] = currentMagnitude;
          return true;
        }
        final elapsed = now.difference(lastSampleTime).inMilliseconds;
        if (elapsed >= _samplingSettings.intervalMs) {
          _lastMovementSampleTime[side] = now;
          _lastMovementMagnitude[side] = currentMagnitude;
          return true;
        }
        return false;

      case MovementSamplingMode.threshold:
        if (lastMagnitude == null) {
          _lastMovementSampleTime[side] = now;
          _lastMovementMagnitude[side] = currentMagnitude;
          return true;
        }
        final change = (currentMagnitude - lastMagnitude).abs();
        if (change >= _samplingSettings.changeThreshold) {
          _lastMovementSampleTime[side] = now;
          _lastMovementMagnitude[side] = currentMagnitude;
          return true;
        }
        return false;

      case MovementSamplingMode.aggregate:
        return _handleAggregateMode(side, movement, now);

      case MovementSamplingMode.recordsPerTimeUnit:
        if (lastSampleTime == null) {
          _lastMovementSampleTime[side] = now;
          _lastMovementMagnitude[side] = currentMagnitude;
          return true;
        }
        final elapsed = now.difference(lastSampleTime).inMilliseconds;
        final calculatedInterval = _samplingSettings.calculatedIntervalMs;
        if (elapsed >= calculatedInterval) {
          _lastMovementSampleTime[side] = now;
          _lastMovementMagnitude[side] = currentMagnitude;
          return true;
        }
        return false;
    }
  }

  /// Gère le mode d'agrégation
  bool _handleAggregateMode(ArmSide side, MovementData movement, DateTime now) {
    final aggregateBuffer = _movementAggregateBuffer[side];
    if (aggregateBuffer == null) return false;

    aggregateBuffer.add(movement);

    final lastSampleTime = _lastMovementSampleTime[side];
    if (lastSampleTime == null) {
      _lastMovementSampleTime[side] = now;
      return false;
    }

    final elapsed = now.difference(lastSampleTime).inMilliseconds;
    if (elapsed >= _samplingSettings.intervalMs && aggregateBuffer.isNotEmpty) {
      _lastMovementSampleTime[side] = now;
      aggregateBuffer.clear();
      return true;
    }

    return false;
  }

  // ========== FLUSH METHODS ==========

  /// Flush le buffer device_info vers la DB
  Future<void> flushDeviceInfoBuffer(ArmSide side) async {
    final buffer = _deviceInfoBuffer[side];
    if (buffer == null || buffer.isEmpty) return;

    final dataToFlush = List<Map<String, dynamic>>.from(buffer);
    buffer.clear();

    try {
      for (final data in dataToFlush) {
        await _db.insertDeviceInfo(
          armSide: data['armSide'] as String,
          infoType: data['infoType'] as String,
          value: data['value'] as double,
          timestamp: data['timestamp'] as DateTime,
        );
      }
      AppLogger.debug('Flushed ${dataToFlush.length} device_info records for ${side.name}');
    } catch (e, stackTrace) {
      AppLogger.error('Error flushing device_info buffer', e, stackTrace);
      // Remettre les données non sauvegardées dans le buffer
      buffer.insertAll(0, dataToFlush);
    }
  }

  /// Flush le buffer movement vers la DB
  Future<void> flushMovementBuffer(ArmSide side, int? rssi) async {
    final buffer = _movementBuffer[side];
    if (buffer == null || buffer.isEmpty) return;

    final dataToFlush = List<MovementData>.from(buffer);
    buffer.clear();

    try {
      for (final movement in dataToFlush) {
        await _db.insertMovementData(side.name, movement, rssi: rssi);
      }
      AppLogger.debug('Flushed ${dataToFlush.length} movement records for ${side.name}');
    } catch (e, stackTrace) {
      AppLogger.error('Error flushing movement buffer', e, stackTrace);
      buffer.insertAll(0, dataToFlush);
    }
  }

  /// Flush tous les buffers
  Future<void> flushAllBuffers({int? leftRssi, int? rightRssi}) async {
    await Future.wait([
      flushDeviceInfoBuffer(ArmSide.left),
      flushDeviceInfoBuffer(ArmSide.right),
      flushMovementBuffer(ArmSide.left, leftRssi),
      flushMovementBuffer(ArmSide.right, rightRssi),
    ]);
  }

  /// Nettoie les maps de tracking
  void cleanupTrackingMaps() {
    for (final side in ArmSide.values) {
      final recordTime = _lastRecordTime[side];
      final recordValue = _lastRecordedValue[side];

      if (recordTime != null && recordTime.length > 10) {
        final sorted = recordTime.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        final toKeep = sorted.take(10).map((e) => e.key).toSet();
        recordTime.removeWhere((key, _) => !toKeep.contains(key));
        recordValue?.removeWhere((key, _) => !toKeep.contains(key));
      }
    }
  }

  /// Vérifie si la batterie a changé significativement
  bool hasBatteryChangedSignificantly(ArmSide side, int newValue) {
    final lastValue = _lastRecordedValue[side]?['battery'];
    if (lastValue == null) return true;
    return (newValue - lastValue).abs() > 1;
  }

  /// Met à jour la dernière valeur enregistrée
  void updateLastRecordedValue(ArmSide side, String key, dynamic value) {
    _lastRecordedValue[side]?[key] = value;
  }
}
