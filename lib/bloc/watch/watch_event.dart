import 'package:flutter_bloc_app_template/models/watch_device.dart';

abstract class WatchEvent {}

class LoadWatchDevices extends WatchEvent {}

class AddWatchDevice extends WatchEvent {
  final WatchDevice device;
  AddWatchDevice(this.device);
}

class UpdateWatchDevice extends WatchEvent {
  final WatchDevice device;
  UpdateWatchDevice(this.device);
}

class DeleteWatchDevice extends WatchEvent {
  final String id;
  DeleteWatchDevice(this.id);
}

class SaveWatchDevice extends WatchEvent {
  final WatchDevice device;
  SaveWatchDevice(this.device);
}