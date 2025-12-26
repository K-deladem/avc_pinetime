import '../../models/device_info_data.dart';

/// Abstract interface for device info/sensor data repository
/// Handles storage and retrieval of watch sensor data
abstract class DeviceInfoRepository {
  /// Saves device info data
  Future<void> saveDeviceInfo(DeviceInfoData data);

  /// Gets all device info for a specific device
  Future<List<DeviceInfoData>> getDeviceInfoByDeviceId(String deviceId);

  /// Gets device info within a date range
  Future<List<DeviceInfoData>> getDeviceInfoByDateRange({
    required String deviceId,
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Gets the latest device info for a device
  Future<DeviceInfoData?> getLatestDeviceInfo(String deviceId);

  /// Deletes all device info for a specific device
  Future<void> deleteDeviceInfo(String deviceId);

  /// Deletes device info older than a specific date
  Future<void> deleteOldDeviceInfo(DateTime beforeDate);

  /// Gets aggregated data for a specific day
  Future<Map<String, dynamic>?> getDailyAggregate({
    required String deviceId,
    required DateTime date,
  });
}
