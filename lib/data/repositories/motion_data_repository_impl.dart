import 'package:infinitime_dfu_library/infinitime_dfu_library.dart';

import '../../app/app_database.dart';
import '../../core/error/exceptions.dart';
import '../../domain/repositories/motion_data_repository.dart';
import '../../models/motion_data.dart';
import '../../utils/app_logger.dart';

/// Implementation of [MotionDataRepository] using local SQLite database
/// Converts between MotionData (app model) and MovementData (infinitime library)
class MotionDataRepositoryImpl implements MotionDataRepository {
  final AppDatabase _database;

  MotionDataRepositoryImpl({required AppDatabase database}) : _database = database;

  @override
  Future<void> saveMotionData(MotionData data) async {
    try {
      final movementData = _toMovementData(data);
      await _database.insertMovementData(data.armSide, movementData, rssi: data.rssi);
    } catch (e, stackTrace) {
      AppLogger.error('Error saving motion data', e, stackTrace);
      throw DatabaseException(
        message: 'Failed to save motion data',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> saveMotionDataBatch(List<MotionData> dataList) async {
    try {
      // Group by armSide and save each batch
      final Map<String, List<MotionData>> grouped = {};
      for (final data in dataList) {
        grouped.putIfAbsent(data.armSide, () => []).add(data);
      }

      for (final entry in grouped.entries) {
        for (final data in entry.value) {
          final movementData = _toMovementData(data);
          await _database.insertMovementData(entry.key, movementData, rssi: data.rssi);
        }
      }
    } catch (e, stackTrace) {
      AppLogger.error('Error saving motion data batch', e, stackTrace);
      throw DatabaseException(
        message: 'Failed to save motion data batch',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<List<MotionData>> getMotionData({
    required String deviceId,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    try {
      final results = <MotionData>[];

      // Query for both arms since we don't have deviceId mapping
      for (final armSide in ['left', 'right']) {
        final data = await _database.getMovementData(
          armSide,
          startDate: startTime,
          endDate: endTime,
        );
        results.addAll(data.map((map) => _fromDatabaseMap(map, armSide)));
      }

      return results;
    } catch (e, stackTrace) {
      AppLogger.error('Error getting motion data', e, stackTrace);
      return [];
    }
  }

  @override
  Future<MotionData?> getLatestMotionData(String deviceId) async {
    try {
      // Get latest from both arms and return the most recent
      MotionData? latest;

      for (final armSide in ['left', 'right']) {
        final data = await _database.getMovementData(
          armSide,
          limit: 1,
        );
        if (data.isNotEmpty) {
          final motionData = _fromDatabaseMap(data.first, armSide);
          if (latest == null || motionData.timestamp.isAfter(latest.timestamp)) {
            latest = motionData;
          }
        }
      }

      return latest;
    } catch (e, stackTrace) {
      AppLogger.error('Error getting latest motion data', e, stackTrace);
      return null;
    }
  }

  @override
  Future<void> deleteOldMotionData(DateTime beforeDate) async {
    try {
      final age = DateTime.now().difference(beforeDate);
      await _database.deleteOldMovementData(age);
    } catch (e, stackTrace) {
      AppLogger.error('Error deleting old motion data', e, stackTrace);
      throw DatabaseException(
        message: 'Failed to delete old motion data',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<int> getMotionDataCount(String deviceId) async {
    try {
      int count = 0;
      for (final armSide in ['left', 'right']) {
        final data = await _database.getMovementData(armSide, limit: 10000);
        count += data.length;
      }
      return count;
    } catch (e, stackTrace) {
      AppLogger.error('Error getting motion data count', e, stackTrace);
      return 0;
    }
  }

  @override
  Future<void> clearMotionData(String deviceId) async {
    try {
      // Clear all movement data by using 0 duration
      await _database.deleteOldMovementData(const Duration(days: 0));
    } catch (e, stackTrace) {
      AppLogger.error('Error clearing motion data', e, stackTrace);
      throw DatabaseException(
        message: 'Failed to clear motion data',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Convert app MotionData to library MovementData
  MovementData _toMovementData(MotionData data) {
    return MovementData(
      timestampMs: data.timestamp.millisecondsSinceEpoch,
      magnitudeActiveTime: 0,
      axisActiveTime: 0,
      movementDetected: true,
      anyMovement: true,
      accelX: data.x / 100.0,
      accelY: data.y / 100.0,
      accelZ: data.z / 100.0,
    );
  }

  /// Convert database map to app MotionData
  MotionData _fromDatabaseMap(Map<String, dynamic> map, String armSide) {
    final timestamp = map['created_at'] != null
        ? DateTime.parse(map['created_at'] as String)
        : DateTime.fromMillisecondsSinceEpoch(map['timestamp_ms'] as int? ?? 0);

    return MotionData(
      id: map['id']?.toString(),
      armSide: armSide,
      x: ((map['accel_x'] as num?) ?? 0 * 100).toInt(),
      y: ((map['accel_y'] as num?) ?? 0 * 100).toInt(),
      z: ((map['accel_z'] as num?) ?? 0 * 100).toInt(),
      timestamp: timestamp,
      rssi: map['rssi'] as int?,
    );
  }
}
