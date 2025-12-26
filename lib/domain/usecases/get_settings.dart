import '../../models/app_settings.dart';
import '../repositories/settings_repository.dart';
import 'usecase.dart';

/// Use case for fetching app settings
///
/// Returns [AppSettings] or default settings if none exist
class GetSettings extends UseCase<AppSettings?, NoParams> {
  final SettingsRepository repository;

  GetSettings(this.repository);

  @override
  Future<AppSettings?> call(NoParams params) async {
    return await repository.fetchSettings();
  }
}
