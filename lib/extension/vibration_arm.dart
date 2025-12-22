enum VibrationArm { left, right, both }

extension VibrationArmExtension on VibrationArm {
  String get label {
    switch (this) {
      case VibrationArm.left:
        return 'Gauche';
      case VibrationArm.right:
        return 'Droit';
      case VibrationArm.both:
        return 'Les deux';
    }
  }

  static VibrationArm fromLabel(String label) {
    return VibrationArm.values.firstWhere((e) => e.label == label);
  }
}