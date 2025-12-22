import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc() : super(ProfileInitialState()) {
    // Gestion de l'événement de chargement initial
    on<ProfileInitialEvent>((event, emit) async {
      emit(ProfileLoadingState());
      await Future.delayed(const Duration(seconds: 2)); // Simulation d'un chargement
      emit(const ProfileLoadedState(["Article 1", "Article 2", "Article 3"])); // Ex de données
    });

    // Gestion de l'événement de chargement manuel
    on<ProfileLoadingEvent>((event, emit) async {
      emit(ProfileLoadingState());
      await Future.delayed(const Duration(seconds: 2));
      emit(const ProfileLoadedState(["Données mises à jour"]));
    });

    // Gestion de l'événement de données chargées
    on<ProfileDataLoadedEvent>((event, emit) {
      emit(ProfileLoadedState(event.data));
    });

    // Gestion de l'événement d'erreur
    on<ProfileErrorEvent>((event, emit) {
      emit(ProfileErrorState(event.message));
    });

    // Gestion du rafraîchissement
    on<ProfileRefreshEvent>((event, emit) async {
      emit(ProfileRefreshingState());
      await Future.delayed(const Duration(seconds: 1)); // Simulation d'un refresh
      emit(const ProfileLoadedState(["Article 1", "Article 2", "Article 3"])); // Recharge les données
    });
  }
}


