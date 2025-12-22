// lib/src/services/firmware_manager.dart
import 'dart:async';

import 'package:archive/archive.dart';
import 'package:flutter/services.dart';
import 'package:infinitime_dfu_library/src/exceptions/dfu_exceptions.dart';
import 'package:infinitime_dfu_library/src/utils/operation_helper.dart';

import '../models/dfu_files.dart';
import '../models/firmware_info.dart';
import '../models/firmware_validation_result.dart';

/// Delegate pour la source des firmwares
/// Doit être implémenté par l'application
abstract class FirmwareSourceDelegate {
  /// Retourne la liste des assets firmware disponibles
  /// Exemple: ['assets/firmware/infinitime-1.14.0.zip', ...]
  Future<List<String>> getAvailableFirmwares();

  /// Retourne les informations détaillées d'un firmware
  /// Peut être surchargé pour ajouter des métadonnées custom
  FirmwareInfo? getFirmwareInfo(String assetPath) => null;

  /// Callback après chaque firmware chargé
  void onFirmwareLoaded(FirmwareInfo info) {}

  /// Callback en cas d'erreur
  void onFirmwareError(String assetPath, String error) {}
}

/// Service de gestion des firmware
class FirmwareManager {
  final FirmwareSourceDelegate _delegate;
  final Map<String, FirmwareInfo> _cache = {};
  final Map<String, DfuFiles> _dfuFilesCache = {};

  FirmwareManager(this._delegate);

  /// Charge la liste des firmwares disponibles
  Future<List<FirmwareInfo>> loadAvailableFirmwares() async {
    try {
      final assetPaths = await _delegate.getAvailableFirmwares();
      final firmwares = <FirmwareInfo>[];

      for (final assetPath in assetPaths) {
        try {
          final info = await getFirmwareInfo(assetPath);
          if (info != null) {
            firmwares.add(info);
            _delegate.onFirmwareLoaded(info);
          }
        } catch (e) {
          _delegate.onFirmwareError(assetPath, e.toString());
        }
      }

      // Trier par version (plus récent en premier)
      firmwares.sort((a, b) => _compareVersions(b.version, a.version));

      return firmwares;
    } catch (e) {
      throw Exception('Erreur chargement liste firmwares: $e');
    }
  }

  /// Obtient les informations d'un firmware spécifique
  Future<FirmwareInfo?> getFirmwareInfo(String assetPath) async {
    // Vérifier le cache
    if (_cache.containsKey(assetPath)) {
      return _cache[assetPath];
    }

    try {
      final validation = await OperationHelper.withTimeout(
        () => validateFirmwareAsset(assetPath),
        operationName: 'Validate firmware asset: $assetPath',
        timeout: Duration(seconds: 30),
      );

      if (!validation.isValid) {
        throw DfuValidationException(
          'Firmware validation failed',
          issues: validation.issues,
        );
      }

      final fileName = assetPath.split('/').last;
      String version = _extractVersion(fileName);
      String type = _detectFirmwareType(fileName);

      final info = FirmwareInfo(
        assetPath: assetPath,
        fileName: fileName,
        version: version,
        type: type,
        sizeBytes: validation.sizeBytes,
        format: validation.format ?? 'UNKNOWN',
        isValid: validation.isValid,
        issues: validation.issues,
        notes: _generateNotes(validation),
      );

      _cache[assetPath] = info;
      return info;
    } on DfuValidationException {
      rethrow; // Propager les erreurs de validation
    } catch (e) {
      throw DfuFileException(
        'Failed to get firmware info',
        assetPath: assetPath,
      );
    }
  }

  /// Valide un firmware asset
  Future<FirmwareValidationResult> validateFirmwareAsset(
    String assetPath,
  ) async {
    try {
      final ByteData assetData = await rootBundle.load(assetPath);
      final Uint8List rawData = assetData.buffer.asUint8List(
        assetData.offsetInBytes,
        assetData.lengthInBytes,
      );

      if (rawData.isEmpty) {
        return FirmwareValidationResult(
          isValid: false,
          assetPath: assetPath,
          sizeBytes: 0,
          issues: ['Asset firmware vide'],
        );
      }

      late Uint8List firmwareBytes;
      String? format;

      // Déterminer le format et extraire si nécessaire
      if (assetPath.toLowerCase().endsWith('.zip')) {
        format = 'ZIP (BIN extrait)';
        try {
          firmwareBytes = _extractBinFromZip(rawData, assetPath);
        } catch (e) {
          return FirmwareValidationResult(
            isValid: false,
            assetPath: assetPath,
            sizeBytes: 0,
            issues: ['Erreur extraction ZIP: $e'],
            format: 'ZIP',
          );
        }
      } else if (assetPath.toLowerCase().endsWith('.bin')) {
        format = 'BIN';
        firmwareBytes = rawData;
      } else {
        return FirmwareValidationResult(
          isValid: false,
          assetPath: assetPath,
          sizeBytes: 0,
          issues: ['Format non supporté'],
        );
      }

      // Validations de base
      final result = FirmwareValidationResult(
        isValid: true,
        assetPath: assetPath,
        sizeBytes: firmwareBytes.length,
        issues: [],
        format: format,
      );

      if (firmwareBytes.isEmpty) {
        result.addIssue('ERROR: Firmware vide');
        result.isValid = false;
      }

      if (firmwareBytes.length < 1024) {
        result.addIssue(
          'ERROR: Firmware trop petit (${firmwareBytes.length} bytes)',
        );
        result.isValid = false;
      }

      if (firmwareBytes.length > 20 * 1024 * 1024) {
        result.addIssue(
          'ERROR: Firmware trop volumineux (${firmwareBytes.length} bytes)',
        );
        result.isValid = false;
      }

      // Vérifier le magic number
      if (firmwareBytes.length >= 4) {
        final magicNumber =
            (firmwareBytes[3] << 24) |
            (firmwareBytes[2] << 16) |
            (firmwareBytes[1] << 8) |
            firmwareBytes[0];

        if (magicNumber == 0x96F3B83D || magicNumber == 0x96F3B83C) {
          result.addIssue('Magic number MCUBoot valide');
        } else {
          result.addIssue(
            'Magic: 0x${magicNumber.toRadixString(16).toUpperCase()}',
          );
        }
      }

      // Vérifier la taille pour InfiniTime
      if (firmwareBytes.length > 100 * 1024 &&
          firmwareBytes.length < 2 * 1024 * 1024) {
        result.addIssue('Taille compatible InfiniTime/PineTime');
      }

      return result;
    } catch (e) {
      return FirmwareValidationResult(
        isValid: false,
        assetPath: assetPath,
        sizeBytes: 0,
        issues: ['Erreur validation: $e'],
      );
    }
  }

  /// Charge un firmware et retourne les fichiers DFU
  Future<DfuFiles> loadFirmwareFiles(String assetPath) async {
    // Vérifier le cache
    if (_dfuFilesCache.containsKey(assetPath)) {
      return _dfuFilesCache[assetPath]!;
    }

    try {
      final ByteData assetData = await rootBundle.load(assetPath);
      final Uint8List zipBytes = assetData.buffer.asUint8List(
        assetData.offsetInBytes,
        assetData.lengthInBytes,
      );

      final archive = ZipDecoder().decodeBytes(zipBytes);

      ArchiveFile? binFile;
      ArchiveFile? datFile;

      for (final file in archive) {
        if (file.name.startsWith('__MACOSX/') || file.name.startsWith('._')) {
          continue;
        }

        if (file.name.endsWith('.bin') && file.isFile) {
          if (binFile == null ||
              (file.content as Uint8List).length > (binFile.content as Uint8List).length) {
            binFile = file;
          }
        } else if (file.name.endsWith('.dat') && file.isFile) {
          if (datFile == null ||
              (file.content as Uint8List).length > (datFile.content as Uint8List).length) {
            datFile = file;
          }
        }
      }

      if (binFile == null) {
        throw Exception('Aucun fichier .bin trouvé');
      }
      if (datFile == null) {
        throw Exception('Aucun fichier .dat trouvé');
      }

      final dfuFiles = DfuFiles(
        firmware: binFile.content as Uint8List,
        initPacket: datFile.content as Uint8List,
        path: assetPath
      );

      if (!dfuFiles.validate()) {
        throw Exception('Fichiers DFU invalides');
      }

      _dfuFilesCache[assetPath] = dfuFiles;
      return dfuFiles;
    } catch (e) {
      throw Exception('Erreur chargement fichiers DFU: $e');
    }
  }

  /// Vide le cache des firmwares
  void clearCache() {
    _cache.clear();
    _dfuFilesCache.clear();
  }

  // ===== Helpers privés =====

  Uint8List _extractBinFromZip(Uint8List zipBytes, String assetPath) {
    final archive = ZipDecoder().decodeBytes(zipBytes);

    for (final file in archive) {
      if (file.name.endsWith('.bin') && file.isFile) {
        return file.content as Uint8List;
      }
    }

    throw Exception('Aucun fichier .bin dans ZIP');
  }

  String _extractVersion(String fileName) {
    final versionPattern = RegExp(r'(\d+\.\d+\.\d+)');
    final match = versionPattern.firstMatch(fileName);
    return match?.group(1) ?? 'Unknown';
  }

  String _detectFirmwareType(String fileName) {
    if (fileName.toLowerCase().contains('infinitime')) return 'InfiniTime';
    if (fileName.toLowerCase().contains('pinetime')) return 'PineTime';
    if (fileName.toLowerCase().contains('mcuboot')) return 'MCUBoot';
    if (fileName.toLowerCase().contains('dfu-terminal')) return 'DFU Terminal';
    return 'Unknown';
  }

  String _generateNotes(FirmwareValidationResult validation) {
    if (validation.format == 'ZIP (BIN extrait)') {
      return 'Archive ZIP avec extraction auto .bin';
    } else if (validation.format == 'BIN') {
      return 'Fichier binaire prêt à flasher';
    }
    return '';
  }

  int _compareVersions(String v1, String v2) {
    final parts1 = v1.split('.').map(int.tryParse).whereType<int>().toList();
    final parts2 = v2.split('.').map(int.tryParse).whereType<int>().toList();

    for (
      int i = 0;
      i < (parts1.length > parts2.length ? parts1.length : parts2.length);
      i++
    ) {
      final p1 = i < parts1.length ? parts1[i] : 0;
      final p2 = i < parts2.length ? parts2[i] : 0;
      if (p1 != p2) return p1.compareTo(p2);
    }

    return 0;
  }
}
