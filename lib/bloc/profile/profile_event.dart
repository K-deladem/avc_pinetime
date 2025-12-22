part of 'profile_bloc.dart';


/// Classe abstraite représentant les événements de la page d'accueil
abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

/// Événement déclenché au démarrage de la page
class ProfileInitialEvent extends ProfileEvent {}

/// Événement déclenché lors du chargement des données
class ProfileLoadingEvent extends ProfileEvent {}

/// Événement déclenché quand les données sont chargées avec succès
class ProfileDataLoadedEvent extends ProfileEvent {
  final dynamic data; // Remplace `dynamic` par un modèle spécifique si possible

  const ProfileDataLoadedEvent(this.data);

  @override
  List<Object?> get props => [data];
}

/// Événement déclenché en cas d'erreur
class ProfileErrorEvent extends ProfileEvent {
  final String message;

  const ProfileErrorEvent(this.message);

  @override
  List<Object?> get props => [message];
}

/// Événement déclenché lorsqu'on rafraîchit la page
class ProfileRefreshEvent extends ProfileEvent {}