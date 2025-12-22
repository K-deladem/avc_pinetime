// lib/src/models/infinitime_uuids.dart
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

/// Classe contenant tous les UUIDs standard pour InfiniTime/PineTime
/// avec extraction automatique des noms de services
class InfiniTimeUuids {
  // ====== Device Information Service (DIS) ======
  static final Uuid disService = Uuid.parse("0000180A-0000-1000-8000-00805F9B34FB");
  static final Uuid disManufacturer = Uuid.parse("00002A29-0000-1000-8000-00805F9B34FB");
  static final Uuid disModelNumber = Uuid.parse("00002A24-0000-1000-8000-00805F9B34FB");
  static final Uuid disFirmwareRev = Uuid.parse("00002A26-0000-1000-8000-00805F9B34FB");
  static final Uuid disHardwareRev = Uuid.parse("00002A27-0000-1000-8000-00805F9B34FB");

  // ====== Battery Service ======
  static final Uuid batteryService = Uuid.parse("0000180F-0000-1000-8000-00805F9B34FB");
  static final Uuid batteryLevel = Uuid.parse("00002A19-0000-1000-8000-00805F9B34FB");

  // ====== Heart Rate Service ======
  static final Uuid hrService = Uuid.parse("0000180D-0000-1000-8000-00805F9B34FB");
  static final Uuid hrMeasurement = Uuid.parse("00002A37-0000-1000-8000-00805F9B34FB");

  // ====== Current Time Service (CTS) ======
  static final Uuid ctsService = Uuid.parse("00001805-0000-1000-8000-00805F9B34FB");
  static final Uuid ctsCurrentTime = Uuid.parse("00002A2B-0000-1000-8000-00805F9B34FB");

  // ====== Alert Notification Service (ANS) ======
  static final Uuid ansService = Uuid.parse("00001811-0000-1000-8000-00805F9B34FB");
  static final Uuid ansNewAlert = Uuid.parse("00002A46-0000-1000-8000-00805F9B34FB");

  // ====== InfiniTime custom services (base: 78fc-48fe-8e23-433b3a1942d0) ======

  // Music Service (0000XXXX-78fc-48fe-8e23-433b3a1942d0)
  static final Uuid musicService = Uuid.parse("00000000-78fc-48fe-8e23-433b3a1942d0");
  static final Uuid musicEvent = Uuid.parse("00000001-78fc-48fe-8e23-433b3a1942d0");
  static final Uuid musicStatus = Uuid.parse("00000002-78fc-48fe-8e23-433b3a1942d0");
  static final Uuid musicArtist = Uuid.parse("00000003-78fc-48fe-8e23-433b3a1942d0");
  static final Uuid musicTrack = Uuid.parse("00000004-78fc-48fe-8e23-433b3a1942d0");
  static final Uuid musicAlbum = Uuid.parse("00000005-78fc-48fe-8e23-433b3a1942d0");
  static final Uuid musicControl = Uuid.parse("00000006-78fc-48fe-8e23-433b3a1942d0");

  // Navigation Service (0001XXXX-78fc-48fe-8e23-433b3a1942d0)
  static final Uuid navService = Uuid.parse("00010000-78fc-48fe-8e23-433b3a1942d0");
  static final Uuid navFlags = Uuid.parse("00010001-78fc-48fe-8e23-433b3a1942d0");
  static final Uuid navNarrative = Uuid.parse("00010002-78fc-48fe-8e23-433b3a1942d0");
  static final Uuid navManDist = Uuid.parse("00010003-78fc-48fe-8e23-433b3a1942d0");
  static final Uuid navProgress = Uuid.parse("00010004-78fc-48fe-8e23-433b3a1942d0");
  static final Uuid navControl = Uuid.parse("00010005-78fc-48fe-8e23-433b3a1942d0");

  // Call/Notifications Service (0002XXXX-78fc-48fe-8e23-433b3a1942d0)
  static final Uuid callService = Uuid.parse("00020000-78fc-48fe-8e23-433b3a1942d0");
  static final Uuid notifEventChar = Uuid.parse("00020001-78fc-48fe-8e23-433b3a1942d0");

  // Motion Service (0003XXXX-78fc-48fe-8e23-433b3a1942d0)
  static final Uuid motionService = Uuid.parse("00030000-78fc-48fe-8e23-433b3a1942d0");
  static final Uuid motionStepCount = Uuid.parse("00030001-78fc-48fe-8e23-433b3a1942d0");
  static final Uuid motionValues = Uuid.parse("00030002-78fc-48fe-8e23-433b3a1942d0");

  // ====== Movement Service (0006XXXX-78fc-48fe-8e23-433b3a1942d0) ======
  static final Uuid movementService = Uuid.parse("00060000-78fc-48fe-8e23-433b3a1942d0");
  static final Uuid movementData = Uuid.parse("00060001-78fc-48fe-8e23-433b3a1942d0");

  // Weather Service (0004XXXX-78fc-48fe-8e23-433b3a1942d0)
  static final Uuid weatherService = Uuid.parse("00040000-78fc-48fe-8e23-433b3a1942d0");
  static final Uuid weatherData = Uuid.parse("00040001-78fc-48fe-8e23-433b3a1942d0");

  // ====== BLEFS - Bluetooth Low Energy File System (Adafruit) ======
  static final Uuid blefsService = Uuid.parse("ADAF0000-4669-6C65-5472-616E73666572");
  static final Uuid blefsVersion = Uuid.parse("ADAF0100-4669-6C65-5472-616E73666572");
  static final Uuid blefsTransfer = Uuid.parse("ADAF0200-4669-6C65-5472-616E73666572");

  // ====== Nordic UART Service (NUS) ======
  static final Uuid uartService = Uuid.parse("6E400001-B5A3-F393-E0A9-E50E24DCCA9E");
  static final Uuid uartTxChar = Uuid.parse("6E400002-B5A3-F393-E0A9-E50E24DCCA9E"); // Phone -> Watch
  static final Uuid uartRxChar = Uuid.parse("6E400003-B5A3-F393-E0A9-E50E24DCCA9E"); // Watch -> Phone

  // ====== DFU Service (Nordic Legacy DFU pour InfiniTime) ======
  static final Uuid dfuService = Uuid.parse("00001530-1212-EFDE-1523-785FEABCD123");
  static final Uuid dfuControl = Uuid.parse("00001531-1212-EFDE-1523-785FEABCD123");
  static final Uuid dfuData = Uuid.parse("00001532-1212-EFDE-1523-785FEABCD123");

  // Alias pour compatibilité
  static final Uuid dfuControlPoint = dfuControl;
  static final Uuid dfuPacket = dfuData;

  // ====== CACHE POUR EXTRACTION AUTOMATIQUE ======
  static late final Map<String, String> _uuidToNameMap;
  static bool _initialized = false;

  /// Initialise les maps pour l'extraction automatique (appelé une seule fois)
  static void _initialize() {
    if (_initialized) return;

    _uuidToNameMap = {};

    // Construire la map UUID -> Nom
    _buildNameMap();
    _initialized = true;
  }

  /// Construit la map des noms de services
  static void _buildNameMap() {
    final services = {
      'BLEFS': blefsService,
      'Weather': weatherService,
      'Music': musicService,
      'Navigation': navService,
      'Battery': batteryService,
      'Heart Rate': hrService,
      'Motion': motionService,
      'Movement': movementService,
      'Current Time': ctsService,
      'Calls': callService,
      'Alert Notification': ansService,
      'UART': uartService,
      'DFU': dfuService,
      'Device Info': disService,
      'Battery Level': batteryLevel,
      'HR Measurement': hrMeasurement,
      'ANS New Alert': ansNewAlert,
      'Music Event': musicEvent,
      'Music Status': musicStatus,
      'Music Artist': musicArtist,
      'Music Track': musicTrack,
      'Music Album': musicAlbum,
      'Music Control': musicControl,
      'Nav Flags': navFlags,
      'Nav Narrative': navNarrative,
      'Nav Distance': navManDist,
      'Nav Progress': navProgress,
      'Nav Control': navControl,
      'Call Event': notifEventChar,
      'Motion Steps': motionStepCount,
      'Motion Values': motionValues,
      'Movement Data': movementData,
      'Weather Data': weatherData,
      'BLEFS Version': blefsVersion,
      'BLEFS Transfer': blefsTransfer,
      'UART TX': uartTxChar,
      'UART RX': uartRxChar,
      'DFU Control': dfuControl,
      'DFU Data': dfuData,
    };

    services.forEach((name, uuid) {
      final uuidStr = uuid.toString().toLowerCase();
      _uuidToNameMap[uuidStr] = name;
    });
  }

  // =================== EXTRACTION AUTOMATIQUE DES NOMS ===================

  /// Obtient le nom du service pour un UUID string
  static String getServiceName(String uuid) {
    _initialize();
    final normalized = uuid.toLowerCase();
    return _uuidToNameMap[normalized] ?? _extractNameFromUuid(uuid);
  }

  /// Obtient le nom du service pour un Uuid object
  static String getServiceNameFromUuid(Uuid uuid) {
    return getServiceName(uuid.toString());
  }

  /// Extrait automatiquement le nom de l'UUID si pas trouvé dans la map
  static String _extractNameFromUuid(String uuid) {
    final lower = uuid.toLowerCase();

    // Vérifier si c'est un service InfiniTime custom
    if (lower.contains('78fc-48fe-8e23-433b3a1942d0')) {
      final prefix = lower.split('-').first;
      if (prefix == '00000000') return 'Music Service';
      if (prefix == '00010000') return 'Navigation Service';
      if (prefix == '00020000') return 'Calls Service';
      if (prefix == '00030000') return 'Motion Service';
      if (prefix == '00040000') return 'Weather Service';
      if (prefix == '00060000') return 'Movement Service';
      return 'InfiniTime Service ${prefix.substring(4)}';
    }

    // Vérifier les autres patterns connus
    if (lower.contains('adaf0000')) return 'BLEFS';
    if (lower.contains('6e400001')) return 'UART Service';
    if (lower.contains('00001530')) return 'DFU Service';
    if (lower.contains('0000180f')) return 'Battery Service';
    if (lower.contains('0000180d')) return 'Heart Rate Service';
    if (lower.contains('00001805')) return 'Current Time Service';
    if (lower.contains('0000180a')) return 'Device Information';

    // Format générique si pas trouvé
    final parts = uuid.split('-');
    final shortCode = parts.first.toUpperCase();
    return 'Unknown Service ($shortCode)';
  }

  /// Vérifie si un UUID correspond à un service InfiniTime connu
  static bool isInfiniTimeService(Uuid uuid) {
    final uuidStr = uuid.toString().toLowerCase();
    return uuidStr.contains('78fc-48fe-8e23-433b3a1942d0') ||
        uuidStr.contains('adaf0000-4669-6c65-5472-616e73666572') ||
        uuidStr.contains('00001530-1212-efde-1523-785feabcd123') ||
        uuidStr == weatherService.toString().toLowerCase();
  }

  /// Retourne tous les UUIDs disponibles sous forme de Map
  static Map<String, Uuid> getAllUuids() {
    return {
      // DIS
      'disService': disService,
      'disManufacturer': disManufacturer,
      'disModelNumber': disModelNumber,
      'disFirmwareRev': disFirmwareRev,
      'disHardwareRev': disHardwareRev,

      // Battery
      'batteryService': batteryService,
      'batteryLevel': batteryLevel,

      // Heart Rate
      'hrService': hrService,
      'hrMeasurement': hrMeasurement,

      // Current Time
      'ctsService': ctsService,
      'ctsCurrentTime': ctsCurrentTime,

      // Alert Notification Service (ANS)
      'ansService': ansService,
      'ansNewAlert': ansNewAlert,

      // Music
      'musicService': musicService,
      'musicEvent': musicEvent,
      'musicStatus': musicStatus,
      'musicArtist': musicArtist,
      'musicTrack': musicTrack,
      'musicAlbum': musicAlbum,
      'musicControl': musicControl,

      // Navigation
      'navService': navService,
      'navFlags': navFlags,
      'navNarrative': navNarrative,
      'navManDist': navManDist,
      'navProgress': navProgress,
      'navControl': navControl,

      // Call/Notifications
      'callService': callService,
      'notifEventChar': notifEventChar,

      // Motion
      'motionService': motionService,
      'motionStepCount': motionStepCount,
      'motionValues': motionValues,

      // Movement
      'movementService': movementService,
      'movementData': movementData,

      // Weather
      'weatherService': weatherService,
      'weatherData': weatherData,

      // BLEFS
      'blefsService': blefsService,
      'blefsVersion': blefsVersion,
      'blefsTransfer': blefsTransfer,

      // UART
      'uartService': uartService,
      'uartTxChar': uartTxChar,
      'uartRxChar': uartRxChar,

      // DFU
      'dfuService': dfuService,
      'dfuControl': dfuControl,
      'dfuData': dfuData,
      'dfuControlPoint': dfuControlPoint,
      'dfuPacket': dfuPacket,
    };
  }

  /// Affiche tous les UUIDs disponibles
  static void printAllUuids() {
    print('=== InfiniTime UUIDs ===');
    getAllUuids().forEach((key, value) {
      print('$key: $value');
    });
  }

  /// Affiche tous les services avec leurs noms
  static void printAllServices() {
    _initialize();
    print('=== InfiniTime Services ===');
    _uuidToNameMap.forEach((uuid, name) {
      print('$name: $uuid');
    });
  }

  /// Affiche les stats
  static void printStats() {
    _initialize();
    print('Total services: ${_uuidToNameMap.length}');
  }
}

// =================== EXTENSIONS ===================

/// Extension sur Uuid pour extraction automatique du nom
extension UuidServiceName on Uuid {
  /// Retourne automatiquement le nom du service
  String getServiceName() {
    return InfiniTimeUuids.getServiceName(toString());
  }

  /// Alias court pour le nom du service
  String get serviceName => getServiceName();

  /// Retourne le nom court (premier mot)
  String get serviceNameShort {
    final full = getServiceName();
    return full.split(' ').first;
  }

  /// Vérifie si c'est un service InfiniTime
  bool isInfiniTimeService() {
    return InfiniTimeUuids.isInfiniTimeService(this);
  }
}

/// Extension sur String pour extraction automatique du nom
extension StringServiceName on String {
  /// Obtient le nom du service pour cet UUID string
  String getServiceName() {
    return InfiniTimeUuids.getServiceName(this);
  }

  /// Retourne le nom court du service
  String get serviceNameShort {
    return getServiceName().split(' ').first;
  }

  /// Vérifie si c'est un UUID InfiniTime
  bool isInfiniTimeService() {
    try {
      return InfiniTimeUuids.isInfiniTimeService(Uuid.parse(this));
    } catch (_) {
      return false;
    }
  }
}
