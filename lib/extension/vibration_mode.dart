enum VibrationMode { short, long, doubleShort, continuous, custom }

extension VibrationModeExtension on VibrationMode {
  String get label {
    switch (this) {
      case VibrationMode.short:
        return 'Courte';
      case VibrationMode.long:
        return 'Longue';
      case VibrationMode.doubleShort:
        return 'Double courte';
      case VibrationMode.continuous:
        return 'Continue';
      case VibrationMode.custom:
        return 'Custom';
    }
  }

  static VibrationMode fromLabel(String label) {
    return VibrationMode.values.firstWhere((e) => e.label == label);
  }
}
