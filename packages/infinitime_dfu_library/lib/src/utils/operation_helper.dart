// lib/src/utils/operation_helper.dart
import 'package:flutter/foundation.dart';

import '../exceptions/dfu_exceptions.dart';

/// Helper pour gérer les opérations avec timeout et retry
class OperationHelper {
  static const Duration defaultTimeout = Duration(seconds: 30);
  static const int defaultMaxRetries = 3;
  static const Duration defaultRetryDelay = Duration(milliseconds: 500);

  /// Exécute une opération avec timeout
  ///
  /// Exemple:
  /// ```dart
  /// await OperationHelper.withTimeout(
  ///   () => ble.writeCharacteristic(...),
  ///   operationName: 'Write DFU Control',
  ///   timeout: Duration(seconds: 10),
  /// );
  /// ```
  static Future<T> withTimeout<T>(
    Future<T> Function() operation, {
    required String operationName,
    Duration timeout = defaultTimeout,
  }) async {
    try {
      return await operation().timeout(
        timeout,
        onTimeout: () {
          throw DfuTimeoutException(operationName, timeout: timeout);
        },
      );
    } catch (e) {
      if (e is DfuTimeoutException) rethrow;
      rethrow;
    }
  }

  /// Exécute une opération avec retry automatique et backoff exponentiel
  ///
  /// Exemple:
  /// ```dart
  /// await OperationHelper.withRetry(
  ///   () => sendFirmwareData(chunk),
  ///   operationName: 'Send firmware chunk',
  ///   maxRetries: 5,
  /// );
  /// ```
  static Future<T> withRetry<T>(
    Future<T> Function() operation, {
    required String operationName,
    int maxRetries = defaultMaxRetries,
    Duration initialDelay = defaultRetryDelay,
  }) async {
    final errors = <Exception>[];

    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        if (kDebugMode && attempt > 1) {
          print('[$operationName] Tentative $attempt/$maxRetries');
        }
        return await operation();
      } catch (e) {
        final exception = e is Exception ? e : Exception(e.toString());
        errors.add(exception);

        if (attempt >= maxRetries) {
          throw DfuRetryException(
            'Opération échouée après $maxRetries tentatives: $operationName',
            attempts: attempt,
            errors: errors,
          );
        }

        // Backoff exponentiel: 500ms, 1s, 2s, 4s...
        final delayMs = initialDelay.inMilliseconds * (1 << (attempt - 1));
        await Future.delayed(Duration(milliseconds: delayMs));
      }
    }

    throw DfuRetryException(
      'Retry failed',
      attempts: maxRetries,
      errors: errors,
    );
  }

  /// Combine timeout et retry
  ///
  /// Exemple:
  /// ```dart
  /// await OperationHelper.withTimeoutAndRetry(
  ///   () => ble.subscribeToCharacteristic(...),
  ///   operationName: 'Subscribe to DFU notifications',
  ///   timeout: Duration(seconds: 15),
  ///   maxRetries: 3,
  /// );
  /// ```
  static Future<T> withTimeoutAndRetry<T>(
    Future<T> Function() operation, {
    required String operationName,
    Duration timeout = defaultTimeout,
    int maxRetries = defaultMaxRetries,
    Duration retryDelay = defaultRetryDelay,
  }) async {
    return withRetry(
      () => withTimeout(
        operation,
        operationName: operationName,
        timeout: timeout,
      ),
      operationName: operationName,
      maxRetries: maxRetries,
      initialDelay: retryDelay,
    );
  }

  /// Exécute une opération avec callback de progression
  ///
  /// Utile pour les opérations longues
  static Future<T> withProgress<T>(
    Future<T> Function(Function(double) onProgress) operation, {
    required String operationName,
    Duration timeout = defaultTimeout,
  }) async {
    try {
      return await withTimeout(
        () => operation((progress) {
          if (kDebugMode) {
            final percent = (progress * 100).toStringAsFixed(1);
            print('[$operationName] Progression: $percent%');
          }
        }),
        operationName: operationName,
        timeout: timeout,
      );
    } catch (e) {
      if (e is DfuException) rethrow;
      throw createDfuException(
        e,
        context: 'Progress operation: $operationName',
      );
    }
  }

  /// Exécute une série d'opérations séquentielles avec timeouts individuels
  ///
  /// Exemple:
  /// ```dart
  /// await OperationHelper.sequence([
  ///   ('Initialize', () => dfu.initialize()),
  ///   ('Send Data', () => dfu.sendData(data)),
  ///   ('Validate', () => dfu.validate()),
  /// ]);
  /// ```
  static Future<List<T>> sequence<T>(
    List<(String name, Future<T> Function() operation)> operations, {
    Duration timeout = defaultTimeout,
  }) async {
    final results = <T>[];

    for (final (name, operation) in operations) {
      try {
        final result = await withTimeout(
          operation,
          operationName: name,
          timeout: timeout,
        );
        results.add(result);
      } catch (e) {
        if (e is DfuException) rethrow;
        throw createDfuException(e, context: 'Sequential operation: $name');
      }
    }

    return results;
  }

  /// Exécute une opération avec gestion complète d'erreurs
  static Future<T> safe<T>(
    Future<T> Function() operation, {
    required String operationName,
    T Function(DfuException e)? onError,
    Duration timeout = defaultTimeout,
    int maxRetries = defaultMaxRetries,
  }) async {
    try {
      return await withTimeoutAndRetry(
        operation,
        operationName: operationName,
        timeout: timeout,
        maxRetries: maxRetries,
      );
    } on DfuException catch (e) {
      if (onError != null) {
        return onError(e);
      }
      rethrow;
    }
  }

  /// Enveloppe une opération avec des callbacks de lifecyle
  static Future<T> withLifecycle<T>(
    Future<T> Function() operation, {
    required String operationName,
    VoidCallback? onStart,
    VoidCallback? onSuccess,
    Function(DfuException)? onError,
    VoidCallback? onFinally,
    Duration timeout = defaultTimeout,
  }) async {
    try {
      onStart?.call();
      final result = await withTimeout(
        operation,
        operationName: operationName,
        timeout: timeout,
      );
      onSuccess?.call();
      return result;
    } on DfuException catch (e) {
      onError?.call(e);
      rethrow;
    } finally {
      onFinally?.call();
    }
  }

  /// Crée un circuit breaker pour éviter les appels répétés en cas d'erreur
  static CircuitBreaker createCircuitBreaker({
    Duration resetTimeout = const Duration(seconds: 60),
  }) {
    return CircuitBreaker(resetTimeout: resetTimeout);
  }
}

enum State { closed, open, halfOpen }

/// Pattern Circuit Breaker pour éviter les cascades d'erreurs
class CircuitBreaker {
  State _state = State.closed;
  int _failureCount = 0;
  DateTime? _lastFailureTime;
  final Duration resetTimeout;

  State get state => _state;

  bool get isOpen => _state == State.open;

  CircuitBreaker({required this.resetTimeout});

  /// Enveloppe une opération avec circuit breaker
  Future<T> call<T>(
    Future<T> Function() operation, {
    required String operationName,
    int failureThreshold = 3,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    // Si open et timeout écoulé, passer en half-open
    if (_state == State.open) {
      final now = DateTime.now();
      if (_lastFailureTime != null &&
          now.difference(_lastFailureTime!).compareTo(resetTimeout) > 0) {
        _state = State.halfOpen;
        if (kDebugMode) {
          print('[CircuitBreaker] Passage en HALF_OPEN pour: $operationName');
        }
      } else {
        throw DfuStateException(
          'Circuit breaker ouvert pour: $operationName',
          currentState: 'OPEN',
        );
      }
    }

    try {
      final result = await OperationHelper.withTimeout(
        operation,
        operationName: operationName,
        timeout: timeout,
      );

      // Réinitialiser en cas de succès
      if (_state == State.halfOpen) {
        _state = State.closed;
        _failureCount = 0;
        if (kDebugMode) {
          print('[CircuitBreaker] Retour à CLOSED pour: $operationName');
        }
      }

      return result;
    } catch (e) {
      _failureCount++;
      _lastFailureTime = DateTime.now();

      if (_failureCount >= failureThreshold) {
        _state = State.open;
        if (kDebugMode) {
          print(
            '[CircuitBreaker] Ouverture du circuit (${_failureCount} erreurs)',
          );
        }
      }

      rethrow;
    }
  }

  void reset() {
    _state = State.closed;
    _failureCount = 0;
    _lastFailureTime = null;
  }
}
