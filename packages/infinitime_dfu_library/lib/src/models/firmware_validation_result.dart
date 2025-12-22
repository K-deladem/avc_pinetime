// lib/src/models/firmware_validation_result.dart

/// Résultat de la validation d'un firmware
class FirmwareValidationResult {
  /// Est-ce que le firmware est valide
  bool isValid;

  /// Chemin de l'asset
  final String assetPath;

  /// Taille en bytes
  final int sizeBytes;

  /// Liste des problèmes ou avertissements
  List<String> issues;

  /// Format du firmware
  String? format;

  /// Détails supplémentaires
  Map<String, dynamic> metadata;

  FirmwareValidationResult({
    required this.isValid,
    required this.assetPath,
    required this.sizeBytes,
    required this.issues,
    this.format,
    Map<String, dynamic>? metadata,
  }) : metadata = metadata ?? {};

  /// Crée une instance à partir d'une map
  factory FirmwareValidationResult.fromMap(Map<String, dynamic> map) {
    return FirmwareValidationResult(
      isValid: map['isValid'] as bool,
      assetPath: map['assetPath'] as String,
      sizeBytes: map['sizeBytes'] as int,
      issues: List<String>.from(map['issues'] as List),
      format: map['format'] as String?,
      metadata: map['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Convertit l'instance en map
  Map<String, dynamic> toMap() {
    return {
      'isValid': isValid,
      'assetPath': assetPath,
      'sizeBytes': sizeBytes,
      'issues': issues,
      'format': format,
      'metadata': metadata,
    };
  }

  /// Ajoute une issue
  void addIssue(String issue) {
    if (!issues.contains(issue)) {
      issues.add(issue);
    }
  }

  /// Obtient les erreurs critiques
  List<String> get criticalIssues {
    return issues.where((i) => i.contains('ERROR') || i.contains('Erreur')).toList();
  }

  /// Obtient les avertissements
  List<String> get warnings {
    return issues.where((i) => !i.contains('ERROR') && !i.contains('Erreur')).toList();
  }

  /// Résumé de la validation
  String get summary {
    if (isValid) {
      return 'Firmware valide (${issues.length} avertissements)';
    } else {
      return 'Firmware invalide (${criticalIssues.length} erreurs)';
    }
  }

  @override
  String toString() => summary;
}
