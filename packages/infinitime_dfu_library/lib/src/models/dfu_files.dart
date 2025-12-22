import 'package:flutter/foundation.dart';

/// Classe contenant les fichiers nécessaires pour une mise à jour DFU
class DfuFiles {
  /// Données du firmware (.bin)
  final Uint8List firmware;

  /// Données du paquet d'initialisation (.dat)
  final Uint8List initPacket;

  /// Taille totale en bytes
  late final int totalSize;

  /// Chemin du fichier firmware source (optionnel)
  /// Exemple: 'assets/firmware/latest.dfu' ou '/sdcard/firmware.dfu'
  late final String? path;

  DfuFiles({
    required this.firmware,
    required this.initPacket,
    required this.path,
  }) {
    totalSize = firmware.length + initPacket.length;
  }

  /// Crée une instance à partir d'une map (utile pour la sérialisation)
  factory DfuFiles.fromMap(Map<String, dynamic> map) {
    return DfuFiles(
      firmware: map['firmware'] as Uint8List,
      initPacket: map['initPacket'] as Uint8List,
      path: map['path'] as String?,
    );
  }

  /// Convertit l'instance en map
  Map<String, dynamic> toMap() {
    return {
      'firmware': firmware,
      'initPacket': initPacket,
      'totalSize': totalSize,
      'path': path,
    };
  }

  /// Validation basique des fichiers
  bool validate() {
    if (firmware.isEmpty || initPacket.isEmpty) {
      debugPrint('[DFU] Validation échouée: fichier vide');
      return false;
    }
    if (firmware.length < 1024) {
      debugPrint('[DFU] Validation échouée: firmware trop petit (${firmware.length} bytes)');
      return false; // Firmware trop petit
    }
    if (firmware.length > 10 * 1024 * 1024) {
      debugPrint('[DFU] Validation échouée: firmware trop grand (${(firmware.length / 1024 / 1024).toStringAsFixed(2)}MB)');
      return false; // Firmware trop grand (>10MB)
    }
    debugPrint('[DFU] Validation OK: firmware=${(firmware.length / 1024).toStringAsFixed(1)}KB, init=${(initPacket.length / 1024).toStringAsFixed(1)}KB');
    return true;
  }

  /// Obtient une description textuelle
  String getDescription() {
    final pathInfo = path != null ? ' (from: $path)' : '';
    return 'DFU Files: firmware=${(firmware.length / 1024).toStringAsFixed(1)}KB, init=${(initPacket.length / 1024).toStringAsFixed(1)}KB, total=${(totalSize / 1024).toStringAsFixed(1)}KB$pathInfo';
  }

  /// Obtient le nom du fichier source (s'il existe)
  String? getFileName() {
    if (path == null) return null;

    // Extraire le nom du fichier du chemin
    final lastSlash = path!.lastIndexOf('/');
    if (lastSlash == -1) {
      return path; // Pas de slash, c'est déjà un nom
    }
    return path!.substring(lastSlash + 1);
  }

  /// Obtient le répertoire du fichier source (s'il existe)
  String? getDirectory() {
    if (path == null) return null;

    final lastSlash = path!.lastIndexOf('/');
    if (lastSlash == -1) {
      return null; // Pas de répertoire
    }
    return path!.substring(0, lastSlash);
  }

  /// Obtient la taille en format lisible
  String getSizeReadable() {
    if (totalSize < 1024) {
      return '${totalSize}B';
    } else if (totalSize < 1024 * 1024) {
      return '${(totalSize / 1024).toStringAsFixed(2)}KB';
    } else {
      return '${(totalSize / 1024 / 1024).toStringAsFixed(2)}MB';
    }
  }

  /// Obtient la taille du firmware en format lisible
  String getFirmwareSizeReadable() {
    if (firmware.length < 1024) {
      return '${firmware.length}B';
    } else if (firmware.length < 1024 * 1024) {
      return '${(firmware.length / 1024).toStringAsFixed(2)}KB';
    } else {
      return '${(firmware.length / 1024 / 1024).toStringAsFixed(2)}MB';
    }
  }

  /// Obtient la taille du packet d'initialisation en format lisible
  String getInitPacketSizeReadable() {
    if (initPacket.length < 1024) {
      return '${initPacket.length}B';
    } else if (initPacket.length < 1024 * 1024) {
      return '${(initPacket.length / 1024).toStringAsFixed(2)}KB';
    } else {
      return '${(initPacket.length / 1024 / 1024).toStringAsFixed(2)}MB';
    }
  }

  /// Obtient un rapport détaillé du fichier
  String getDetailedReport() {
    final buffer = StringBuffer();
    buffer.writeln('═══════════════════════════════════════════');
    buffer.writeln('DFU FILES REPORT');
    buffer.writeln('═══════════════════════════════════════════');

    if (path != null) {
      buffer.writeln('Path: $path');
      buffer.writeln('File Name: ${getFileName()}');
      if (getDirectory() != null) {
        buffer.writeln('Directory: ${getDirectory()}');
      }
      buffer.writeln('───────────────────────────────────────────');
    }

    buffer.writeln('Firmware Size: ${getFirmwareSizeReadable()} (${firmware.length} bytes)');
    buffer.writeln('Init Packet Size: ${getInitPacketSizeReadable()} (${initPacket.length} bytes)');
    buffer.writeln('Total Size: ${getSizeReadable()} (${totalSize} bytes)');
    buffer.writeln('───────────────────────────────────────────');

    final isValid = validate();
    buffer.writeln('Validation Status: ${isValid ? 'VALID' : 'INVALID'}');
    buffer.writeln('═══════════════════════════════════════════');

    return buffer.toString();
  }

  /// Comparaison d'égalité
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DfuFiles &&
        listEquals(other.firmware, firmware) &&
        listEquals(other.initPacket, initPacket) &&
        other.path == path;
  }

  @override
  int get hashCode => Object.hash(firmware, initPacket, path);

  @override
  String toString() => getDescription();
}