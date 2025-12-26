import 'package:get_it/get_it.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

import '../../app/app_database.dart';
import '../../data/repositories/device_info_repository_impl.dart';
import '../../data/repositories/motion_data_repository_impl.dart';
import '../../data/repositories/settings_repository_impl.dart';
import '../../data/repositories/watch_repository_impl.dart';
import '../../domain/repositories/device_info_repository.dart';
import '../../domain/repositories/motion_data_repository.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../domain/repositories/watch_repository.dart';
import '../../domain/usecases/get_settings.dart';
import '../../domain/usecases/save_settings.dart';
import '../../domain/usecases/get_all_watches.dart';
import '../../routes/router.dart';

final sl = GetIt.instance;

/// Initialize all dependencies
Future<void> initDependencies() async {
  // Core
  await _initCore();

  // Repositories
  _initRepositories();

  // Use cases
  _initUseCases();

  // Services
  _initServices();
}

Future<void> _initCore() async {
  // Database
  sl.registerLazySingleton<AppDatabase>(() => AppDatabase.instance);

  // Bluetooth
  sl.registerLazySingleton<FlutterReactiveBle>(() => FlutterReactiveBle());
}

void _initRepositories() {
  // Settings Repository
  sl.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(database: sl()),
  );

  // Watch Repository
  sl.registerLazySingleton<WatchRepository>(
    () => WatchRepositoryImpl(database: sl()),
  );

  // Device Info Repository
  sl.registerLazySingleton<DeviceInfoRepository>(
    () => DeviceInfoRepositoryImpl(database: sl()),
  );

  // Motion Data Repository
  sl.registerLazySingleton<MotionDataRepository>(
    () => MotionDataRepositoryImpl(database: sl()),
  );
}

void _initUseCases() {
  // Settings use cases
  sl.registerLazySingleton(() => GetSettings(sl()));
  sl.registerLazySingleton(() => SaveSettings(sl()));

  // Watch use cases
  sl.registerLazySingleton(() => GetAllWatches(sl()));
}

void _initServices() {
  // Navigation Service
  sl.registerLazySingleton<NavigationService>(() => NavigationService());
}

/// Reset all dependencies (useful for testing)
Future<void> resetDependencies() async {
  await sl.reset();
  await initDependencies();
}
