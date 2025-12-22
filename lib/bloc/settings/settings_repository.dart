// settings_repository.dart
import 'package:flutter_bloc_app_template/app/app_database.dart';
import 'package:flutter_bloc_app_template/models/app_settings.dart';

abstract class SettingsRepository {
  Future<AppSettings?> fetchSettings();
  Future<void> saveSettings(AppSettings settings);
}

class SettingsRepositoryImpl implements SettingsRepository {
  final AppDatabase _db = AppDatabase.instance;

  @override
  Future<AppSettings?> fetchSettings() async {
    try {
      // Ajouter un timeout pour éviter le blocage
      return await _db.fetchSettings().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          print('Timeout lors du chargement des settings, utilisation des valeurs par défaut');
          return AppDatabase.defaultSettings;
        },
      );
    } catch (e) {
      print('Erreur lors du fetchSettings: $e');
      // En cas d'erreur, retourner les paramètres par défaut
      return AppDatabase.defaultSettings;
    }
  }

  @override
  Future<void> saveSettings(AppSettings settings) async {
    try {
      await _db.saveSettings(settings).timeout(
        const Duration(seconds: 5),
      );
    } catch (e) {
      print('Erreur lors du saveSettings: $e');
      rethrow;
    }
  }
}
