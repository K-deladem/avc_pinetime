import '../../models/app_settings.dart';

/// Abstract interface for settings repository
/// Implementations should handle local storage operations for app settings
abstract class SettingsRepository {
  /// Fetches the current app settings
  /// Returns null if no settings exist, or default settings on error
  Future<AppSettings?> fetchSettings();

  /// Saves the app settings
  /// Throws [Exception] if save operation fails
  Future<void> saveSettings(AppSettings settings);

  /// Resets settings to default values
  Future<void> resetToDefaults();

  /// Updates a specific setting field
  Future<void> updateSetting<T>(String key, T value);
}
