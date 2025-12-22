enum ArmSide { none ,left, right }


extension ArmSideExtension on ArmSide {
  String get label {
    switch (this) {
      case ArmSide.none:
        return 'Aucun';
      case ArmSide.left:
        return 'Gauche';
      case ArmSide.right:
        return 'Droite';
    }
  }

  /// Retourne le nom technique utilisé dans la base de données ('left', 'right', 'none')
  String get technicalName {
    switch (this) {
      case ArmSide.none:
        return 'none';
      case ArmSide.left:
        return 'left';
      case ArmSide.right:
        return 'right';
    }
  }

  /// Retourne le label court pour l'affichage ('G', 'D', '-')
  String get shortLabel {
    switch (this) {
      case ArmSide.none:
        return '-';
      case ArmSide.left:
        return 'G';
      case ArmSide.right:
        return 'D';
    }
  }

  static ArmSide fromLabel(String label) {
    return ArmSide.values.firstWhere((e) => e.label == label);
  }

  static ArmSide fromTechnicalName(String name) {
    switch (name.toLowerCase()) {
      case 'left':
        return ArmSide.left;
      case 'right':
        return ArmSide.right;
      case 'none':
      default:
        return ArmSide.none;
    }
  }
}