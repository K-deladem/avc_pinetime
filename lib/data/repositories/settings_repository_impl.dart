import '../../app/app_database.dart';
import '../../core/error/exceptions.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../models/app_settings.dart';
import '../../utils/app_logger.dart';

/// Implementation of [SettingsRepository] using local SQLite database
class SettingsRepositoryImpl implements SettingsRepository {
  final AppDatabase _database;
  static const Duration _timeout = Duration(seconds: 10);
  static const Duration _saveTimeout = Duration(seconds: 5);

  SettingsRepositoryImpl({required AppDatabase database}) : _database = database;

  @override
  Future<AppSettings?> fetchSettings() async {
    try {
      return await _database.fetchSettings().timeout(
        _timeout,
        onTimeout: () {
          AppLogger.warning('Timeout loading settings, using defaults');
          return AppDatabase.defaultSettings;
        },
      );
    } catch (e, stackTrace) {
      AppLogger.error('Error fetching settings', e, stackTrace);
      return AppDatabase.defaultSettings;
    }
  }

  @override
  Future<void> saveSettings(AppSettings settings) async {
    try {
      await _database.saveSettings(settings).timeout(_saveTimeout);
    } catch (e, stackTrace) {
      AppLogger.error('Error saving settings', e, stackTrace);
      throw DatabaseException(
        message: 'Failed to save settings',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> resetToDefaults() async {
    try {
      await saveSettings(AppDatabase.defaultSettings);
    } catch (e, stackTrace) {
      AppLogger.error('Error resetting settings to defaults', e, stackTrace);
      throw DatabaseException(
        message: 'Failed to reset settings',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> updateSetting<T>(String key, T value) async {
    try {
      final currentSettings = await fetchSettings();
      if (currentSettings == null) {
        throw const DatabaseException(message: 'No settings found to update');
      }

      // Create updated settings based on key
      final updatedSettings = _updateSettingByKey(currentSettings, key, value);
      await saveSettings(updatedSettings);
    } catch (e, stackTrace) {
      if (e is DatabaseException) rethrow;
      AppLogger.error('Error updating setting: $key', e, stackTrace);
      throw DatabaseException(
        message: 'Failed to update setting: $key',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  AppSettings _updateSettingByKey<T>(AppSettings settings, String key, T value) {
    // This method should be expanded based on AppSettings fields
    // For now, return the original settings
    // In a real implementation, use copyWith pattern
    return settings;
  }
}
