import '../../app/app_database.dart';
import '../../core/error/exceptions.dart';
import '../../domain/repositories/watch_repository.dart';
import '../../models/watch_device.dart';
import '../../utils/app_logger.dart';

/// Implementation of [WatchRepository] using local SQLite database
class WatchRepositoryImpl implements WatchRepository {
  final AppDatabase _database;

  WatchRepositoryImpl({required AppDatabase database}) : _database = database;

  @override
  Future<void> addWatchDevice(WatchDevice device) async {
    try {
      await _database.insertWatchDevice(device);
    } catch (e, stackTrace) {
      AppLogger.error('Error adding watch device', e, stackTrace);
      throw DatabaseException(
        message: 'Failed to add watch device',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<List<WatchDevice>> getAllDevices() async {
    try {
      return await _database.getAllWatchDevices();
    } catch (e, stackTrace) {
      AppLogger.error('Error getting all devices', e, stackTrace);
      throw DatabaseException(
        message: 'Failed to get devices',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<WatchDevice?> getDeviceById(String id) async {
    try {
      return await _database.getWatchDeviceById(id);
    } catch (e, stackTrace) {
      AppLogger.error('Error getting device by id: $id', e, stackTrace);
      throw DatabaseException(
        message: 'Failed to get device',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> updateWatchDevice(WatchDevice device) async {
    try {
      await _database.updateWatchDevice(device);
    } catch (e, stackTrace) {
      AppLogger.error('Error updating watch device', e, stackTrace);
      throw DatabaseException(
        message: 'Failed to update watch device',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> deleteDevice(String id) async {
    try {
      await _database.deleteWatchDevice(id);
    } catch (e, stackTrace) {
      AppLogger.error('Error deleting device: $id', e, stackTrace);
      throw DatabaseException(
        message: 'Failed to delete device',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> deleteAllDevices() async {
    try {
      await _database.deleteAllWatchDevices();
    } catch (e, stackTrace) {
      AppLogger.error('Error deleting all devices', e, stackTrace);
      throw DatabaseException(
        message: 'Failed to delete all devices',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> saveOrUpdateDevice(WatchDevice device) async {
    try {
      final existing = await _database.getWatchDeviceById(device.id);
      if (existing == null) {
        await addWatchDevice(device);
      } else {
        await updateWatchDevice(device);
      }
    } catch (e, stackTrace) {
      if (e is DatabaseException) rethrow;
      AppLogger.error('Error saving/updating device', e, stackTrace);
      throw DatabaseException(
        message: 'Failed to save or update device',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}
