// lib/models/final/pinetime/arm_side_extensions.dart
import 'package:flutter_bloc_app_template/models/arm_side.dart';

extension ArmSideExt on ArmSide {
  /// Clé pour sauvegarder l'ID du device dans SharedPreferences
  String get deviceKey => this == ArmSide.left
      ? 'arm_left_device_id'
      : 'arm_right_device_id';

  /// Clé pour sauvegarder la dernière synchronisation dans SharedPreferences
  String get syncKey => this == ArmSide.left
      ? 'arm_left_last_sync'
      : 'arm_right_last_sync';

  /// Nom d'affichage pour l'utilisateur
  String get displayName => this == ArmSide.left ? 'gauche' : 'droite';

  /// Côté opposé
  ArmSide get opposite => this == ArmSide.left ? ArmSide.right : ArmSide.left;
}