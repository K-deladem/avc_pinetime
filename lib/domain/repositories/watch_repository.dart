import '../../models/watch_device.dart';

/// Abstract interface for watch device repository
/// Implementations should handle CRUD operations for watch devices
abstract class WatchRepository {
  /// Adds a new watch device to storage
  Future<void> addWatchDevice(WatchDevice device);

  /// Gets all stored watch devices
  Future<List<WatchDevice>> getAllDevices();

  /// Gets a specific device by its ID
  /// Returns null if device not found
  Future<WatchDevice?> getDeviceById(String id);

  /// Updates an existing watch device
  Future<void> updateWatchDevice(WatchDevice device);

  /// Deletes a device by its ID
  Future<void> deleteDevice(String id);

  /// Deletes all stored devices
  Future<void> deleteAllDevices();

  /// Saves or updates a device (upsert operation)
  Future<void> saveOrUpdateDevice(WatchDevice device);
}
