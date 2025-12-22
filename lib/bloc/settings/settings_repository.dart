// settings_repository.dart
import 'package:flutter_bloc_app_template/app/app_database.dart';
import 'package:flutter_bloc_app_template/models/app_settings.dart';

abstract class SettingsRepository {
  Future<AppSettings?> fetchSettings();
  Future<void> saveSettings(AppSettings settings);
}

class SettingsRepositoryImpl implements SettingsRepository {
  final AppDatabase _db = AppDatabase.instance;

  @override
  Future<AppSettings?> fetchSettings() => _db.fetchSettings();

  @override
  Future<void> saveSettings(AppSettings settings) => _db.saveSettings(settings);
}
