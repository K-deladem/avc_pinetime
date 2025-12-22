// lib/src/utils/dfu_protocol_helper.dart
import 'package:flutter/foundation.dart';

/// Classe d'aide pour le protocole DFU (Device Firmware Update)
class DfuProtocolHelper {
  // ====== DFU Operation Codes ======
  static const int START_DFU = 0x01;
  static const int INITIALIZE_DFU = 0x02;
  static const int RECEIVE_FIRMWARE_IMAGE = 0x03;
  static const int VALIDATE_FIRMWARE = 0x04;
  static const int ACTIVATE_AND_RESET = 0x05;
  static const int RESET_SYSTEM = 0x06;
  static const int PACKET_RECEIPT_NOTIFICATION_REQUEST = 0x08;

  // ====== DFU Response Codes ======
  static const int RESPONSE_SUCCESS = 0x01;
  static const int RESPONSE_INVALID_STATE = 0x02;
  static const int RESPONSE_NOT_SUPPORTED = 0x03;
  static const int RESPONSE_DATA_SIZE_EXCEEDS_LIMIT = 0x04;
  static const int RESPONSE_CRC_ERROR = 0x05;
  static const int RESPONSE_OPERATION_FAILED = 0x06;

  /// Crée un paquet START_DFU
  static List<int> createStartDfuPacket({int imageType = 0x04}) {
    return [START_DFU, imageType];
  }

  /// Crée un paquet SIZE avec la taille du firmware
  /// Format: 12 bytes (8 null + taille firmware en little-endian)
  static List<int> createSizePacket({
    required int firmwareSize,
    int softDeviceSize = 0,
    int bootloaderSize = 0,
  }) {
    final buffer = ByteData(12);
    buffer.setUint32(0, softDeviceSize, Endian.little);
    buffer.setUint32(4, bootloaderSize, Endian.little);
    buffer.setUint32(8, firmwareSize, Endian.little);
    return buffer.buffer.asUint8List();
  }

  /// Crée un paquet INITIALIZE_DFU
  static List<int> createInitializeDfuPacket({int part = 0}) {
    return [INITIALIZE_DFU, part];
  }

  /// Crée un paquet RECEIVE_FIRMWARE_IMAGE
  static List<int> createReceiveFirmwarePacket() {
    return [RECEIVE_FIRMWARE_IMAGE];
  }

  /// Crée un paquet VALIDATE_FIRMWARE
  static List<int> createValidateFirmwarePacket() {
    return [VALIDATE_FIRMWARE];
  }

  /// Crée un paquet ACTIVATE_AND_RESET
  static List<int> createActivateAndResetPacket() {
    return [ACTIVATE_AND_RESET];
  }

  /// Crée un paquet PACKET_RECEIPT_NOTIFICATION_REQUEST
  static List<int> createPacketReceiptNotificationPacket({int notifyEveryN = 16}) {
    return [
      PACKET_RECEIPT_NOTIFICATION_REQUEST,
      notifyEveryN & 0xFF,
      (notifyEveryN >> 8) & 0xFF,
    ];
  }

  /// Parse une réponse DFU
  /// Retourne (commandId, responseCode) ou null si invalide
  static Map<String, int>? parseDfuResponse(List<int> data) {
    if (data.length < 3) return null;
    if (data[0] != 0x10) return null; // Response opcode

    return {
      'commandId': data[1],
      'responseCode': data[2],
    };
  }

  /// Crée un paquet CTS (Current Time Service)
  static List<int> createCtsTimePacket(DateTime dateTime) {
    return [
      dateTime.year & 0xFF,
      (dateTime.year >> 8) & 0xFF,
      dateTime.month,
      dateTime.day,
      dateTime.hour,
      dateTime.minute,
      dateTime.second,
      dateTime.weekday % 7, // 0 = Monday in BLE
      0, // Fractions of second
      0, // Adjust reason
    ];
  }

  /// Crée un paquet de température pour Weather Service
  /// Format: int16 en centièmes de degrés Celsius
  static List<int> createTemperaturePacket(int temperature) {
    final tempCelsius = (temperature * 100).toInt();
    return [
      tempCelsius & 0xFF,
      (tempCelsius >> 8) & 0xFF,
    ];
  }

  /// Calcule le MTU effectif pour le transfert
  /// MTU = Maximum Transmission Unit de la couche BLE
  /// Nous retirons les headers ATT (3 bytes)
  static int calculateEffectiveMtu(int negotiatedMtu, {int maxDataSize = 100}) {
    const int attHeaderSize = 3;
    int effectiveMtu = negotiatedMtu - attHeaderSize;
    
    // Capper au maximum raisonnable
    if (effectiveMtu > maxDataSize) {
      effectiveMtu = maxDataSize;
    }
    
    // Minimum 20 bytes (MTU 23)
    if (effectiveMtu < 20) {
      effectiveMtu = 20;
    }
    
    return effectiveMtu;
  }

  /// Divise les données en paquets selon le MTU
  static List<List<int>> splitDataByMtu(List<int> data, int mtu) {
    final packets = <List<int>>[];
    
    for (int i = 0; i < data.length; i += mtu) {
      int end = (i + mtu < data.length) ? i + mtu : data.length;
      packets.add(data.sublist(i, end));
    }
    
    return packets;
  }

  /// Calcule un délai adaptatif basé sur le MTU et le nombre de paquets
  static Duration calculateAdaptiveDelay(int mtu, int packetNumber) {
    int delayMs = 5;
    
    if (mtu < 40) {
      delayMs = 10;
    } else if (mtu < 80) {
      delayMs = 8;
    } else if (mtu >= 80) {
      delayMs = 5;
    }
    
    // Augmenter le délai tous les 100 paquets
    if (packetNumber > 100 && packetNumber % 100 == 0) {
      delayMs += 5;
    }
    
    return Duration(milliseconds: delayMs);
  }

  /// Formate un message de debug pour DFU
  static String formatDfuDebug(List<int> data) {
    return 'DFU: ${data.map((b) => '0x${b.toRadixString(16).padLeft(2, '0').toUpperCase()}').join(' ')}';
  }

  /// Valide les données DFU de base
  static bool validateDfuData({
    required Uint8List firmwareData,
    required Uint8List initPacketData,
  }) {
    // Vérifications du firmware
    if (firmwareData.isEmpty) return false;
    if (firmwareData.length < 1024) return false; // Au moins 1KB
    if (firmwareData.length > 10 * 1024 * 1024) return false; // Max 10MB

    // Vérifications du paquet d'initialisation
    if (initPacketData.isEmpty) return false;
    if (initPacketData.length > 1024) return false; // Max 1KB typiquement

    return true;
  }

  /// Crée un paquet de taille de progression pour les notifications
  static int calculateProgressPercentage(int sentBytes, int totalBytes) {
    if (totalBytes == 0) return 0;
    return ((sentBytes * 100) / totalBytes).toInt().clamp(0, 100);
  }

  /// Détecte le type de firmware basé sur le magic number
  static String detectFirmwareType(Uint8List data) {
    if (data.length < 4) return 'Unknown';

    final magicNumber = (data[3] << 24) |
        (data[2] << 16) |
        (data[1] << 8) |
        data[0];

    // Magic numbers pour MCUBoot
    if (magicNumber == 0x96F3B83D || magicNumber == 0x96F3B83C) {
      return 'MCUBoot';
    }

    // Magic number pour Nordic bootloader
    if (magicNumber == 0x00000000) {
      return 'Nordic';
    }

    return 'Unknown (0x${magicNumber.toRadixString(16).toUpperCase()})';
  }
}
