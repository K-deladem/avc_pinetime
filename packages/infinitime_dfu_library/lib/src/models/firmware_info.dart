// lib/src/models/firmware_info.dart

/// Informations détaillées sur un firmware
class FirmwareInfo {
  /// Chemin de l'asset
  final String assetPath;

  /// Nom du fichier
  final String fileName;

  /// Version du firmware
  final String version;

  /// Type de firmware (InfiniTime, PineTime, etc.)
  final String type;

  /// Taille en bytes
  final int sizeBytes;

  /// Format du fichier (ZIP, BIN, etc.)
  final String format;

  /// Est-ce que le firmware est valide
  final bool isValid;

  /// Liste des problèmes potentiels
  final List<String> issues;

  /// Notes additionnelles
  final String notes;

  /// Date d'ajout (optionnel)
  final DateTime? addedDate;

  /// Checksum SHA256 (optionnel)
  final String? sha256;

  /// Changelog (optionnel)
  final String? changelog;

  FirmwareInfo({
    required this.assetPath,
    required this.fileName,
    required this.version,
    this.type = 'InfiniTime',
    this.sizeBytes = 0,
    this.format = 'BIN',
    this.isValid = true,
    this.issues = const [],
    this.notes = '',
    this.addedDate,
    this.sha256,
    this.changelog,
  });

  /// Crée une instance à partir d'une map
  factory FirmwareInfo.fromMap(Map<String, dynamic> map) {
    return FirmwareInfo(
      assetPath: map['assetPath'] as String,
      fileName: map['fileName'] as String,
      version: map['version'] as String,
      type: map['type'] as String? ?? 'InfiniTime',
      sizeBytes: map['sizeBytes'] as int? ?? 0,
      format: map['format'] as String? ?? 'BIN',
      isValid: map['isValid'] as bool? ?? true,
      issues: List<String>.from(map['issues'] as List? ?? []),
      notes: map['notes'] as String? ?? '',
      addedDate:
          map['addedDate'] != null
              ? DateTime.parse(map['addedDate'] as String)
              : null,
      sha256: map['sha256'] as String?,
      changelog: map['changelog'] as String?,
    );
  }

  /// Convertit l'instance en map
  Map<String, dynamic> toMap() {
    return {
      'assetPath': assetPath,
      'fileName': fileName,
      'version': version,
      'type': type,
      'sizeBytes': sizeBytes,
      'format': format,
      'isValid': isValid,
      'issues': issues,
      'notes': notes,
      'addedDate': addedDate?.toIso8601String(),
      'sha256': sha256,
      'changelog': changelog,
    };
  }

  /// Obtient la taille formatée
  String get formattedSize {
    if (sizeBytes < 1024) {
      return '$sizeBytes B';
    } else if (sizeBytes < 1024 * 1024) {
      return '${(sizeBytes / 1024).toStringAsFixed(2)} KB';
    } else {
      return '${(sizeBytes / 1024 / 1024).toStringAsFixed(2)} MB';
    }
  }

  /// Obtient la description courte
  String get shortDescription => '$type v$version ($formattedSize)';

  /// Obtient la description longue
  String get longDescription {
    return '''
    Firmware: $shortDescription
    File: $fileName
    Format: $format
    Valid: $isValid
    Issues: ${issues.join(', ')}
    Notes: $notes
    ''';
  }

  @override
  String toString() => shortDescription;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FirmwareInfo &&
          runtimeType == other.runtimeType &&
          assetPath == other.assetPath &&
          version == other.version;

  @override
  int get hashCode => assetPath.hashCode ^ version.hashCode;
}
