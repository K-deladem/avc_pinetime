import 'package:equatable/equatable.dart';

/// Base failure class for functional error handling
/// Use Failures for expected errors that should be handled gracefully
abstract class Failure extends Equatable {
  final String message;
  final dynamic originalError;

  const Failure({
    required this.message,
    this.originalError,
  });

  @override
  List<Object?> get props => [message, originalError];
}

/// Database operation failure
class DatabaseFailure extends Failure {
  const DatabaseFailure({
    required super.message,
    super.originalError,
  });
}

/// Bluetooth/BLE operation failure
class BluetoothFailure extends Failure {
  final BluetoothFailureType type;

  const BluetoothFailure({
    required super.message,
    required this.type,
    super.originalError,
  });

  @override
  List<Object?> get props => [message, type, originalError];
}

enum BluetoothFailureType {
  connectionFailed,
  connectionLost,
  deviceNotFound,
  permissionDenied,
  timeout,
  unknown,
}

/// Network operation failure
class NetworkFailure extends Failure {
  final int? statusCode;

  const NetworkFailure({
    required super.message,
    this.statusCode,
    super.originalError,
  });

  @override
  List<Object?> get props => [message, statusCode, originalError];
}

/// Firmware operation failure
class FirmwareFailure extends Failure {
  final FirmwareFailureType type;

  const FirmwareFailure({
    required super.message,
    required this.type,
    super.originalError,
  });

  @override
  List<Object?> get props => [message, type, originalError];
}

enum FirmwareFailureType {
  downloadFailed,
  installationFailed,
  invalidFirmware,
  incompatibleVersion,
  unknown,
}

/// Settings operation failure
class SettingsFailure extends Failure {
  const SettingsFailure({
    required super.message,
    super.originalError,
  });
}

/// Cache operation failure
class CacheFailure extends Failure {
  const CacheFailure({
    required super.message,
    super.originalError,
  });
}

/// Validation failure
class ValidationFailure extends Failure {
  final String? field;

  const ValidationFailure({
    required super.message,
    this.field,
    super.originalError,
  });

  @override
  List<Object?> get props => [message, field, originalError];
}

/// Unknown/unexpected failure
class UnknownFailure extends Failure {
  const UnknownFailure({
    super.message = 'An unexpected error occurred',
    super.originalError,
  });
}
