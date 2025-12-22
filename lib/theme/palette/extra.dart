import 'package:flutter/cupertino.dart';

/// ------------------------------
/// Valeurs complémentaires pour la gestion des surfaces et contrastes
/// (pour chaque thème et selon la luminosité)
/// ------------------------------
class Extras {
  final Color surface;
  final Color onSurface;
  final Color surfaceContainerHighest;
  final Color onSurfaceVariant;
  final Color onInverseSurface;
  final Color inverseSurface;
  final Color inversePrimary;
  final Color shadow;
  final Color outlineVariant;
  final Color scrim;

  const Extras({
    required this.surface,
    required this.onSurface,
    required this.surfaceContainerHighest,
    required this.onSurfaceVariant,
    required this.onInverseSurface,
    required this.inverseSurface,
    required this.inversePrimary,
    required this.shadow,
    required this.outlineVariant,
    required this.scrim,
  });
}
