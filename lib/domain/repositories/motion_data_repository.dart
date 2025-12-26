import '../../models/motion_data.dart';

/// Abstract interface for motion/acceleration data repository
/// Handles storage and retrieval of motion sensor data
abstract class MotionDataRepository {
  /// Saves motion data
  Future<void> saveMotionData(MotionData data);

  /// Saves multiple motion data entries in batch
  Future<void> saveMotionDataBatch(List<MotionData> dataList);

  /// Gets motion data for a specific device within a time range
  Future<List<MotionData>> getMotionData({
    required String deviceId,
    required DateTime startTime,
    required DateTime endTime,
  });

  /// Gets the latest motion data for a device
  Future<MotionData?> getLatestMotionData(String deviceId);

  /// Deletes motion data older than a specific date
  Future<void> deleteOldMotionData(DateTime beforeDate);

  /// Gets motion data count for a device
  Future<int> getMotionDataCount(String deviceId);

  /// Clears all motion data for a device
  Future<void> clearMotionData(String deviceId);
}
