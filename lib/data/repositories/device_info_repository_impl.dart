import '../../app/app_database.dart';
import '../../core/error/exceptions.dart';
import '../../domain/repositories/device_info_repository.dart';
import '../../models/arm_side.dart';
import '../../models/device_info_data.dart';
import '../../models/info_type.dart';
import '../../utils/app_logger.dart';

/// Implementation of [DeviceInfoRepository] using local SQLite database
class DeviceInfoRepositoryImpl implements DeviceInfoRepository {
  final AppDatabase _database;

  DeviceInfoRepositoryImpl({required AppDatabase database}) : _database = database;

  @override
  Future<void> saveDeviceInfo(DeviceInfoData data) async {
    try {
      await _database.insertDeviceInfo(
        armSide: data.armSide,
        infoType: data.infoType.name,
        value: data.value,
        timestamp: data.timestamp,
      );
    } catch (e, stackTrace) {
      AppLogger.error('Error saving device info', e, stackTrace);
      throw DatabaseException(
        message: 'Failed to save device info',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<List<DeviceInfoData>> getDeviceInfoByDeviceId(String deviceId) async {
    // Note: Current API uses armSide, not deviceId
    // Returning empty - the API needs to be extended if deviceId is required
    return [];
  }

  @override
  Future<List<DeviceInfoData>> getDeviceInfoByDateRange({
    required String deviceId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final results = <DeviceInfoData>[];

      for (final arm in ArmSide.values) {
        for (final infoType in InfoType.values) {
          final data = await _database.getDeviceInfo(
            arm.name,
            infoType.name,
            startDate: startDate,
            endDate: endDate,
          );
          results.addAll(data);
        }
      }

      return results;
    } catch (e, stackTrace) {
      AppLogger.error('Error getting device info by date range', e, stackTrace);
      return [];
    }
  }

  @override
  Future<DeviceInfoData?> getLatestDeviceInfo(String deviceId) async {
    try {
      // Get latest from left arm battery as default
      return await _database.getLatestDeviceInfo('left', 'battery');
    } catch (e, stackTrace) {
      AppLogger.error('Error getting latest device info', e, stackTrace);
      return null;
    }
  }

  @override
  Future<void> deleteDeviceInfo(String deviceId) async {
    try {
      await _database.deleteOldDeviceInfo(const Duration(days: 0));
    } catch (e, stackTrace) {
      AppLogger.error('Error deleting device info', e, stackTrace);
      throw DatabaseException(
        message: 'Failed to delete device info',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> deleteOldDeviceInfo(DateTime beforeDate) async {
    try {
      final age = DateTime.now().difference(beforeDate);
      await _database.deleteOldDeviceInfo(age);
    } catch (e, stackTrace) {
      AppLogger.error('Error deleting old device info', e, stackTrace);
      throw DatabaseException(
        message: 'Failed to delete old device info',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<Map<String, dynamic>?> getDailyAggregate({
    required String deviceId,
    required DateTime date,
  }) async {
    try {
      return await _database.calculateDeviceInfoStats(
        'left',
        'battery',
        date,
      );
    } catch (e, stackTrace) {
      AppLogger.error('Error getting daily aggregate', e, stackTrace);
      return null;
    }
  }
}
