import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app_template/domain/repositories/watch_repository.dart';
import 'package:flutter_bloc_app_template/utils/app_logger.dart';

import 'watch_event.dart';
import 'watch_state.dart';

class WatchBloc extends Bloc<WatchEvent, WatchState> {
  final WatchRepository repository;

  WatchBloc(this.repository) : super(WatchInitial()) {
    on<LoadWatchDevices>(_onLoad);
    on<AddWatchDevice>(_onAdd);
    on<UpdateWatchDevice>(_onUpdate);
    on<DeleteWatchDevice>(_onDelete);
    on<SaveWatchDevice>(_onSave);
  }

  Future<void> _onLoad(LoadWatchDevices event, Emitter<WatchState> emit) async {
    emit(WatchLoading());
    try {
      final devices = await repository.getAllDevices();
      emit(WatchLoaded(devices));
    } catch (e, stackTrace) {
      AppLogger.error('Error loading watch devices', e, stackTrace);
      emit(WatchError(e.toString()));
    }
  }

  Future<void> _onAdd(AddWatchDevice event, Emitter<WatchState> emit) async {
    try {
      await repository.addWatchDevice(event.device);
      add(LoadWatchDevices());
    } catch (e, stackTrace) {
      AppLogger.error('Error adding watch device', e, stackTrace);
      emit(WatchError('Failed to add device: ${e.toString()}'));
    }
  }

  Future<void> _onUpdate(UpdateWatchDevice event, Emitter<WatchState> emit) async {
    try {
      await repository.updateWatchDevice(event.device);
      add(LoadWatchDevices());
    } catch (e, stackTrace) {
      AppLogger.error('Error updating watch device', e, stackTrace);
      emit(WatchError('Failed to update device: ${e.toString()}'));
    }
  }

  Future<void> _onDelete(DeleteWatchDevice event, Emitter<WatchState> emit) async {
    try {
      await repository.deleteDevice(event.id);
      add(LoadWatchDevices());
    } catch (e, stackTrace) {
      AppLogger.error('Error deleting watch device', e, stackTrace);
      emit(WatchError('Failed to delete device: ${e.toString()}'));
    }
  }

  Future<void> _onSave(SaveWatchDevice event, Emitter<WatchState> emit) async {
    try {
      await repository.saveOrUpdateDevice(event.device);
      add(LoadWatchDevices());
    } catch (e, stackTrace) {
      AppLogger.error('Error saving watch device', e, stackTrace);
      emit(WatchError('Failed to save device: ${e.toString()}'));
    }
  }
}