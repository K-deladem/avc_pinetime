// lib/src/services/movement_service.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:infinitime_dfu_library/src/exceptions/dfu_exceptions.dart';
import 'package:infinitime_dfu_library/src/utils/operation_helper.dart';
import '../models/infinitime_uuids.dart';
import '../models/movement_data.dart';
import '../utils/data_parser.dart';

/// Callback pour les événements de mouvement
typedef MovementCallback = void Function(MovementData movement);

/// Service de gestion des données de mouvement
/// Gère la lecture et l'analyse des données d'accéléromètre/gyroscope
class MovementService {
  final FlutterReactiveBle _ble;
  final String _deviceId;

  StreamSubscription? _subscription;
  final StreamController<MovementData> _movementController =
  StreamController<MovementData>.broadcast();

  MovementCallback? _onMovementChanged;

  bool _isSubscribed = false;

  /// Stream des événements de mouvement
  Stream<MovementData> get movementStream => _movementController.stream;

  /// État de la souscription
  bool get isSubscribed => _isSubscribed;

  MovementService(this._ble, this._deviceId);

  /// Définie le callback de mouvement
  void onMovementChanged(MovementCallback? callback) {
    _onMovementChanged = callback;
  }

  /// Souscrire aux données de mouvement
  Future<void> subscribe() async {
    try {
      if (_isSubscribed) {
        if (kDebugMode) print('Déjà abonné au service de mouvement');
        return;
      }

      final characteristic = QualifiedCharacteristic(
        serviceId: InfiniTimeUuids.movementService,
        characteristicId: InfiniTimeUuids.movementData,
        deviceId: _deviceId,
      );

      // ÉTAPE 1: Vérifier que la souscription fonctionne (avec timeout/retry)
      await OperationHelper.withTimeoutAndRetry(
            () => _ble.subscribeToCharacteristic(characteristic)
            .first
            .timeout(
          Duration(seconds: 10),
          onTimeout: () {
            throw DfuTimeoutException(
              'Subscribe to movement characteristic',
              timeout: Duration(seconds: 10),
            );
          },
        ),
        operationName: 'Subscribe to movement data',
        timeout: Duration(seconds: 15),
        maxRetries: 3,
      );

      // ÉTAPE 2: Créer la souscription réelle pour les données continues
      _subscription = _ble.subscribeToCharacteristic(characteristic).listen(
            (data) {
          if (kDebugMode) {
            print('[MovementService] Received ${data.length} bytes');
          }
          if (data.length == 22) {
            try {
              final movement = _parseMovementData(data);
              _movementController.add(movement);
              _onMovementChanged?.call(movement);
              if (kDebugMode) {
                print('[MovementService] Movement data parsed successfully');
              }
            } catch (e) {
              if (kDebugMode) {
                print('[MovementService] Parse error: $e');
              }
              _movementController.addError(
                GenericDfuException('Failed to parse movement data: $e'),
              );
            }
          } else {
            if (kDebugMode) {
              print('[MovementService] Invalid data length: ${data.length}, expected 22 bytes');
            }
          }
        },
        onError: (e) {
          final dfuError = createDfuException(
            e,
            context: 'Movement subscription error',
          );
          _movementController.addError(dfuError);
          _isSubscribed = false;
        },
        cancelOnError: false,
        onDone: () {
          _isSubscribed = false;
          if (kDebugMode) print('Movement stream fermé');
        },
      );

      _isSubscribed = true;
      if (kDebugMode) print('Souscription au service de mouvement réussie');
    } catch (e) {
      _isSubscribed = false;
      if (kDebugMode) print('Erreur souscription mouvement: $e');
      rethrow;
    }
  }

  /// Se désabonner des données de mouvement
  Future<void> unsubscribe() async {
    try {
      if (_subscription != null) {
        await _subscription!.cancel();
        _subscription = null;
      }
      _isSubscribed = false;
      if (kDebugMode) print('Désinscription du service de mouvement');
    } catch (e) {
      if (kDebugMode) print('Erreur désinscription mouvement: $e');
    }
  }

  /// Parse les 22 bytes de données de mouvement
  ///
  /// Format:
  /// - [0-3]   : timestamp (uint32 LE, ms)
  /// - [4-7]   : magnitudeActiveTime (uint32 LE, ms)
  /// - [8-11]  : axisActiveTime (uint32 LE, ms)
  /// - [12]    : movementDetected (uint8 bool)
  /// - [13]    : anyMovement (uint8 bool)
  /// - [14-15] : accelX (int16 LE, centièmes de g)
  /// - [16-17] : accelY (int16 LE, centièmes de g)
  /// - [18-19] : accelZ (int16 LE, centièmes de g)
  /// - [20-21] : reserved
  MovementData _parseMovementData(List<int> data) {
    int offset = 0;

    // Timestamp (4 bytes, little-endian)
    final timestampMs = DataParser.readUint32LE(data, offset);
    offset += 4;

    // Magnitude active time (4 bytes, little-endian)
    final magnitudeActiveTime = DataParser.readUint32LE(data, offset);
    offset += 4;

    // Axis active time (4 bytes, little-endian)
    final axisActiveTime = DataParser.readUint32LE(data, offset);
    offset += 4;

    // Movement detected (1 byte)
    final movementDetected = DataParser.readUint8(data, offset) != 0;
    offset += 1;

    // Any movement (1 byte)
    final anyMovement = DataParser.readUint8(data, offset) != 0;
    offset += 1;

    // Acceleration X (2 bytes, signed little-endian)
    final accelXInt = DataParser.readInt16LE(data, offset);
    final accelX = accelXInt / 100.0;
    offset += 2;

    // Acceleration Y (2 bytes, signed little-endian)
    final accelYInt = DataParser.readInt16LE(data, offset);
    final accelY = accelYInt / 100.0;
    offset += 2;

    // Acceleration Z (2 bytes, signed little-endian)
    final accelZInt = DataParser.readInt16LE(data, offset);
    final accelZ = accelZInt / 100.0;

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

  /// Libère les ressources
  Future<void> dispose() async {
    await unsubscribe();
    await _movementController.close();
  }
}