// lib/src/services/dfu_service_manager.dart
import 'dart:async';

import 'package:archive/archive.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:infinitime_dfu_library/src/utils/operation_helper.dart';
import 'package:infinitime_dfu_library/src/utils/state_manager.dart';

import '../models/dfu_files.dart';
import '../models/enums.dart';
import '../models/infinitime_uuids.dart';
import '../utils/dfu_protocol_helper.dart';

/// Callback pour les mises à jour de statut
typedef StatusCallback = void Function(String status);

/// Callback pour les mises à jour de progression
typedef ProgressCallback = void Function(double progress);

/// Callback pour les erreurs
typedef ErrorCallback = void Function(String error);

/// Service de gestion des mises à jour DFU
class DfuServiceManager {
  final FlutterReactiveBle _ble;
  late final DfuStateManager _stateManager;

  bool _isConnected = false;
  String? _connectedDeviceId;
  bool _updateRunning = false;
  StreamSubscription<ConnectionStateUpdate>? _connectionSubscription;

  final StreamController<String> _statusController =
      StreamController.broadcast();
  final StreamController<double> _progressController =
      StreamController.broadcast();
  final StreamController<DfuUpdateState> _stateController =
      StreamController.broadcast();

  // Callbacks
  StatusCallback? _onStatusUpdate;
  ProgressCallback? _onProgressUpdate;
  ErrorCallback? _onError;

  Stream<String> get statusStream => _statusController.stream;

  Stream<double> get progressStream => _progressController.stream;

  Stream<DfuUpdateState> get stateStream => _stateController.stream;

  bool get isConnected => _isConnected;

  String? get connectedDeviceId => _connectedDeviceId;

  bool get isUpdateRunning => _updateRunning;

  DfuServiceManager(this._ble) {
    _stateManager = DfuStateManager();
    _setupStateHandlers();
  }

  void _setupStateHandlers() {
    _stateManager.onStateChanged((newState) {
      _stateController.add(newState);
    });

    _stateManager.onInvalidTransition((from, to) {
      _onError?.call('Invalid state transition: $from → $to');
    });
  }

  /// Définit le callback de statut
  void onStatusUpdate(StatusCallback? callback) {
    _onStatusUpdate = callback;
  }

  /// Définit le callback de progression
  void onProgressUpdate(ProgressCallback? callback) {
    _onProgressUpdate = callback;
  }

  /// Définit le callback d'erreur
  void onError(ErrorCallback? callback) {
    _onError = callback;
  }

  /// Connecte l'appareil en mode DFU
  Future<bool> connectToDevice(
    String deviceId, {
    int maxRetries = 3,
    Duration retryDelay = const Duration(seconds: 3),
  }) async {
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        _updateStatus("Connexion DFU $attempt/$maxRetries...");
        _updateState(DfuUpdateState.preparing);

        await _cleanupPreviousConnection();

        if (deviceId.isEmpty) {
          throw Exception("DeviceId vide");
        }

        await Future.delayed(const Duration(milliseconds: 500));

        final completer = Completer<bool>();

        await OperationHelper.withTimeoutAndRetry(
          () async => _ble
              .connectToDevice(
                id: deviceId,
                connectionTimeout: const Duration(seconds: 10),
              )
              .listen(
                (connectionState) {
                  if (connectionState.connectionState ==
                      DeviceConnectionState.connected) {
                    if (!completer.isCompleted) {
                      _isConnected = true;
                      _connectedDeviceId = deviceId;
                      _updateStatus("Connecté à $deviceId");
                      completer.complete(true);
                    }
                  } else if (connectionState.connectionState ==
                      DeviceConnectionState.disconnected) {
                    if (!completer.isCompleted) {
                      _updateStatus("Déconnexion détectée");
                      completer.complete(false);
                    }
                  }
                },
                onError: (error) {
                  if (!completer.isCompleted) {
                    _updateStatus("Erreur connexion: $error");
                    completer.complete(false);
                  }
                },
              ),
          operationName: 'Connect to device: $deviceId',
          timeout: Duration(seconds: 15),
          maxRetries: 3,
        );

        final connected = await completer.future.timeout(
          const Duration(seconds: 12),
          onTimeout: () {
            _updateStatus("Timeout connexion");
            return false;
          },
        );

        if (connected) {
          await Future.delayed(const Duration(milliseconds: 1000));
          _updateStatus("Mode DFU prêt");
          return true;
        }
      } catch (e) {
        _updateStatus("Tentative $attempt échouée: $e");
        await _cleanupPreviousConnection();

        if (attempt < maxRetries) {
          _updateStatus("Nouvelle tentative dans ${retryDelay.inSeconds}s...");
          await Future.delayed(retryDelay);
        }
      }
    }

    _isConnected = false;
    _connectedDeviceId = null;
    _updateStatus("ÉCHEC: Connexion impossible après $maxRetries tentatives");
    _updateState(DfuUpdateState.failed);
    return false;
  }

  /// Effectue la mise à jour complète DFU
  Future<bool> performCompleteFirmwareUpdate(
    DfuFiles dfuFiles, {
    Duration timeout = const Duration(minutes: 10),
    bool compatibilityMode = false,
  }) async {
    if (!_isConnected || _connectedDeviceId == null) {
      throw Exception("Appareil non connecté ou deviceId manquant");
    }
    if (_updateRunning) {
      throw Exception("Une mise à jour est déjà en cours");
    }

    try {
      _updateRunning = true;
      _updateState(DfuUpdateState.initialized);
      _updateStatus(
        "Début mise à jour DFU (${dfuFiles.firmware.length} bytes)",
      );
      _updateProgress(0.0);

      final result = await _performDfuUpdate(
        _connectedDeviceId!,
        dfuFiles,
        timeout: timeout,
        compatibilityMode: compatibilityMode,
      );

      if (result) {
        _updateStatus("Mise à jour réussie!");
        _updateProgress(1.0);
        _updateState(DfuUpdateState.completed);
        return true;
      } else {
        _updateStatus("Mise à jour échouée");
        _updateState(DfuUpdateState.failed);
        return false;
      }
    } catch (e) {
      _updateStatus("ERREUR: $e");
      _updateState(DfuUpdateState.failed);
      _onError?.call(e.toString());
      return false;
    } finally {
      _updateRunning = false;
    }
  }

  QualifiedCharacteristic _qc(Uuid serviceId, Uuid charId, String deviceId) {
    return QualifiedCharacteristic(
      serviceId: serviceId,
      characteristicId: charId,
      deviceId: deviceId,
    );
  }

  Future<bool> _performDfuUpdate(
    String deviceId,
    DfuFiles dfuFiles, {
    required Duration timeout,
    required bool compatibilityMode,
  }) async {
    try {
      await Future.delayed(const Duration(seconds: 1));

      final inDfuMode = await _checkIfInDfuMode(deviceId);

      if (!inDfuMode) {
        _updateStatus("Tentative d'activation du mode DFU...");
        try {
          await _enterDfuMode(deviceId);
          _updateStatus("Mode DFU activé");
          await Future.delayed(const Duration(seconds: 5));
        } catch (e) {
          final errorMsg = e.toString();
          if (errorMsg.contains('already_in_dfu')) {
            _updateStatus("Déjà en mode DFU");
          } else if (errorMsg.contains('dfu_reboot_initiated')) {
            _updateStatus("Redémarrage en mode DFU...");
            await Future.delayed(const Duration(seconds: 8));

            _updateStatus("Reconnexion après redémarrage...");
            await _cleanupPreviousConnection();
            await Future.delayed(const Duration(seconds: 2));

            final reconnected = await connectToDevice(deviceId);
            if (!reconnected) {
              throw Exception("Échec reconnexion");
            }
          } else {
            _updateStatus("Erreur activation mode DFU: $e");
            rethrow;
          }
        }
      }

      final completer = Completer<bool>();
      Timer? timeoutTimer;

      timeoutTimer = Timer(timeout, () {
        if (!completer.isCompleted) {
          _updateStatus("TIMEOUT");
          completer.complete(false);
        }
      });

      try {
        await _uploadFirmware(
          deviceId,
          dfuFiles,
          compatibilityMode: compatibilityMode,
        );
        timeoutTimer.cancel();
        if (!completer.isCompleted) {
          completer.complete(true);
        }
      } catch (error) {
        timeoutTimer.cancel();
        _updateStatus("Erreur transfert: $error");
        if (!completer.isCompleted) {
          completer.complete(false);
        }
      }

      return await completer.future;
    } catch (e) {
      _updateStatus("Erreur DFU: $e");
      return false;
    }
  }

  Future<bool> _checkIfInDfuMode(String deviceId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      await _ble.discoverAllServices(deviceId);
      final services = await _ble.getDiscoveredServices(deviceId);

      final dfuServiceStr = InfiniTimeUuids.dfuService.toString().toLowerCase();
      final result = services.any(
        (s) => s.id.toString().toLowerCase() == dfuServiceStr,
      );

      _updateStatus(result ? "Mode DFU détecté" : "Mode normal");
      return result;
    } catch (e) {
      _updateStatus("Erreur vérification mode DFU: $e");
      return false;
    }
  }

  Future<void> _enterDfuMode(String deviceId) async {
    await _ble.discoverAllServices(deviceId);
    final services = await _ble.getDiscoveredServices(deviceId);

    final dfuServiceStr = InfiniTimeUuids.dfuService.toString().toLowerCase();
    bool alreadyInDfu = services.any(
      (s) => s.id.toString().toLowerCase() == dfuServiceStr,
    );

    if (alreadyInDfu) {
      throw Exception('already_in_dfu');
    }

    final weatherServiceStr =
        InfiniTimeUuids.weatherService.toString().toLowerCase();
    bool weatherServiceFound = services.any(
      (s) => s.id.toString().toLowerCase() == weatherServiceStr,
    );

    if (weatherServiceFound) {
      final weatherChar = _qc(
        InfiniTimeUuids.weatherService,
        InfiniTimeUuids.weatherData,
        deviceId,
      );

      await _ble.writeCharacteristicWithResponse(
        weatherChar,
        value: [0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00],
      );
      throw Exception('dfu_reboot_initiated');
    }

    throw Exception('manual_dfu_required');
  }

  Future<void> _uploadFirmware(
    String deviceId,
    DfuFiles dfuFiles, {
    required bool compatibilityMode,
  }) async {
    final firmwareData = dfuFiles.firmware;
    final initPacketData = dfuFiles.initPacket;
    final progressTracker = _ProgressTracker();

    await _ble.discoverAllServices(deviceId);
    final services = await _ble.getDiscoveredServices(deviceId);

    final dfuServiceStr = InfiniTimeUuids.dfuService.toString().toLowerCase();
    bool dfuServiceFound = services.any(
      (s) => s.id.toString().toLowerCase() == dfuServiceStr,
    );

    if (!dfuServiceFound) {
      throw Exception("Service DFU non trouvé!");
    }

    // Négociation MTU
    // compatibilityMode = true quand version > 1.13.5 → négociation MTU
    // compatibilityMode = false quand version ≤ 1.13.5 ou inconnue → MTU = 20
    int effectiveMtu = 20;
    if (compatibilityMode) {
      try {
        _updateStatus("Négociation MTU...");
        final negotiatedMtu = await _ble.requestMtu(
          deviceId: deviceId,
          mtu: 247,
        );
        effectiveMtu = DfuProtocolHelper.calculateEffectiveMtu(negotiatedMtu);
        _updateStatus("MTU: $effectiveMtu bytes");
        await Future.delayed(const Duration(milliseconds: 500));
      } catch (e) {
        _updateStatus("MTU par défaut: 20 bytes");
        effectiveMtu = 20;
      }
    } else {
      _updateStatus("MTU par défaut: 20 bytes (version ≤ 1.13.5)");
      effectiveMtu = 20;
    }

    final controlChar = _qc(
      InfiniTimeUuids.dfuService,
      InfiniTimeUuids.dfuControlPoint,
      deviceId,
    );

    final packetChar = _qc(
      InfiniTimeUuids.dfuService,
      InfiniTimeUuids.dfuPacket,
      deviceId,
    );

    List<int> lastResponse = [];
    final subscription = _ble.subscribeToCharacteristic(controlChar).listen((
      data,
    ) {
      if (data.isNotEmpty) {
        lastResponse = data;
        if (kDebugMode) {
          print(DfuProtocolHelper.formatDfuDebug(data));
        }
      }
    }, onError: (e) => print("Erreur notifications: $e"));

    try {
      _updateState(DfuUpdateState.initialized);
      await Future.delayed(const Duration(milliseconds: 500));
      _updateStatus("Initialisation DFU...");
      _updateProgress(progressTracker.getProgress('initialization'));

      // START DFU
      lastResponse = [];
      await _ble.writeCharacteristicWithResponse(
        controlChar,
        value: [DfuProtocolHelper.START_DFU, 0x04],
      );
      await _waitForResponse(lastResponse, const Duration(seconds: 3));
      _updateProgress(progressTracker.getProgress('start_dfu'));
      _updateStatus("DFU démarré");

      // SIZE
      final sizePacket = DfuProtocolHelper.createSizePacket(
        firmwareSize: firmwareData.length,
      );
      await _ble.writeCharacteristicWithResponse(packetChar, value: sizePacket);
      await Future.delayed(const Duration(milliseconds: 300));
      _updateProgress(progressTracker.getProgress('size_packet'));
      _updateStatus("Taille firmware envoyée");

      // INITIALIZE DFU (part 1)
      lastResponse = [];
      await _ble.writeCharacteristicWithResponse(
        controlChar,
        value: [DfuProtocolHelper.INITIALIZE_DFU, 0x00],
      );
      await _waitForResponse(lastResponse, const Duration(seconds: 3));
      _updateProgress(progressTracker.getProgress('init_part1'));
      _updateStatus("Init DFU partie 1");

      // INIT PACKET
      _updateStatus("Envoi init packet...");
      await _ble.writeCharacteristicWithResponse(
        packetChar,
        value: initPacketData,
      );
      await Future.delayed(const Duration(milliseconds: 300));
      _updateProgress(progressTracker.getProgress('init_packet'));
      _updateStatus("Init packet envoyé");

      // INITIALIZE DFU (part 2)
      lastResponse = [];
      await _ble.writeCharacteristicWithResponse(
        controlChar,
        value: [DfuProtocolHelper.INITIALIZE_DFU, 0x01],
      );
      await _waitForResponse(lastResponse, const Duration(seconds: 3));
      _updateProgress(progressTracker.getProgress('init_part2'));
      _updateStatus("Init DFU partie 2");

      // PACKET RECEIPT NOTIFICATION
      lastResponse = [];
      await _ble.writeCharacteristicWithResponse(
        controlChar,
        value: DfuProtocolHelper.createPacketReceiptNotificationPacket(
          notifyEveryN: 16,
        ),
      );
      await Future.delayed(const Duration(milliseconds: 200));
      _updateProgress(progressTracker.getProgress('packet_notification'));
      _updateStatus("Notification configurée");

      // RECEIVE FIRMWARE IMAGE
      _updateState(DfuUpdateState.sending);
      _updateStatus("Démarrage transfert...");
      lastResponse = [];
      await _ble.writeCharacteristicWithResponse(
        controlChar,
        value: [DfuProtocolHelper.RECEIVE_FIRMWARE_IMAGE],
      );
      await _waitForResponse(lastResponse, const Duration(seconds: 3));
      _updateProgress(progressTracker.getProgress('receive_image'));
      _updateStatus("Prêt à recevoir firmware");

      // TRANSFERT
      int sentBytes = 0;
      int totalSize = firmwareData.length;
      int packetCount = 0;

      _updateStatus("Transfert (MTU=$effectiveMtu)...");

      for (int i = 0; i < firmwareData.length; i += effectiveMtu) {
        int end =
            (i + effectiveMtu < firmwareData.length)
                ? i + effectiveMtu
                : firmwareData.length;
        List<int> packet = firmwareData.sublist(i, end);

        await _ble.writeCharacteristicWithoutResponse(
          packetChar,
          value: packet,
        );

        sentBytes += packet.length;
        packetCount++;

        // Mise à jour progressive plus fréquente (tous les 10 paquets au lieu de 50)
        if (packetCount % 10 == 0 || sentBytes == totalSize) {
          final transferProgress = progressTracker.getTransferProgress(
            sentBytes,
            totalSize,
          );
          _updateProgress(transferProgress);
          _updateStatus(
            "Transfert: ${(sentBytes / 1024).toStringAsFixed(1)}/${(totalSize / 1024).toStringAsFixed(1)} KB",
          );
        }

        if (packetCount % 20 == 0) {
          await Future.delayed(const Duration(milliseconds: 5));
        }
      }

      _updateState(DfuUpdateState.validating);
      _updateStatus("Validation firmware...");
      _updateProgress(progressTracker.getProgress('validation'));
      await Future.delayed(const Duration(milliseconds: 500));

      // VALIDATE FIRMWARE
      lastResponse = [];
      await _ble.writeCharacteristicWithResponse(
        controlChar,
        value: [DfuProtocolHelper.VALIDATE_FIRMWARE],
      );
      _updateStatus("Validation du firmware...");
      await Future.delayed(const Duration(seconds: 1));

      // ACTIVATE_AND_RESET
      _updateState(DfuUpdateState.activating);
      _updateStatus("Activation et redémarrage...");
      _updateProgress(progressTracker.getProgress('activation'));

      try {
        await _ble.writeCharacteristicWithResponse(
          controlChar,
          value: [DfuProtocolHelper.ACTIVATE_AND_RESET],
        );
        await Future.delayed(const Duration(milliseconds: 500));
      } catch (e) {
        if (e.toString().toLowerCase().contains('disconnect') ||
            e.toString().toLowerCase().contains('not connected')) {
          _updateStatus("Redémarrage initié");
        }
      }

      await _cleanupPreviousConnection();
      await Future.delayed(const Duration(seconds: 1));

      _updateStatus("Mise à jour terminée!");
      _updateProgress(progressTracker.getProgress('finalization'));
    } finally {
      try {
        await subscription.cancel();
      } catch (e) {
        if (kDebugMode) print("Cancel subscription: $e");
      }
    }
  }

  Future<bool> _waitForResponse(
    List<int> responseList,
    Duration timeout,
  ) async {
    final startTime = DateTime.now();
    while (responseList.isEmpty) {
      if (DateTime.now().difference(startTime) > timeout) {
        return false;
      }
      await Future.delayed(const Duration(milliseconds: 100));
    }
    return true;
  }

  Future<bool> cancelUpdate() async {
    if (_updateRunning) {
      _updateStatus("Annulation demandée");
      _updateRunning = false;
      _updateState(DfuUpdateState.cancelled);
      return true;
    }
    return false;
  }

  Future<void> _cleanupPreviousConnection() async {
    try {
      if (_connectionSubscription != null) {
        await _connectionSubscription!.cancel();
        _connectionSubscription = null;
      }
    } catch (e) {
      if (kDebugMode) print("Erreur cleanup: $e");
    }

    _isConnected = false;
    _connectedDeviceId = null;
  }

  void _updateStatus(String status) {
    final msg =
        "[${DateTime.now().toIso8601String().substring(11, 19)}] $status";
    if (!_statusController.isClosed) {
      _statusController.add(msg);
    }
    if (kDebugMode) print("DFU: $msg");
  }

  void _updateProgress(double progress) {
    final clamped = progress.clamp(0.0, 1.0);
    if (!_progressController.isClosed) {
      _progressController.add(clamped);
    }
  }

  void _updateState(DfuUpdateState state) {
    if (!_stateController.isClosed) {
      _stateController.add(state);
    }
  }

  Future<void> dispose() async {
    await _cleanupPreviousConnection();
    if (!_statusController.isClosed) await _statusController.close();
    if (!_progressController.isClosed) await _progressController.close();
    if (!_stateController.isClosed) await _stateController.close();
  }

  Future<DfuFiles> loadFirmwareFromAssets(String assetPath) async {
    try {
      _updateStatus("Chargement firmware depuis assets: $assetPath");
      final zipData = await rootBundle.load(assetPath);
      final zipBytes = zipData.buffer.asUint8List();
      final archive = ZipDecoder().decodeBytes(zipBytes);

      ArchiveFile? binFile;
      ArchiveFile? datFile;

      for (final file in archive) {
        // Ignorer les fichiers de métadonnées macOS
        if (file.name.startsWith('__MACOSX/') || file.name.startsWith('._')) {
          _updateStatus("Ignoré (métadonnées macOS): ${file.name}");
          continue;
        }

        if (file.name.endsWith('.bin') && file.isFile) {
          // Ne garder que si c'est plus grand que les métadonnées
          if (binFile == null ||
              (file.content).length > (binFile.content).length) {
            binFile = file;
            _updateStatus(
              "Fichier .bin trouvé: ${file.name} (${(file.content).length} bytes)",
            );
          }
        } else if (file.name.endsWith('.dat') && file.isFile) {
          // Ne garder que si c'est plus grand que les métadonnées
          if (datFile == null ||
              (file.content).length > (datFile.content).length) {
            datFile = file;
            _updateStatus(
              "Fichier .dat trouvé: ${file.name} (${(file.content).length} bytes)",
            );
          }
        }
      }

      if (binFile == null) {
        throw Exception("Aucun fichier .bin trouvé dans l'archive ZIP");
      }

      if (datFile == null) {
        throw Exception("Aucun fichier .dat trouvé dans l'archive ZIP");
      }

      final firmwareBytes = binFile.content as Uint8List;
      final datBytes = datFile.content as Uint8List;

      // Vérifications du firmware
      if (firmwareBytes.length < 1024) {
        throw Exception(
          "Fichier .bin trop petit (${firmwareBytes.length} bytes) - probablement corrompu",
        );
      }

      // Pour InfiniTime, la taille typique est entre 300KB et 600KB
      if (firmwareBytes.length > 1024 * 1024) {
        throw Exception(
          "Fichier .bin trop grand (${firmwareBytes.length} bytes) - format invalide",
        );
      }

      // Vérifier que ce n'est pas un fichier texte
      if (firmwareBytes[0] == 0x7B || firmwareBytes[0] == 0x5B) {
        // { ou [
        throw Exception("Le fichier semble être JSON, pas un firmware binaire");
      }

      // Vérification du .dat
      if (datBytes.isEmpty) {
        throw Exception("Fichier .dat vide");
      }

      _updateStatus(
        "Firmware valide: ${firmwareBytes.length} bytes (${(firmwareBytes.length / 1024).toStringAsFixed(1)} KB)",
      );
      _updateStatus("Init packet: ${datBytes.length} bytes");

      return DfuFiles(
        firmware: firmwareBytes,
        initPacket: datBytes,
        path: assetPath,
      );
    } catch (e) {
      _updateStatus("✗ Erreur chargement firmware: $e");
      throw Exception("Impossible de charger firmware depuis assets: $e");
    }
  }
}

/// Classe interne pour gérer la progression par étapes
class _ProgressTracker {
  late final Map<String, double> _stageProgress;

  _ProgressTracker() {
    // Progression alignée avec la montre :
    // - Transfert = 0% à 95% (comme la montre)
    // - Validation/Activation = 95% à 99%
    // - Reconnexion après installation = 100%
    _stageProgress = {
      'initialization': 0.0,       // 0%
      'start_dfu': 0.0,            // 0%
      'size_packet': 0.0,          // 0%
      'init_part1': 0.0,           // 0%
      'init_packet': 0.0,          // 0%
      'init_part2': 0.0,           // 0%
      'packet_notification': 0.0,  // 0%
      'receive_image': 0.0,        // 0% - prêt à transférer
      'transfer': 0.95,            // 0% -> 95% (transfert = comme la montre)
      'validation': 0.97,          // 95% -> 97%
      'activation': 0.99,          // 97% -> 99%
      'finalization': 1.0,         // 100% (reconnexion terminée)
    };
  }

  double getProgress(String stage) => _stageProgress[stage] ?? 0.0;

  /// Calcule la progression interpolée pour le transfert
  /// Correspond exactement à la progression affichée sur la montre (0% -> 95%)
  double getTransferProgress(int sentBytes, int totalBytes) {
    const double transferStart = 0.0;
    const double transferEnd = 0.95;
    final progress = sentBytes / totalBytes;
    return transferStart + (progress * (transferEnd - transferStart));
  }
}