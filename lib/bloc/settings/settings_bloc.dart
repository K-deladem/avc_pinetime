import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app_template/bloc/settings/settings_event.dart';
import 'package:flutter_bloc_app_template/bloc/settings/settings_repository.dart';
import 'package:flutter_bloc_app_template/bloc/settings/settings_states.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsRepository repository;

  SettingsBloc(this.repository) : super(SettingsInitial()) {
    on<LoadSettings>(_onLoad);
    on<UpdateSettings>(_onUpdate);
  }

  // Gestion du chargement des paramètres
  Future<void> _onLoad(LoadSettings event, Emitter<SettingsState> emit) async {
    emit(SettingsLoading());

    try {
      final settings = await repository.fetchSettings();

      if (settings != null) {
        emit(SettingsLoaded(settings));
      } else {
        emit(SettingsError("Aucun paramètre trouvé dans la base de données."));
      }
    } catch (e) {
      emit(SettingsError("Erreur lors du chargement : $e"));
    }
  }

  // Gestion de la mise à jour des paramètres
  Future<void> _onUpdate(UpdateSettings event, Emitter<SettingsState> emit) async {
    await repository.saveSettings(event.settings);
    final updated = await repository.fetchSettings();
    if (updated != null) {
      emit(SettingsLoaded(updated));
    } else {
      emit(SettingsError('Impossible de recharger les paramètres après mise à jour'));
    }
  }

}