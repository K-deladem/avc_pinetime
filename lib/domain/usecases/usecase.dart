import 'package:equatable/equatable.dart';

/// Base class for all use cases
///
/// Use cases encapsulate a single piece of business logic.
/// They take parameters [Params] and return a result [Type].
///
/// Example:
/// ```dart
/// class GetSettings extends UseCase<AppSettings, NoParams> {
///   final SettingsRepository repository;
///
///   GetSettings(this.repository);
///
///   @override
///   Future<AppSettings> call(NoParams params) async {
///     return await repository.fetchSettings();
///   }
/// }
/// ```
abstract class UseCase<T, Params> {
  Future<T> call(Params params);
}

/// Use this class when use case doesn't need any parameters
class NoParams extends Equatable {
  const NoParams();

  @override
  List<Object?> get props => [];
}
