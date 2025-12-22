// lib/src/exceptions/dfu_exceptions.dart
import 'package:flutter/foundation.dart';

/// Exception de base pour toutes les erreurs DFU
abstract class DfuException implements Exception {
  final String message;

  DfuException(this.message);

  @override
  String toString() => 'DfuException: $message';

}

/// Exception générique DFU pour les cas non-spécifiques
class GenericDfuException extends DfuException {
  GenericDfuException(String message) : super(message);

  @override
  String toString() => 'DfuException: $message';
}

/// Exception de connexion BLE
class DfuConnectionException extends DfuException {
  final String? deviceId;
  final dynamic originalError;

  DfuConnectionException(
      String message, {
        this.deviceId,
        this.originalError,
      }) : super(message);

  @override
  String toString() => 'DfuConnectionException: $message' +
      (deviceId != null ? ' (Device: $deviceId)' : '') +
      (originalError != null ? '\nCause: $originalError' : '');
}

/// Exception de validation de firmware
class DfuValidationException extends DfuException {
  final List<String>? issues;

  DfuValidationException(
      String message, {
        this.issues,
      }) : super(message);

  @override
  String toString() {
    String str = 'DfuValidationException: $message';
    if (issues != null && issues!.isNotEmpty) {
      str += '\nProblèmes identifiés:\n';
      str += issues!.map((i) => '  - $i').join('\n');
    }
    return str;
  }
}

/// Exception de timeout
class DfuTimeoutException extends DfuException {
  final Duration timeout;
  final String operation;

  DfuTimeoutException(
      this.operation, {
        this.timeout = const Duration(seconds: 30),
      }) : super('Timeout après ${timeout.inSeconds}s lors de: $operation');

  @override
  String toString() => 'DfuTimeoutException: $message';
}

/// Exception du protocole DFU
class DfuProtocolException extends DfuException {
  final int? responseCode;
  final int? expectedCode;
  final List<int>? rawData;

  DfuProtocolException(
      String message, {
        this.responseCode,
        this.expectedCode,
        this.rawData,
      }) : super(message);

  String get responseDescription {
    switch (responseCode) {
      case 0x01:
        return 'Success';
      case 0x02:
        return 'Invalid State';
      case 0x03:
        return 'Not Supported';
      case 0x04:
        return 'Data Size Exceeds Limit';
      case 0x05:
        return 'CRC Error';
      case 0x06:
        return 'Operation Failed';
      default:
        return 'Unknown Response (0x${responseCode?.toRadixString(16).padLeft(2, '0').toUpperCase()})';
    }
  }

  @override
  String toString() => 'DfuProtocolException: $message\n' +
      'Response Code: $responseDescription ' +
      (expectedCode != null ? '(expected: 0x${expectedCode!.toRadixString(16)})' : '');
}

/// Exception de retry échouée
class DfuRetryException extends DfuException {
  final int attempts;
  final List<Exception> errors;

  DfuRetryException(
      String message, {
        required this.attempts,
        this.errors = const [],
      }) : super(message);

  @override
  String toString() {
    String str = 'DfuRetryException: $message (après $attempts tentatives)';
    if (errors.isNotEmpty) {
      str += '\nErreurs lors des tentatives:\n';
      for (int i = 0; i < errors.length; i++) {
        str += '  ${i + 1}. ${errors[i]}\n';
      }
    }
    return str;
  }
}

/// Exception de fichier/asset
class DfuFileException extends DfuException {
  final String? assetPath;
  final int? fileSize;

  DfuFileException(
      String message, {
        this.assetPath,
        this.fileSize,
      }) : super(message);

  @override
  String toString() => 'DfuFileException: $message' +
      (assetPath != null ? '\nAsset: $assetPath' : '') +
      (fileSize != null ? '\nTaille: $fileSize bytes' : '');
}

/// Exception d'état invalide
class DfuStateException extends DfuException {
  final String? currentState;
  final String? attemptedState;

  DfuStateException(
      String message, {
        this.currentState,
        this.attemptedState,
      }) : super(message);

  @override
  String toString() => 'DfuStateException: $message' +
      (currentState != null ? '\nÉtat actuel: $currentState' : '') +
      (attemptedState != null ? '\nÉtat demandé: $attemptedState' : '');
}

/// Exception de ressource
class DfuResourceException extends DfuException {
  final String resourceName;

  DfuResourceException(
      String message, {
        required this.resourceName,
      }) : super(message);

  @override
  String toString() => 'DfuResourceException: $message\n' +
      'Ressource: $resourceName';
}

/// Helper pour mapper les codes d'erreur DFU à des exceptions
DfuException createDfuException(
    dynamic error, {
      String? context,
    }) {
  if (error is DfuException) return error;

  final errorStr = error.toString().toLowerCase();

  if (errorStr.contains('timeout')) {
    return DfuTimeoutException(context ?? 'Unknown operation');
  }

  if (errorStr.contains('validation') || errorStr.contains('invalid')) {
    return DfuValidationException(
      context ?? 'Validation failed',
    );
  }

  if (errorStr.contains('connection') || errorStr.contains('disconnected')) {
    return DfuConnectionException(
      context ?? 'Connection error',
      originalError: error,
    );
  }

  if (errorStr.contains('file') || errorStr.contains('asset')) {
    return DfuFileException(
      context ?? 'File error',
    );
  }

  return GenericDfuException('${context ?? "DFU Error"}: $error');
}

/// Logger pour les exceptions DFU
void logDfuException(DfuException e, {String? prefix}) {
  if (kDebugMode) {
    final msg = '${prefix ?? "DFU Error"}: $e';
    print(msg);
  }
}