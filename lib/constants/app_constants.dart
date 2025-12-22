/// Application-wide constants
///
/// This file centralizes all magic numbers, timeouts, and configuration values
/// to improve maintainability and prevent hardcoding throughout the codebase.
library;

/// BLE Connection Constants
class BleConstants {
  BleConstants._();

  /// Maximum time to wait for device discovery during scanning
  static const Duration scanTimeout = Duration(seconds: 30);

  /// Delay before retrying a failed connection
  static const Duration connectionRetryDelay = Duration(milliseconds: 500);

  /// Maximum time to wait for a connection to establish
  static const Duration connectionTimeout = Duration(seconds: 15);

  /// Delay between connection attempts
  static const Duration connectionCooldown = Duration(seconds: 2);

  /// Debounce duration for RSSI updates
  static const Duration rssiDebounceDelay = Duration(milliseconds: 500);

  /// Time to wait before considering a device disconnected
  static const Duration disconnectionTimeout = Duration(seconds: 10);

  /// Maximum retry attempts for connection
  static const int maxConnectionRetries = 3;

  /// Preferred MTU size for BLE communication
  static const int preferredMtu = 247;

  /// Minimum acceptable MTU size
  static const int minimumMtu = 23;
}

/// Sensor Data Constants
class SensorConstants {
  SensorConstants._();

  /// Maximum number of sensor readings to buffer before flushing to database
  static const int bufferSize = 100;

  /// Interval for periodic buffer flush
  static const Duration bufferFlushInterval = Duration(seconds: 30);

  /// Interval for battery level refresh
  static const Duration batteryRefreshInterval = Duration(minutes: 5);

  /// Timeout for sensor read operations
  static const Duration sensorReadTimeout = Duration(seconds: 5);
}

/// Cache and Cleanup Constants
class CacheConstants {
  CacheConstants._();

  /// Duration to keep scan results in cache
  static const Duration scanCacheLifetime = Duration(minutes: 2);

  /// Interval for cleaning up stale cache entries
  static const Duration cacheCleanupInterval = Duration(minutes: 5);

  /// Maximum number of cached devices
  static const int maxCachedDevices = 50;
}

/// Database Constants
class DatabaseConstants {
  DatabaseConstants._();

  /// Database name
  static const String databaseName = 'infinitime.db';

  /// Current database version
  static const int databaseVersion = 1;

  /// Table names
  static const String deviceTable = 'devices';
  static const String settingsTable = 'settings';
}

/// UI Constants
class UiConstants {
  UiConstants._();

  /// Default animation duration
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);

  /// Shimmer loading duration
  static const Duration shimmerDuration = Duration(milliseconds: 1500);

  /// Toast/Snackbar display duration
  static const Duration toastDuration = Duration(seconds: 3);

  /// Default padding
  static const double defaultPadding = 16.0;

  /// Default border radius
  static const double defaultBorderRadius = 12.0;
}

/// Storage Keys
class StorageKeys {
  StorageKeys._();

  /// SharedPreferences keys
  static const String leftDeviceId = 'left_device_id';
  static const String rightDeviceId = 'right_device_id';
  static const String appSettings = 'app_settings';
  static const String userPreferences = 'user_preferences';
  static const String lastSyncTimestamp = 'last_sync_timestamp';
}

/// App Configuration
class AppConfig {
  AppConfig._();

  /// Application name
  static const String appName = 'AVC PineTime';

  /// Application version (should match pubspec.yaml)
  static const String appVersion = '1.0.0';

  /// Enable debug logging
  static const bool enableDebugLogging = true;

  /// API base URL (if applicable)
  static const String apiBaseUrl = '';

  /// Support email
  static const String supportEmail = 'support@avcpinetime.com';
}

/// Permission Constants
class PermissionConstants {
  PermissionConstants._();

  /// Required permissions for BLE functionality
  static const List<String> requiredBlePermissions = [
    'android.permission.BLUETOOTH',
    'android.permission.BLUETOOTH_ADMIN',
    'android.permission.BLUETOOTH_SCAN',
    'android.permission.BLUETOOTH_CONNECT',
    'android.permission.ACCESS_FINE_LOCATION',
  ];
}
