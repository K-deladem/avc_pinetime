/// Constants for BLE operations
/// Centralized configuration for Bluetooth Low Energy operations
library;

class BleConstants {
  BleConstants._();

  // ========== SCAN CONSTANTS ==========
  static const int scanThrottleMs = 500;
  static const int scanCacheCleanupMinutes = 5;
  static const int defaultScanTimeoutSeconds = 30;

  // ========== CONNECTION CONSTANTS ==========
  static const int minReconnectDelayMs = 2000;
  static const int stableConnectionDelayMs = 3000;

  // ========== OPERATION DELAYS ==========
  static const Duration delayBeforeReconnect = Duration(milliseconds: 300);
  static const Duration delayBetweenStreams = Duration(milliseconds: 5);
  static const Duration delayBetweenOperations = Duration(milliseconds: 150);
  static const Duration delayAfterConnection = Duration(milliseconds: 200);

  // ========== BUFFER LIMITS ==========
  static const int maxDeviceInfoBufferSize = 50;
  static const int maxMovementBufferSize = 100;

  // ========== RSSI CONSTANTS ==========
  static const int rssiDebounceMs = 500;
  static const int rssiMinSignal = -100;
  static const int rssiMaxSignal = -30;

  // ========== TIMER INTERVALS ==========
  static const Duration bufferFlushInterval = Duration(seconds: 30);
  static const Duration trackingCleanupInterval = Duration(minutes: 5);
  static const Duration oldDataCleanupInterval = Duration(hours: 1);
}

/// Configurable BLE settings (loaded from AppSettings)
class BleConfig {
  final int scanTimeoutSeconds;
  final int connectionTimeoutSeconds;
  final int maxRetryAttempts;
  final int maxReconnectDelayMs;
  final Duration minDeviceInfoRecordInterval;
  final Duration minMovementRecordInterval;

  const BleConfig({
    this.scanTimeoutSeconds = 30,
    this.connectionTimeoutSeconds = 30,
    this.maxRetryAttempts = 3,
    this.maxReconnectDelayMs = 30000,
    this.minDeviceInfoRecordInterval = const Duration(seconds: 60),
    this.minMovementRecordInterval = const Duration(seconds: 1),
  });

  BleConfig copyWith({
    int? scanTimeoutSeconds,
    int? connectionTimeoutSeconds,
    int? maxRetryAttempts,
    int? maxReconnectDelayMs,
    Duration? minDeviceInfoRecordInterval,
    Duration? minMovementRecordInterval,
  }) {
    return BleConfig(
      scanTimeoutSeconds: scanTimeoutSeconds ?? this.scanTimeoutSeconds,
      connectionTimeoutSeconds: connectionTimeoutSeconds ?? this.connectionTimeoutSeconds,
      maxRetryAttempts: maxRetryAttempts ?? this.maxRetryAttempts,
      maxReconnectDelayMs: maxReconnectDelayMs ?? this.maxReconnectDelayMs,
      minDeviceInfoRecordInterval: minDeviceInfoRecordInterval ?? this.minDeviceInfoRecordInterval,
      minMovementRecordInterval: minMovementRecordInterval ?? this.minMovementRecordInterval,
    );
  }
}
