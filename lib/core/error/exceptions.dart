/// Base exception class for the application
abstract class AppException implements Exception {
  final String message;
  final dynamic originalError;
  final StackTrace? stackTrace;

  const AppException({
    required this.message,
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() => '$runtimeType: $message';
}

/// Database related exceptions
class DatabaseException extends AppException {
  const DatabaseException({
    required super.message,
    super.originalError,
    super.stackTrace,
  });
}

/// Bluetooth/BLE related exceptions
class BluetoothException extends AppException {
  final BluetoothErrorType type;

  const BluetoothException({
    required super.message,
    required this.type,
    super.originalError,
    super.stackTrace,
  });
}

enum BluetoothErrorType {
  connectionFailed,
  connectionLost,
  deviceNotFound,
  permissionDenied,
  serviceNotFound,
  characteristicNotFound,
  timeout,
  unknown,
}

/// Firmware related exceptions
class FirmwareException extends AppException {
  final FirmwareErrorType type;

  const FirmwareException({
    required super.message,
    required this.type,
    super.originalError,
    super.stackTrace,
  });
}

enum FirmwareErrorType {
  downloadFailed,
  installationFailed,
  invalidFirmware,
  incompatibleVersion,
  checksumMismatch,
  unknown,
}

/// Network related exceptions
class NetworkException extends AppException {
  final int? statusCode;

  const NetworkException({
    required super.message,
    this.statusCode,
    super.originalError,
    super.stackTrace,
  });
}

/// Settings related exceptions
class SettingsException extends AppException {
  const SettingsException({
    required super.message,
    super.originalError,
    super.stackTrace,
  });
}

/// Cache related exceptions
class CacheException extends AppException {
  const CacheException({
    required super.message,
    super.originalError,
    super.stackTrace,
  });
}

/// Validation related exceptions
class ValidationException extends AppException {
  final String? field;

  const ValidationException({
    required super.message,
    this.field,
    super.originalError,
    super.stackTrace,
  });
}
