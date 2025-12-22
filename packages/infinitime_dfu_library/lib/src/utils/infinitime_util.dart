// lib/src/utils/infinitime_util.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import '../models/infinitime_uuids.dart';
import '../models/enums.dart';
import 'data_parser.dart';
import 'dfu_protocol_helper.dart';
import '../models/movement_data.dart';

/// Classe utilitaire principale pour InfiniTime
/// Regroupe les helpers et formatters
class InfiniTimeUtil {
  InfiniTimeUtil._(); // Classe statique uniquement

  // Export des UUIDs
  static final uuids = InfiniTimeUuids();



  /// Température en Celsius vers bytes pour Weather Service
  static List<int> temperatureToBytes(int temperature) {
    return DfuProtocolHelper.createTemperaturePacket(temperature);
  }

  /// Crée un paquet de temps CTS
  static List<int> createCtsTimePacket(DateTime dateTime) {
    return DfuProtocolHelper.createCtsTimePacket(dateTime);
  }

  /// Vérifie si un UUID est un service InfiniTime
  static bool isInfiniTimeService(Uuid uuid) {
    return InfiniTimeUuids.isInfiniTimeService(uuid);
  }

  /// Parser de batterie
  static int parseBatteryLevel(List<int> data) {
    return DataParser.parseBatteryLevel(data);
  }

  /// Parser de fréquence cardiaque
  static int parseHeartRate(List<int> data) {
    return DataParser.parseHeartRate(data);
  }

  /// Parser de nombre de pas
  static int parseStepCount(List<int> data) {
    return DataParser.parseStepCount(data);
  }

  /// Parser de valeurs de mouvement
  static Map<String, int> parseMotionValues(List<int> data) {
    return DataParser.parseMotionValues(data);
  }

  /// Parser de température
  static double parseTemperature(List<int> data) {
    return DataParser.parseTemperature(data);
  }

  /// Parser d'heure
  static DateTime? parseCurrentTime(List<int> data) {
    return DataParser.parseCurrentTime(data);
  }

  /// Convertir bytes en hex pour debug
  static String bytesToHex(List<int> data) {
    return DataParser.bytesToHex(data);
  }

  /// Convertir bytes en ASCII
  static String bytesToAscii(List<int> data) {
    return DataParser.bytesToAscii(data);
  }

  /// Convertir bytes en UTF-8
  static String bytesToUtf8(List<int> data) {
    return DataParser.bytesToUtf8(data);
  }

  /// Crée un paquet DFU START
  static List<int> createStartDfuPacket({int imageType = 0x04}) {
    return DfuProtocolHelper.createStartDfuPacket(imageType: imageType);
  }

  /// Crée un paquet DFU SIZE
  static List<int> createSizePacket({
    required int firmwareSize,
    int softDeviceSize = 0,
    int bootloaderSize = 0,
  }) {
    return DfuProtocolHelper.createSizePacket(
      firmwareSize: firmwareSize,
      softDeviceSize: softDeviceSize,
      bootloaderSize: bootloaderSize,
    );
  }

  /// Crée un paquet DFU INITIALIZE
  static List<int> createInitializeDfuPacket({int part = 0}) {
    return DfuProtocolHelper.createInitializeDfuPacket(part: part);
  }

  /// Crée un paquet DFU RECEIVE_FIRMWARE_IMAGE
  static List<int> createReceiveFirmwarePacket() {
    return DfuProtocolHelper.createReceiveFirmwarePacket();
  }

  /// Crée un paquet DFU VALIDATE_FIRMWARE
  static List<int> createValidateFirmwarePacket() {
    return DfuProtocolHelper.createValidateFirmwarePacket();
  }

  /// Crée un paquet DFU ACTIVATE_AND_RESET
  static List<int> createActivateAndResetPacket() {
    return DfuProtocolHelper.createActivateAndResetPacket();
  }

  /// Crée un paquet DFU PACKET_RECEIPT_NOTIFICATION_REQUEST
  static List<int> createPacketReceiptNotificationPacket({int notifyEveryN = 16}) {
    return DfuProtocolHelper.createPacketReceiptNotificationPacket(
      notifyEveryN: notifyEveryN,
    );
  }

  /// Parse une réponse DFU
  static Map<String, int>? parseDfuResponse(List<int> data) {
    return DfuProtocolHelper.parseDfuResponse(data);
  }

  /// Calcule le MTU effectif
  static int calculateEffectiveMtu(int negotiatedMtu, {int maxDataSize = 100}) {
    return DfuProtocolHelper.calculateEffectiveMtu(
      negotiatedMtu,
      maxDataSize: maxDataSize,
    );
  }

  /// Divise les données en paquets selon le MTU
  static List<List<int>> splitDataByMtu(List<int> data, int mtu) {
    return DfuProtocolHelper.splitDataByMtu(data, mtu);
  }

  /// Calcule le délai adaptatif
  static Duration calculateAdaptiveDelay(int mtu, int packetNumber) {
    return DfuProtocolHelper.calculateAdaptiveDelay(mtu, packetNumber);
  }

  /// Formate un message de debug
  static String formatDfuDebug(List<int> data) {
    return DfuProtocolHelper.formatDfuDebug(data);
  }

  /// Valide les données DFU
  static bool validateDfuData({
    required Uint8List firmwareData,
    required Uint8List initPacketData,
  }) {
    return DfuProtocolHelper.validateDfuData(
      firmwareData: firmwareData,
      initPacketData: initPacketData,
    );
  }

  /// Calcule le pourcentage de progression
  static int calculateProgressPercentage(int sentBytes, int totalBytes) {
    return DfuProtocolHelper.calculateProgressPercentage(sentBytes, totalBytes);
  }

  /// Détecte le type de firmware
  static String detectFirmwareType(Uint8List data) {
    return DfuProtocolHelper.detectFirmwareType(data);
  }

  /// Parse les données de mouvement
  static MovementData parseMovementData(List<int> data) {
    // Validation
    if (data.length < 22) {
      throw Exception('Données de mouvement invalides: ${data.length} bytes');
    }

    // Parser
    final timestampMs = DataParser.readUint32LE(data, 0);
    final magnitudeActiveTime = DataParser.readUint32LE(data, 4);
    final axisActiveTime = DataParser.readUint32LE(data, 8);
    final movementDetected = DataParser.readUint8(data, 12) != 0;
    final anyMovement = DataParser.readUint8(data, 13) != 0;
    final accelX = DataParser.readInt16LE(data, 14) / 100.0;
    final accelY = DataParser.readInt16LE(data, 16) / 100.0;
    final accelZ = DataParser.readInt16LE(data, 18) / 100.0;

    return MovementData(
      timestampMs: timestampMs,
      magnitudeActiveTime: magnitudeActiveTime,
      axisActiveTime: axisActiveTime,
      movementDetected: movementDetected,
      anyMovement: anyMovement,
      accelX: accelX,
      accelY: accelY,
      accelZ: accelZ,
    );
  }

  /// Calcule le niveau d'activité (0-100)
  static int getActivityLevel(double accelerationMagnitude) {
    if (accelerationMagnitude < 0.1) return 0;      // Immobile
    if (accelerationMagnitude < 0.5) return 25;     // Très faible
    if (accelerationMagnitude < 1.0) return 50;     // Faible
    if (accelerationMagnitude < 2.0) return 75;     // Modéré
    return 100;                                      // Élevé
  }

  /// Formate l'accélération en g
  static String formatAcceleration(double x, double y, double z) {
    return '($x, $y, $z) g';
  }
}
