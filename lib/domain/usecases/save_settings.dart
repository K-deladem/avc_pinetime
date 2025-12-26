import 'package:equatable/equatable.dart';

import '../../models/app_settings.dart';
import '../repositories/settings_repository.dart';
import 'usecase.dart';

/// Use case for saving app settings
class SaveSettings extends UseCase<void, SaveSettingsParams> {
  final SettingsRepository repository;

  SaveSettings(this.repository);

  @override
  Future<void> call(SaveSettingsParams params) async {
    await repository.saveSettings(params.settings);
  }
}

/// Parameters for [SaveSettings] use case
class SaveSettingsParams extends Equatable {
  final AppSettings settings;

  const SaveSettingsParams({required this.settings});

  @override
  List<Object?> get props => [settings];
}
