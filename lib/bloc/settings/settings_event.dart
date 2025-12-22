import 'package:flutter_bloc_app_template/models/app_settings.dart';

sealed class SettingsEvent {}

class LoadSettings extends SettingsEvent {}

class AppResetRequested extends SettingsEvent {}

class UpdateSettings extends SettingsEvent {
  final AppSettings settings;
  UpdateSettings(this.settings);
}