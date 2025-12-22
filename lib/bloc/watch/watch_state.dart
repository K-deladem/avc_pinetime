import 'package:flutter_bloc_app_template/models/watch_device.dart';

abstract class WatchState {}

class WatchInitial extends WatchState {}

class WatchLoading extends WatchState {}

class WatchLoaded extends WatchState {
  final List<WatchDevice> devices;
  WatchLoaded(this.devices);
}

class WatchError extends WatchState {
  final String message;
  WatchError(this.message);
}