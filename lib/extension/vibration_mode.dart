/// Modes de vibration simplifiés
/// - short: 1 vibration (simple)
/// - doubleShort: 2 vibrations (double)
/// - custom: N vibrations définies par l'utilisateur
/// - long, continuous: obsolètes, traités comme 'short'
enum VibrationMode { short, long, doubleShort, continuous, custom }

extension VibrationModeExtension on VibrationMode {
  String get label {
    switch (this) {
      case VibrationMode.short:
        return 'Simple';
      case VibrationMode.doubleShort:
        return 'Double';
      case VibrationMode.custom:
        return 'Personnalisé';
      // Modes obsolètes - gardés pour compatibilité DB
      case VibrationMode.long:
      case VibrationMode.continuous:
        return 'Simple';
    }
  }

  /// Retourne les modes disponibles dans l'UI (sans les obsolètes)
  static List<VibrationMode> get availableModes => [
    VibrationMode.short,
    VibrationMode.doubleShort,
    VibrationMode.custom,
  ];

  static VibrationMode fromLabel(String label) {
    switch (label) {
      case 'Simple':
        return VibrationMode.short;
      case 'Double':
        return VibrationMode.doubleShort;
      case 'Personnalisé':
        return VibrationMode.custom;
      default:
        return VibrationMode.short;
    }
  }
}
