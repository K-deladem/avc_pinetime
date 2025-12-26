import 'package:infinitime_dfu_library/infinitime_dfu_library.dart';

import '../../../service/firmware_source.dart';
import '../../../utils/app_logger.dart';

/// Handler pour la gestion des firmwares
class FirmwareHandler {
  /// Charge la liste des firmwares disponibles depuis les assets
  static Future<List<FirmwareInfo>> loadAvailableFirmwares() async {
    try {
      final manager = FirmwareManager(FirmwareSource());
      final firmwares = await manager.loadAvailableFirmwares();
      AppLogger.info('${firmwares.length} firmwares loaded');
      return firmwares;
    } catch (e, stackTrace) {
      AppLogger.error('Error loading firmwares', e, stackTrace);
      return [];
    }
  }

  /// Démarre une mise à jour DFU
  static Future<bool> startDfu(
    InfiniTimeSession session,
    String firmwarePath, {
    bool reconnectOnComplete = true,
  }) async {
    try {
      await session.startSystemFirmwareDfu(
        firmwarePath,
        reconnectOnComplete: reconnectOnComplete,
      );
      AppLogger.info('DFU started with path: $firmwarePath');
      return true;
    } catch (e, stackTrace) {
      AppLogger.error('DFU start error', e, stackTrace);
      return false;
    }
  }

  /// Annule une mise à jour DFU en cours
  static Future<bool> abortDfu(InfiniTimeSession session) async {
    try {
      await session.abortSystemFirmwareDfu();
      AppLogger.info('DFU aborted');
      return true;
    } catch (e, stackTrace) {
      AppLogger.error('DFU abort error', e, stackTrace);
      return false;
    }
  }

  /// Obtient des informations sur un firmware spécifique
  static FirmwareDetails? parseFirmwareInfo(FirmwareInfo firmware) {
    try {
      return FirmwareDetails(
        fileName: firmware.fileName,
        version: firmware.version,
        size: firmware.sizeBytes,
      );
    } catch (e) {
      AppLogger.warning('Error parsing firmware info: $e');
      return null;
    }
  }
}

/// Détails d'un firmware
class FirmwareDetails {
  final String fileName;
  final String version;
  final int size;

  FirmwareDetails({
    required this.fileName,
    required this.version,
    required this.size,
  });

  String get formattedSize {
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
