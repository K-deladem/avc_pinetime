part of 'profile_bloc.dart';

/// Classe abstraite représentant les états de la page d'accueil
abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

/// État initial (au démarrage de l'application)
class ProfileInitialState extends ProfileState {}

/// État lorsque les données sont en cours de chargement
class ProfileLoadingState extends ProfileState {}

/// État lorsque les données sont chargées avec succès
class ProfileLoadedState extends ProfileState {
  final dynamic data; // Remplace `dynamic` par ton modèle de données spécifique

  const ProfileLoadedState(this.data);

  @override
  List<Object?> get props => [data];
}

/// État lorsque la page est en train de se rafraîchir
class ProfileRefreshingState extends ProfileState {}

/// État en cas d'erreur
class ProfileErrorState extends ProfileState {
  final String message;

  const ProfileErrorState(this.message);

  @override
  List<Object?> get props => [message];
}
