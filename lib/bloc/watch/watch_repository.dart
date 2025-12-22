import 'package:flutter_bloc_app_template/app/app_database.dart';
import 'package:flutter_bloc_app_template/models/watch_device.dart';

class WatchRepository {
  final AppDatabase _db = AppDatabase.instance;

  Future<void> addWatchDevice(WatchDevice device) {
    return _db.insertWatchDevice(device);
  }

  Future<List<WatchDevice>> getAllDevices() {
    return _db.getAllWatchDevices();
  }

  Future<WatchDevice?> getDeviceById(String id) {
    return _db.getWatchDeviceById(id);
  }

  Future<void> updateWatchDevice(WatchDevice device) {
    return _db.updateWatchDevice(device);
  }

  Future<void> deleteDevice(String id) {
    return _db.deleteWatchDevice(id);
  }

  Future<void> deleteAllDevices() {
    return _db.deleteAllWatchDevices();
  }

  Future<void> saveOrUpdateDevice(WatchDevice device) async {
    final existing = await getDeviceById(device.id);
    if (existing == null) {
      await addWatchDevice(device);
    } else {
      await updateWatchDevice(device);
    }
  }


}