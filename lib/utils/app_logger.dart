/// Centralized logging service for the application
///
/// This service wraps the logger package to provide consistent logging
/// across the entire application. It replaces all print() statements
/// with proper logging levels (debug, info, warning, error).
library;

import 'package:logger/logger.dart';

/// Global logger instance
///
/// Usage:
/// ```dart
/// AppLogger.d('Debug message');
/// AppLogger.i('Info message');
/// AppLogger.w('Warning message');
/// AppLogger.e('Error message', error: e, stackTrace: st);
/// ```
class AppLogger {
  AppLogger._();

  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
    level: Level.debug,
  );

  /// Log a debug message
  ///
  /// Use for detailed diagnostic information useful during development.
  /// These logs should be disabled in production.
  static void d(
    dynamic message, {
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _logger.d(message, time: time, error: error, stackTrace: stackTrace);
  }

  /// Log an info message
  ///
  /// Use for general informational messages that highlight the progress
  /// of the application at a coarse-grained level.
  static void i(
    dynamic message, {
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _logger.i(message, time: time, error: error, stackTrace: stackTrace);
  }

  /// Log a warning message
  ///
  /// Use for potentially harmful situations that might cause issues
  /// but don't prevent the application from functioning.
  static void w(
    dynamic message, {
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _logger.w(message, time: time, error: error, stackTrace: stackTrace);
  }

  /// Log an error message
  ///
  /// Use for error events that might still allow the application
  /// to continue running.
  static void e(
    dynamic message, {
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _logger.e(message, time: time, error: error, stackTrace: stackTrace);
  }

  /// Log a fatal error message
  ///
  /// Use for very severe error events that will presumably lead the
  /// application to abort.
  static void f(
    dynamic message, {
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _logger.f(message, time: time, error: error, stackTrace: stackTrace);
  }

  /// Close the logger and release resources
  static void close() {
    _logger.close();
  }

  /// Configure logger level based on build mode
  ///
  /// Call this in main() to set appropriate log level:
  /// - Debug mode: Level.debug (all logs)
  /// - Release mode: Level.warning (only warnings and errors)
  static void configureForEnvironment({required bool isDebug}) {
    Logger.level = isDebug ? Level.debug : Level.warning;
  }
}
