import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:infinitime_dfu_library/infinitime_dfu_library.dart';
import 'package:infinitime_dfu_library/src/services/movement_service.dart';

// =================== TYPES DE CALLBACKS ===================

typedef BatteryCallback = void Function(int batteryLevel);
typedef HeartRateCallback = void Function(int heartRate);
typedef StepCountCallback = void Function(int steps);
typedef MotionCallback = void Function(Map<String, int> motion);
typedef TemperatureCallback = void Function(double temperature);
typedef ConnectionCallback = void Function(InfiniTimeConnectionState state);
typedef MovementCallback = void Function(MovementData movement);

// =================== CLASSES DE PROGRESSION ===================

class DfuProgress {
  final int percent;
  final String phase;
  final int bytesTransferred;
  final int totalBytes;
  final String? error;
  final int part;
  final int totalParts;
  final double speedKbps;
  final double avgKbps;

  const DfuProgress({
    required this.percent,
    required this.phase,
    this.bytesTransferred = 0,
    this.totalBytes = 0,
    this.error,
    this.part = 0,
    this.totalParts = 0,
    this.speedKbps = 0,
    this.avgKbps = 0,
  });
}

class BlefsProgress {
  final int percent;
  final String phase;
  final int bytesTransferred;
  final int totalBytes;
  final String? error;
  final int? currentChunk;
  final int? totalChunks;

  const BlefsProgress({
    required this.percent,
    required this.phase,
    this.bytesTransferred = 0,
    this.totalBytes = 0,
    this.error,
    this.currentChunk,
    this.totalChunks,
  });
}

// =================== SESSION INFINITIME COMPLÈTE ===================

/// Session de communication robuste avec un appareil InfiniTime/PineTime
class InfiniTimeSession {
  final FlutterReactiveBle _ble;
  final String _deviceId;
  final DfuServiceManager _dfuManager;

  // État de connexion
  DeviceConnectionState _connState = DeviceConnectionState.disconnected;

  bool get isConnected => _connState == DeviceConnectionState.connected;

  String get deviceId => _deviceId;

  // Connexion
  StreamSubscription<ConnectionStateUpdate>? _connSub;
  Completer<bool>? _connectCompleter;
  int _negotiatedMtu = 20;

  // Mapping caractéristique -> service
  final Map<Uuid, Uuid> _charToService = {};

  // File d'écriture avec retry
  final _writeQ = StreamController<Future<void> Function()>();
  StreamSubscription? _writeWorker;

  // DFU et BLEFS
  bool _dfuRunning = false;
  bool _blefsRunning = false;

  // Souscriptions internes
  final Map<String, StreamSubscription<List<int>>> _subscriptions = {};

  // Callbacks
  BatteryCallback? _onBatteryChanged;
  HeartRateCallback? _onHeartRateChanged;
  StepCountCallback? _onStepCountChanged;
  MotionCallback? _onMotionChanged;
  TemperatureCallback? _onTemperatureChanged;
  ConnectionCallback? _onConnectionChanged;
  MovementCallback? _onMovementChanged;

  // StreamControllers
  final _connectionController =
      StreamController<InfiniTimeConnectionState>.broadcast();
  final _batteryController = StreamController<int>.broadcast();
  final _heartRateController = StreamController<int>.broadcast();
  final _stepCountController = StreamController<int>.broadcast();
  final _motionController = StreamController<Map<String, int>>.broadcast();
  final _temperatureController = StreamController<double>.broadcast();
  final _movementController = StreamController<MovementData>.broadcast();
  final _dfuProgressController = StreamController<DfuProgress>.broadcast();
  final _blefsProgressController = StreamController<BlefsProgress>.broadcast();
  final _musicEventsController = StreamController<int>.broadcast();
  final _callResponsesController = StreamController<int>.broadcast();

  // Streams publics (noms longs)
  Stream<InfiniTimeConnectionState> get connectionStream =>
      _connectionController.stream;

  Stream<int> get batteryStream => _batteryController.stream;

  Stream<int> get heartRateStream => _heartRateController.stream;

  Stream<int> get stepCountStream => _stepCountController.stream;

  Stream<Map<String, int>> get motionStream => _motionController.stream;

  Stream<double> get temperatureStream => _temperatureController.stream;

  Stream<MovementData> get movementStream => _movementController.stream;

  Stream<DfuProgress> get dfuProgress => _dfuProgressController.stream;

  Stream<BlefsProgress> get blefsProgress => _blefsProgressController.stream;

  Stream<int> get musicEvents => _musicEventsController.stream;

  Stream<int> get callResponses => _callResponsesController.stream;

  // Streams publics (noms courts - alias pour bloc)
  Stream<int> get battery => _batteryController.stream;

  Stream<int> get heartRate => _heartRateController.stream;

  Stream<int> get steps => _stepCountController.stream;

  Stream<List<int>> get motion => _motionController.stream.map(
    (m) => [m['x'] ?? 0, m['y'] ?? 0, m['z'] ?? 0],
  );

  Stream<double> get temperature => _temperatureController.stream;

  // Throttle mouvement
  DateTime _lastMotionEmit = DateTime.fromMillisecondsSinceEpoch(0);
  Duration _motionMinInterval = const Duration(milliseconds: 120);

  // MovementService
  MovementService? _movementService;

  InfiniTimeSession(this._ble, this._deviceId)
    : _dfuManager = DfuServiceManager(_ble);

  // =================== CALLBACKS ===================

  void onMovementChanged(MovementCallback? callback) {
    _onMovementChanged = callback;
  }

  void onBatteryChanged(BatteryCallback? callback) {
    _onBatteryChanged = callback;
  }

  void onHeartRateChanged(HeartRateCallback? callback) {
    _onHeartRateChanged = callback;
  }

  void onStepCountChanged(StepCountCallback? callback) {
    _onStepCountChanged = callback;
  }

  void onMotionChanged(MotionCallback? callback) {
    _onMotionChanged = callback;
  }

  void onTemperatureChanged(TemperatureCallback? callback) {
    _onTemperatureChanged = callback;
  }

  void onConnectionChanged(ConnectionCallback? callback) {
    _onConnectionChanged = callback;
  }

  set motionMinInterval(Duration interval) {
    _motionMinInterval = interval;
  }

  // =================== CONNEXION ROBUSTE ===================

  /// Connecte à l'appareil et initialise les souscriptions
  Future<bool> connectAndSetup() async {
    try {
      // Éviter les connexions multiples
      if (_connectCompleter != null && !_connectCompleter!.isCompleted) {
        debugPrint('[BLE] Connexion déjà en cours, attente...');
        return await _connectCompleter!.future;
      }

      // Nettoyer connexion précédente
      await _disposeConn();
      _connectCompleter = Completer<bool>();

      _updateConnectionState(InfiniTimeConnectionState.connecting);
      debugPrint('[BLE] ========================================');
      debugPrint('[BLE] Début connexion à $_deviceId');
      debugPrint('[BLE] ========================================');

      _connSub = _ble
          .connectToDevice(
            id: _deviceId,
            connectionTimeout: const Duration(seconds: 45),
          )
          .listen(
            (update) async {
              _connState = update.connectionState;
              _updateConnectionState(
                _mapConnectionState(update.connectionState),
              );

              debugPrint('[BLE] État: ${update.connectionState}');

              if (update.connectionState == DeviceConnectionState.connected) {
                try {
                  debugPrint('[BLE] ─────────────────────────────────');
                  debugPrint('[BLE] CONNECTÉ - Initialisation...');
                  debugPrint('[BLE] ─────────────────────────────────');

                  // ÉTAPE 1: Stabilité initiale
                  debugPrint('[BLE] [1/6] Stabilité initiale (500ms)...');
                  await Future.delayed(const Duration(milliseconds: 500));

                  // ÉTAPE 2: Découvrir les services
                  debugPrint('[BLE] [2/6] Découverte des services...');
                  await _discoverAndResolve();
                  debugPrint(
                    '[BLE] Caractéristiques résolues: ${_charToService.length}',
                  );

                  // ÉTAPE 3: Attendre post-découverte
                  debugPrint('[BLE] [3/6] Stabilisation (500ms)...');
                  await Future.delayed(const Duration(milliseconds: 500));

                  // ÉTAPE 4: Négociation MTU - COMME DANS L'ORIGINAL
                  debugPrint('[BLE] [4/6] Négociation MTU...');
                  try {
                    _negotiatedMtu = await _ble.requestMtu(
                      deviceId: _deviceId,
                      mtu: 20,
                    );
                    debugPrint('[BLE] MTU négocié: $_negotiatedMtu bytes');
                  } catch (e) {
                    debugPrint('[BLE] Fallback MTU 20: $e');
                    _negotiatedMtu = 20;
                  }

                  // ÉTAPE 5: Stabilité critique POST-MTU (1000ms)
                  debugPrint('[BLE] [5/6] Stabilisation post-MTU (1000ms)...');
                  await Future.delayed(const Duration(milliseconds: 1000));

                  // ÉTAPE 6: Démarrer les souscriptions
                  debugPrint('[BLE] [6/6] Souscriptions...');
                  _startWriteWorker();
                  await _startSubscriptions();

                  // Confirmation
                  if (!_connectCompleter!.isCompleted) {
                    debugPrint('[BLE] ═════════════════════════════════');
                    debugPrint('[BLE] CONNEXION RÉUSSIE');
                    debugPrint('[BLE] Device: $_deviceId');
                    debugPrint('[BLE] MTU: $_negotiatedMtu');
                    debugPrint(
                      '[BLE] Caractéristiques: ${_charToService.length}',
                    );
                    debugPrint('[BLE] ═════════════════════════════════');
                    _connectCompleter!.complete(true);
                  }
                } catch (e) {
                  debugPrint('[BLE] ERREUR INITIALISATION: $e');
                  await _cancelSubscriptions();

                  if (!_connectCompleter!.isCompleted) {
                    _connectCompleter!.complete(false);
                  }
                }
              } else if (update.connectionState ==
                  DeviceConnectionState.disconnected) {
                debugPrint('[BLE] DÉCONNEXION DÉTECTÉE');
                await _cancelSubscriptions();

                if (!_connectCompleter!.isCompleted) {
                  _connectCompleter!.complete(false);
                }
              }
            },
            onError: (e) async {
              debugPrint('[BLE] ERREUR LISTENER: $e');
              await _cancelSubscriptions();

              if (!_connectCompleter!.isCompleted) {
                _connectCompleter!.complete(false);
              }
            },
            onDone: () {
              debugPrint('[BLE] Stream listener terminé');
              if (!_connectCompleter!.isCompleted) {
                _connectCompleter!.complete(false);
              }
            },
          );

      final result = await _connectCompleter!.future;
      return result;
    } catch (e) {
      debugPrint('[BLE] ERREUR: $e');
      _updateConnectionState(InfiniTimeConnectionState.disconnected);
      return false;
    }
  }

  // =================== DÉCOUVERTE ET RÉSOLUTION ===================

  Future<void> _discoverAndResolve() async {
    if (!isConnected) {
      throw StateError('Appareil non connecté');
    }

    try {
      await _ble.discoverAllServices(_deviceId);
    } catch (e) {
      debugPrint('[BLE] Erreur découverte: $e');
      throw StateError('Impossible de découvrir les services: $e');
    }

    final services = await _ble.getDiscoveredServices(_deviceId);

    if (services.isEmpty) {
      throw StateError('Aucun service découvert');
    }

    _charToService.clear();
    _charToService.addEntries(
      services.expand(
        (s) => s.characteristics.map((c) => MapEntry(c.id, s.id)),
      ),
    );

    debugPrint('[BLE] Services découverts: ${services.length}');
    debugPrint('[BLE] Caractéristiques résolues: ${_charToService.length}');

    // Vérifier essentielles
    final mustHave = <Uuid>[
      InfiniTimeUuids.batteryLevel,
      InfiniTimeUuids.hrMeasurement,
      InfiniTimeUuids.musicEvent,
      InfiniTimeUuids.motionStepCount,
    ];

    int foundCount = 0;
    for (final uuid in mustHave) {
      if (_charToService.containsKey(uuid)) {
        foundCount++;
      }
    }
    debugPrint('[BLE] Essentielles: $foundCount/${mustHave.length}');
  }

  // =================== SANTÉ CONNEXION ===================

  Future<bool> isConnectionHealthy() async {
    if (!isConnected) return false;

    try {
      if (_charToService.containsKey(InfiniTimeUuids.batteryLevel)) {
        await _ble.readCharacteristic(_qc(InfiniTimeUuids.batteryLevel));
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('[BLE] Health check échoué: $e');
      return false;
    }
  }

  Future<void> waitForStableConnection({
    Duration timeout = const Duration(seconds: 5),
  }) async {
    final startTime = DateTime.now();

    while (DateTime.now().difference(startTime) < timeout) {
      if (await isConnectionHealthy()) {
        final elapsed = DateTime.now().difference(startTime).inMilliseconds;
        debugPrint('[BLE] Connexion stable après ${elapsed}ms');
        return;
      }
      await Future.delayed(const Duration(milliseconds: 200));
    }

    throw TimeoutException('Connexion pas stable après ${timeout.inSeconds}s');
  }

  // =================== FILE D'ÉCRITURE AVEC RETRY ===================

  void _startWriteWorker() {
    _writeWorker ??= _writeQ.stream
        .asyncMap((task) async {
          int attempt = 0;
          const maxAttempts = 3;

          while (true) {
            try {
              await task();
              return;
            } catch (e) {
              attempt++;
              if (attempt >= maxAttempts) {
                debugPrint('[BLE] Échec après $maxAttempts tentatives: $e');
                rethrow;
              }

              final delayMs = 200 * attempt;
              debugPrint(
                '[BLE] Retry $attempt/$maxAttempts (attente ${delayMs}ms)',
              );
              await Future.delayed(Duration(milliseconds: delayMs));
            }
          }
        })
        .listen(
          (_) {},
          onError: (e) {
            debugPrint('[BLE] Erreur worker: $e');
          },
        );
  }

  Future<void> _enqueueWrite(Future<void> Function() task) async {
    if (!_writeQ.isClosed) {
      _writeQ.add(task);
    }
  }

  Future<void> _writeWithResponse(
    QualifiedCharacteristic qc,
    List<int> value,
  ) async {
    const overhead = 3;
    final chunkSize = math.max(20, _negotiatedMtu - overhead);

    for (int i = 0; i < value.length; i += chunkSize) {
      final part = value.sublist(i, math.min(value.length, i + chunkSize));

      try {
        await _ble.writeCharacteristicWithResponse(qc, value: part);
        if (i + chunkSize < value.length) {
          await Future.delayed(const Duration(milliseconds: 100));
        }
      } catch (e) {
        debugPrint('[BLE] Erreur écriture: $e');
        rethrow;
      }
    }
  }

  /// Écrit sans chunking (pour les notifications ANS)
  Future<void> _writeWithoutChunking(
    QualifiedCharacteristic qc,
    List<int> value,
  ) async {
    try {
      await _ble.writeCharacteristicWithResponse(qc, value: value);
    } catch (e) {
      debugPrint('[BLE] Erreur écriture (no chunking): $e');
      rethrow;
    }
  }

  QualifiedCharacteristic _qc(Uuid charId) {
    final svc = _charToService[charId];
    if (svc == null) {
      throw StateError('Caractéristique non résolue: $charId');
    }
    return QualifiedCharacteristic(
      serviceId: svc,
      characteristicId: charId,
      deviceId: _deviceId,
    );
  }

  // =================== SOUSCRIPTIONS ===================

  Future<void> _startSubscriptions() async {
    await _cancelSubscriptions();

    // Initialiser MovementService
    _movementService = MovementService(_ble, _deviceId);
    _movementService!.onMovementChanged((data) {
      _movementController.add(data);
      _onMovementChanged?.call(data);
    });

    final subs = [
      ('battery', InfiniTimeUuids.batteryLevel, _subscribeToBattery),
      ('heartRate', InfiniTimeUuids.hrMeasurement, _subscribeToHeartRate),
      ('stepCount', InfiniTimeUuids.motionStepCount, _subscribeToStepCount),
      ('motion', InfiniTimeUuids.motionValues, _subscribeToMotion),
      ('musicEvent', InfiniTimeUuids.musicEvent, _subscribeToMusicEvents),
      ('callEvent', InfiniTimeUuids.notifEventChar, _subscribeToCallEvents),
    ];

    for (final (name, uuid, subFn) in subs) {
      if (_charToService.containsKey(uuid)) {
        try {
          await subFn();
          debugPrint('[BLE] Souscription $name active');
        } catch (e) {
          debugPrint('[BLE] Erreur souscription $name: $e');
        }
      }
    }

    // Souscrire au MovementService seulement si la caractéristique est disponible
    if (_charToService.containsKey(InfiniTimeUuids.movementData)) {
      try {
        await _movementService?.subscribe();
        debugPrint('[BLE] MovementService abonné');
      } catch (e) {
        debugPrint('[BLE] Erreur MovementService: $e');
      }
    } else {
      debugPrint('[BLE] MovementService non disponible (caractéristique absente)');
    }
  }

  Future<void> _subscribeToBattery() async {
    final subscription = _ble
        .subscribeToCharacteristic(_qc(InfiniTimeUuids.batteryLevel))
        .listen((data) {
          if (data.isNotEmpty && !_batteryController.isClosed) {
            final level = DataParser.parseBatteryLevel(data);
            _batteryController.add(level);
            _onBatteryChanged?.call(level);
          }
        }, onError: (e) => debugPrint('[BLE] Erreur batterie: $e'));
    _subscriptions['battery'] = subscription;
  }

  Future<void> _subscribeToHeartRate() async {
    final subscription = _ble
        .subscribeToCharacteristic(_qc(InfiniTimeUuids.hrMeasurement))
        .listen((data) {
          if (data.isNotEmpty && !_heartRateController.isClosed) {
            final hr = DataParser.parseHeartRate(data);
            if (hr > 0) {
              _heartRateController.add(hr);
              _onHeartRateChanged?.call(hr);
            }
          }
        }, onError: (e) => debugPrint('[BLE] Erreur HR: $e'));
    _subscriptions['heartRate'] = subscription;
  }

  Future<void> _subscribeToStepCount() async {
    final subscription = _ble
        .subscribeToCharacteristic(_qc(InfiniTimeUuids.motionStepCount))
        .listen((data) {
          if (data.length >= 4 && !_stepCountController.isClosed) {
            final steps = DataParser.parseStepCount(data);
            _stepCountController.add(steps);
            _onStepCountChanged?.call(steps);
          }
        }, onError: (e) => debugPrint('[BLE] Erreur pas: $e'));
    _subscriptions['stepCount'] = subscription;
  }

  Future<void> _subscribeToMotion() async {
    final subscription = _ble
        .subscribeToCharacteristic(_qc(InfiniTimeUuids.motionValues))
        .listen((data) {
          if (data.length < 6) return;

          int i16(int lo, int hi) {
            final v = (hi << 8) | lo;
            return v >= 0x8000 ? v - 0x10000 : v;
          }

          final now = DateTime.now();
          if (now.difference(_lastMotionEmit) >= _motionMinInterval) {
            _lastMotionEmit = now;
            if (!_motionController.isClosed) {
              final motion = {
                'x': i16(data[0], data[1]),
                'y': i16(data[2], data[3]),
                'z': i16(data[4], data[5]),
              };
              _motionController.add(motion);
              _onMotionChanged?.call(motion);
            }
          }
        }, onError: (e) => debugPrint('[BLE] Erreur motion: $e'));
    _subscriptions['motion'] = subscription;
  }

  Future<void> _subscribeToMusicEvents() async {
    final subscription = _ble
        .subscribeToCharacteristic(_qc(InfiniTimeUuids.musicEvent))
        .listen((data) {
          if (!_musicEventsController.isClosed) {
            final eventValue = data.isEmpty ? -1 : data.first;
            _musicEventsController.add(eventValue);
          }
        }, onError: (e) => debugPrint('[BLE] Erreur music: $e'));
    _subscriptions['musicEvents'] = subscription;
  }

  Future<void> _subscribeToCallEvents() async {
    final subscription = _ble
        .subscribeToCharacteristic(_qc(InfiniTimeUuids.notifEventChar))
        .listen((data) {
          if (!_callResponsesController.isClosed) {
            _callResponsesController.add(data.isEmpty ? -1 : data.first);
          }
        }, onError: (e) => debugPrint('[BLE] Erreur call: $e'));
    _subscriptions['callEvents'] = subscription;
  }

  Future<void> _subscribeToTemperature() async {
    final subscription = _ble
        .subscribeToCharacteristic(_qc(InfiniTimeUuids.weatherData))
        .listen((data) {
          if (!_temperatureController.isClosed) {
            final temp = DataParser.parseTemperature(data);
            _temperatureController.add(temp);
            _onTemperatureChanged?.call(temp);
          }
        }, onError: (e) => debugPrint('[BLE] Erreur temp: $e'));
    _subscriptions['temperature'] = subscription;
  }

  // =================== LECTURES ===================

  Future<Map<String, String?>> readDeviceInfo() async {
    if (!isConnected) {
      return {
        'manufacturer': null,
        'model': null,
        'firmware': null,
        'hardware': null,
      };
    }

    Future<String?> read(Uuid charId) async {
      try {
        if (!_charToService.containsKey(charId)) {
          return null;
        }
        final d = await _ble.readCharacteristic(_qc(charId));
        return d.isEmpty ? null : utf8.decode(d, allowMalformed: true).trim();
      } catch (e) {
        debugPrint('[BLE] Erreur lecture: $e');
        return null;
      }
    }

    await Future.delayed(const Duration(milliseconds: 200));

    return {
      'manufacturer': await read(InfiniTimeUuids.disManufacturer),
      'model': await read(InfiniTimeUuids.disModelNumber),
      'firmware': await read(InfiniTimeUuids.disFirmwareRev),
      'hardware': await read(InfiniTimeUuids.disHardwareRev),
    };
  }

  Future<int?> readBattery() async {
    try {
      if (!_charToService.containsKey(InfiniTimeUuids.batteryLevel)) {
        return null;
      }
      final d = await _ble.readCharacteristic(
        _qc(InfiniTimeUuids.batteryLevel),
      );
      return d.isNotEmpty ? DataParser.parseBatteryLevel(d) : null;
    } catch (e) {
      debugPrint('[BLE] Erreur batterie: $e');
      return null;
    }
  }

  // =================== TIME ===================

  Future<void> syncTimeUtc(DateTime utc) async {
    if (!_charToService.containsKey(InfiniTimeUuids.ctsCurrentTime)) {
      throw StateError('CTS non disponible');
    }

    final packet = [
      utc.year & 0xFF,
      (utc.year >> 8) & 0xFF,
      utc.month,
      utc.day,
      utc.hour,
      utc.minute,
      utc.second,
      utc.weekday % 7,
      0,
      0,
    ];

    await _enqueueWrite(
      () => _writeWithResponse(_qc(InfiniTimeUuids.ctsCurrentTime), packet),
    );
  }

  /// Envoie l'heure avec possibilité de fuseau horaire
  Future<void> sendTime({
    DateTime? dateTime,
    Duration? timeZoneOffset, // ex: Duration(hours: 2) pour UTC+2
  }) async {
    // Heure locale par défaut
    DateTime localTime = dateTime ?? DateTime.now();

    Duration offset = timeZoneOffset ?? localTime.timeZoneOffset;

    // Convertir l'heure locale vers UTC en tenant compte du fuseau voulu
    DateTime utcTime = localTime.subtract(offset);

    await syncTimeUtc(utcTime);
  }

  // =================== MUSIC ===================

  Future<void> musicSetPlaying(bool playing) async {
    if (!_charToService.containsKey(InfiniTimeUuids.musicStatus)) {
      throw StateError('Music service non disponible');
    }

    await _enqueueWrite(
      () => _writeWithResponse(_qc(InfiniTimeUuids.musicStatus), [
        playing ? 1 : 0,
      ]),
    );
  }

  Future<void> musicSetMeta({
    String? artist,
    String? track,
    String? album,
  }) async {
    if (artist != null &&
        _charToService.containsKey(InfiniTimeUuids.musicArtist)) {
      await _enqueueWrite(
        () => _writeWithResponse(
          _qc(InfiniTimeUuids.musicArtist),
          utf8.encode(artist),
        ),
      );
    }
    if (track != null &&
        _charToService.containsKey(InfiniTimeUuids.musicTrack)) {
      await _enqueueWrite(
        () => _writeWithResponse(
          _qc(InfiniTimeUuids.musicTrack),
          utf8.encode(track),
        ),
      );
    }
    if (album != null &&
        _charToService.containsKey(InfiniTimeUuids.musicAlbum)) {
      await _enqueueWrite(
        () => _writeWithResponse(
          _qc(InfiniTimeUuids.musicAlbum),
          utf8.encode(album),
        ),
      );
    }
  }

  // =================== NAVIGATION ===================

  Future<void> navFlagsSet(int flags) async {
    if (!_charToService.containsKey(InfiniTimeUuids.navFlags)) {
      throw StateError('Navigation non disponible');
    }

    await _enqueueWrite(
      () => _writeWithResponse(_qc(InfiniTimeUuids.navFlags), [flags & 0xFF]),
    );
  }

  Future<void> navNarrativeSet(String text) async {
    if (!_charToService.containsKey(InfiniTimeUuids.navNarrative)) {
      throw StateError('Navigation non disponible');
    }

    await _enqueueWrite(
      () => _writeWithResponse(
        _qc(InfiniTimeUuids.navNarrative),
        utf8.encode(text),
      ),
    );
  }

  Future<void> navManDistSet(String text) async {
    if (!_charToService.containsKey(InfiniTimeUuids.navManDist)) {
      throw StateError('Navigation non disponible');
    }

    await _enqueueWrite(
      () => _writeWithResponse(
        _qc(InfiniTimeUuids.navManDist),
        utf8.encode(text),
      ),
    );
  }

  Future<void> navProgressSet(int progress) async {
    if (!_charToService.containsKey(InfiniTimeUuids.navProgress)) {
      throw StateError('Navigation non disponible');
    }

    await _enqueueWrite(
      () => _writeWithResponse(_qc(InfiniTimeUuids.navProgress), [
        progress.clamp(0, 100),
      ]),
    );
  }

  Future<void> navTurnLeft() async => navFlagsSet(0x01);

  Future<void> navTurnRight() async => navFlagsSet(0x02);

  Future<void> navTurnSharpLeft() async => navFlagsSet(0x04);

  Future<void> navTurnSharpRight() async => navFlagsSet(0x08);

  Future<void> navTurnSlightLeft() async => navFlagsSet(0x10);

  Future<void> navTurnSlightRight() async => navFlagsSet(0x20);

  Future<void> navContinue() async => navFlagsSet(0x40);

  Future<void> navUTurn() async => navFlagsSet(0x80);

  Future<void> navFinish() async => navFlagsSet(0x00);

  // =================== WEATHER ===================

  Future<void> weatherWrite(Uint8List bytes) async {
    if (!_charToService.containsKey(InfiniTimeUuids.weatherData)) {
      throw StateError('Weather service non disponible');
    }

    await _enqueueWrite(
      () => _writeWithResponse(_qc(InfiniTimeUuids.weatherData), bytes),
    );
  }

  Future<void> sendWeatherData({
    required int temperature,
    required int condition,
    int? minTemp,
    int? maxTemp,
  }) async {
    List<int> temperatureToBytes(int temp) {
      final tempCelsius = temp.clamp(-128, 127);
      return [tempCelsius & 0xFF, (tempCelsius >> 8) & 0xFF];
    }

    final data = <int>[
      ...temperatureToBytes(temperature),
      condition & 0xFF,
      if (minTemp != null) ...temperatureToBytes(minTemp),
      if (maxTemp != null) ...temperatureToBytes(maxTemp),
    ];

    await weatherWrite(Uint8List.fromList(data));
  }

  // =================== NOTIFICATIONS ===================

  /// Envoie une notification à la montre via le service ANS (Alert Notification Service)
  ///
  /// [title] - Titre de la notification
  /// [message] - Corps du message de la notification (optionnel)
  /// [category] - Catégorie de l'alerte (par défaut: 0 = Simple Alert)
  ///
  /// Format du protocole InfiniTime ANS:
  /// - Byte 0: Category ID (0x00 = Simple Alert, 0x03 = Call, etc.)
  /// - Byte 1: Nombre d'alertes (toujours 1)
  /// - Byte 2: Séparateur null (0x00)
  /// - Bytes 3+: Message UTF-8 (titre\0message si message fourni)
  ///
  /// Catégories disponibles:
  /// - 0: Simple Alert
  /// - 1: Email
  /// - 2: News
  /// - 3: Call Notification
  /// - 4: Missed Call
  /// - 5: SMS/MMS
  /// - 6: Voicemail
  /// - 7: Schedule
  /// - 8: High Priority Alert
  /// - 9: Instant Message
  Future<void> sendNotification({
    required String title,
    String? message,
    int category = 0, // 0 = Simple Alert
  }) async {
    if (!_charToService.containsKey(InfiniTimeUuids.ansNewAlert)) {
      throw StateError('Alert Notification Service (ANS) non disponible');
    }

    // Construire le message: titre\0message (si message fourni)
    final fullMessage = message != null ? '$title\x00$message' : title;
    final messageBytes = utf8.encode(fullMessage);

    // Format du paquet selon la spec ANS d'InfiniTime:
    // <category><amount>\x00<data>
    final packet = <int>[
      category & 0xFF,  // Category
      0x01,             // Alert count: 1
      0x00,             // Séparateur null
      ...messageBytes,  // Message UTF-8
    ];

    // Les notifications ANS doivent être envoyées en un seul bloc
    // (pas de chunking) pour éviter qu'elles apparaissent fragmentées
    await _enqueueWrite(
      () => _writeWithoutChunking(
        _qc(InfiniTimeUuids.ansNewAlert),
        packet,
      ),
    );
  }

  // =================== BLEFS (WATCHFACE) ===================


  Future<String?> blefsReadVersion() async {
    try {
      if (!_charToService.containsKey(InfiniTimeUuids.blefsVersion)) {
        return null;
      }
      final d = await _ble.readCharacteristic(
        _qc(InfiniTimeUuids.blefsVersion),
      );
      return d.isEmpty ? null : utf8.decode(d);
    } catch (e) {
      debugPrint('[BLE] Erreur BLEFS version: $e');
      return null;
    }
  }

  Future<void> blefsWriteRaw(Uint8List bytes) async {
    if (!_charToService.containsKey(InfiniTimeUuids.blefsTransfer)) {
      throw StateError('BLEFS non disponible');
    }

    await _enqueueWrite(
      () => _writeWithResponse(_qc(InfiniTimeUuids.blefsTransfer), bytes),
    );
  }

  Future<void> installWatchfaceViaBLEFS(
    Uint8List watchfaceData, {
    String? name,
  }) async {
    if (_blefsRunning) {
      throw StateError('Installation BLEFS en cours');
    }

    if (_dfuRunning) {
      throw StateError('Un DFU est en cours');
    }

    _blefsRunning = true;

    try {
      _blefsProgressController.add(
        const BlefsProgress(percent: 0, phase: 'Initialisation BLEFS'),
      );

      final chunkSize = math.max(20, _negotiatedMtu - 3);
      final totalChunks = (watchfaceData.length / chunkSize).ceil();

      debugPrint(
        '[BLEFS] Watchface: ${watchfaceData.length} bytes, '
        '$totalChunks chunks de $chunkSize bytes',
      );

      for (int i = 0; i < totalChunks; i++) {
        final int start = i * chunkSize;
        final int end = math.min(start + chunkSize, watchfaceData.length);
        final chunk = watchfaceData.sublist(start, end);

        final progress = ((i / totalChunks) * 95).round();

        _blefsProgressController.add(
          BlefsProgress(
            percent: progress,
            phase: 'Chunk ${i + 1}/$totalChunks',
            bytesTransferred: end,
            totalBytes: watchfaceData.length,
            currentChunk: i + 1,
            totalChunks: totalChunks,
          ),
        );

        try {
          await blefsWriteRaw(chunk);

          if (i < totalChunks - 1) {
            final delayMs = watchfaceData.length > 50000 ? 30 : 20;
            await Future.delayed(Duration(milliseconds: delayMs));
          }
        } catch (e) {
          throw Exception('Erreur chunk ${i + 1}/$totalChunks: $e');
        }
      }

      _blefsProgressController.add(
        BlefsProgress(
          percent: 100,
          phase: 'Watchface installée',
          bytesTransferred: watchfaceData.length,
          totalBytes: watchfaceData.length,
          currentChunk: totalChunks,
          totalChunks: totalChunks,
        ),
      );
    } catch (e) {
      _blefsProgressController.add(
        BlefsProgress(
          percent: 0,
          phase: 'Erreur: $e',
          bytesTransferred: 0,
          totalBytes: watchfaceData.length,
          error: e.toString(),
        ),
      );
      rethrow;
    } finally {
      _blefsRunning = false;
    }
  }

  // =================== DFU (FIRMWARE UPDATE) ===================
  // ============================================================
  // IMPLÉMENTATION EXACTE DE LA LOGIQUE ORIGINALE
  // ============================================================

  /// Démarre une mise à jour firmware complète
  /// Respecte exactement la logique du DfuServiceManager original
  Future<void> startSystemFirmwareDfu(
    String firmwarePath, {
    required bool reconnectOnComplete,
  }) async {
    if (_dfuRunning) {
      throw StateError('Un DFU est déjà en cours');
    }

    if (_blefsRunning) {
      throw StateError('Une installation BLEFS est en cours');
    }

    try {
      _dfuRunning = true;

      // === PRÉPARATION DFU (Phase initiale) ===
      _dfuProgressController.add(
        const DfuProgress(
          percent: 2,
          part: 0,
          totalParts: 0,
          speedKbps: 0,
          avgKbps: 0,
          phase: 'Préparation DFU...',
        ),
      );

      debugPrint('[DFU] ════════════════════════════════════════');
      debugPrint('[DFU] DÉBUT MISE À JOUR FIRMWARE');
      debugPrint('[DFU] ════════════════════════════════════════');

      // === ÉTAPE CRITIQUE: DÉCONNECTER LA SESSION PRINCIPALE ===
      debugPrint('[DFU] Déconnexion session principale...');
      await _cancelSubscriptions();
      await _disposeConn();

      // Laisser le temps au BLE de se stabiliser
      await Future.delayed(const Duration(seconds: 2));

      debugPrint('[DFU] Session principale déconnectée');

      // === CHARGER LE FIRMWARE ===
      _dfuProgressController.add(
        const DfuProgress(
          percent: 5,
          part: 0,
          totalParts: 0,
          speedKbps: 0,
          avgKbps: 0,
          phase: 'Chargement firmware...',
        ),
      );

      debugPrint('[DFU] Chargement firmware depuis: $firmwarePath');
      final dfuFiles = await _dfuManager.loadFirmwareFromAssets(firmwarePath);
      debugPrint('[DFU] Firmware chargé:');
      debugPrint('[DFU]   - Binaire: ${dfuFiles.firmware.length} bytes');
      debugPrint('[DFU]   - Init packet: ${dfuFiles.initPacket.length} bytes');

      // === CONFIGURER LES LISTENERS DE PROGRESSION ===
      _dfuStatusSub = _dfuManager.statusStream.listen(
        (status) {
          final phase = _mapDfuStatusToPhase(status);
          if (phase.isNotEmpty) {
            final percent = _getPhasePercent(phase);
            if (percent >= 0) {
              _dfuProgressController.add(
                DfuProgress(
                  phase: phase,
                  percent: percent,
                  part: 1,
                  totalParts: 1,
                  speedKbps: 0,
                  avgKbps: 0,
                ),
              );
            }
          }
        },
        onError: (e) {
          debugPrint('[DFU] Erreur stream: $e');
        },
      );

      _dfuProgressSub = _dfuManager.progressStream.listen((progress) {
        final percent = (progress * 80).round() + 10;
        _dfuProgressController.add(
          DfuProgress(
            phase: 'Transfert firmware (${(progress * 100).round()}%)',
            percent: percent,
            part: 1,
            totalParts: 1,
            speedKbps: 0,
            avgKbps: 0,
          ),
        );
      });

      // === CONNEXION EN MODE DFU ===
      _dfuProgressController.add(
        const DfuProgress(
          percent: 5,
          part: 0,
          totalParts: 0,
          speedKbps: 0,
          avgKbps: 0,
          phase: 'Connexion DFU...',
        ),
      );

      debugPrint('[DFU] Tentative connexion DFU avec retries...');
      final connected = await _dfuManager.connectToDevice(deviceId);

      if (!connected) {
        throw Exception('Impossible de se connecter en mode DFU');
      }

      debugPrint('[DFU] Connecté en mode DFU');

      // === TRANSFERT FIRMWARE ===
      // Respecte la logique exacte du DfuServiceManager
      final success = await _dfuManager.performCompleteFirmwareUpdate(
        dfuFiles,
        compatibilityMode: true,
        //onProgress: (progress) => debugPrint('[DFU] Progrès: ${(progress * 100).toInt()}%'),
        //onStatusUpdate: (status) => debugPrint('[DFU] $status'),
      );

      if (!success) {
        throw Exception('Mise à jour firmware échouée');
      }

      debugPrint('[DFU] Transfert firmware réussi');

      _dfuProgressController.add(
        const DfuProgress(
          phase: 'Firmware installé avec succès',
          percent: 100,
          part: 1,
          totalParts: 1,
          speedKbps: 0,
          avgKbps: 0,
        ),
      );

      // === RECONNEXION APRÈS MISE À JOUR ===
      if (reconnectOnComplete) {
        _dfuProgressController.add(
          const DfuProgress(
            phase: 'Reconnexion...',
            percent: 100,
            part: 1,
            totalParts: 1,
            speedKbps: 0,
            avgKbps: 0,
          ),
        );

        // Attendre que la montre redémarre (8 secondes)
        debugPrint('[DFU] Attente redémarrage (8s)...');
        await Future.delayed(const Duration(seconds: 8));

        try {
          debugPrint('[DFU] Reconnexion en cours...');

          int reconnectAttempts = 0;
          const maxReconnectAttempts = 3;
          bool reconnected = false;

          while (reconnectAttempts < maxReconnectAttempts && !reconnected) {
            try {
              reconnected = await connectAndSetup();
              if (reconnected) break;
            } catch (e) {
              debugPrint(
                '[DFU] Tentative reconnexion ${reconnectAttempts + 1} échouée: $e',
              );
              reconnectAttempts++;
              if (reconnectAttempts < maxReconnectAttempts) {
                await Future.delayed(const Duration(seconds: 2));
              }
            }
          }

          if (reconnected) {
            debugPrint('[DFU] MISE À JOUR RÉUSSIE');
          } else {
            debugPrint(
              '[DFU] Reconnexion échouée après $maxReconnectAttempts tentatives',
            );
            debugPrint('[DFU] (Mais DFU a réussi - vérifiez manuellement)');
          }
        } catch (e) {
          debugPrint('[DFU] Erreur reconnexion: $e');
        }
      }
    } catch (e) {
      debugPrint('[DFU] ════════════════════════════════════════');
      debugPrint('[DFU] ERREUR DFU: $e');
      debugPrint('[DFU] ════════════════════════════════════════');

      _dfuProgressController.add(
        DfuProgress(
          phase: 'Erreur DFU: $e',
          percent: 0,
          part: 0,
          totalParts: 0,
          speedKbps: 0,
          avgKbps: 0,
        ),
      );
      rethrow;
    } finally {
      _dfuRunning = false;
      await _cancelDfuSubscriptions();
    }
  }

  StreamSubscription<String>? _dfuStatusSub;
  StreamSubscription<double>? _dfuProgressSub;

  Future<void> _cancelDfuSubscriptions() async {
    await _dfuStatusSub?.cancel();
    await _dfuProgressSub?.cancel();
    _dfuStatusSub = null;
    _dfuProgressSub = null;
  }

  String _mapDfuStatusToPhase(String status) {
    final s = status.toLowerCase();

    if (s.contains('initialisation') || s.contains('début')) {
      return 'Initialisation DFU';
    }
    if (s.contains('connexion')) return 'Connexion DFU';
    if (s.contains('validation')) return 'Validation firmware';
    if (s.contains('activation')) return 'Activation firmware';
    if (s.contains('redémarrage') || s.contains('reset')) return 'Redémarrage';
    if (s.contains('terminé') || s.contains('réussie')) {
      return 'Firmware installé';
    }
    if (s.contains('erreur')) return 'Erreur DFU';

    return '';
  }

  int _getPhasePercent(String phase) {
    switch (phase) {
      case 'Initialisation DFU':
        return 8;
      case 'Connexion DFU':
        return 5;
      case 'Validation firmware':
        return 92;
      case 'Activation firmware':
        return 95;
      case 'Redémarrage':
        return 98;
      case 'Firmware installé':
        return 100;
      case 'Erreur DFU':
        return 0;
      default:
        return -1;
    }
  }

  Future<void> abortSystemFirmwareDfu() async {
    if (!_dfuRunning) return;

    try {
      await _dfuManager.cancelUpdate();
    } finally {
      _dfuRunning = false;
      _dfuProgressController.add(
        const DfuProgress(
          percent: 0,
          part: 0,
          totalParts: 0,
          speedKbps: 0,
          avgKbps: 0,
          phase: 'DFU annulé',
        ),
      );
      await _cancelDfuSubscriptions();
    }
  }

  bool get isDfuRunning => _dfuRunning;

  // =================== HELPERS ===================

  InfiniTimeConnectionState _mapConnectionState(DeviceConnectionState state) {
    switch (state) {
      case DeviceConnectionState.connecting:
        return InfiniTimeConnectionState.connecting;
      case DeviceConnectionState.connected:
        return InfiniTimeConnectionState.connected;
      case DeviceConnectionState.disconnecting:
        return InfiniTimeConnectionState.disconnecting;
      case DeviceConnectionState.disconnected:
        return InfiniTimeConnectionState.disconnected;
    }
  }

  void _updateConnectionState(InfiniTimeConnectionState state) {
    if (!_connectionController.isClosed) {
      _connectionController.add(state);
      _onConnectionChanged?.call(state);
    }
  }

  // =================== NETTOYAGE ===================

  Future<void> _cancelSubscriptions() async {
    for (final sub in _subscriptions.values) {
      try {
        await sub.cancel();
      } catch (e) {
        debugPrint('[BLE] Erreur annulation: $e');
      }
    }
    _subscriptions.clear();

    try {
      await _movementService?.dispose();
      _movementService = null;
    } catch (e) {
      debugPrint('[BLE] Erreur MovementService: $e');
    }
  }

  Future<void> _disposeConn() async {
    await _connSub?.cancel();
    _connSub = null;
  }

  Future<void> disconnect() async {
    try {
      await _cancelSubscriptions();
      await _disposeConn();
      _updateConnectionState(InfiniTimeConnectionState.disconnected);
    } catch (e) {
      debugPrint('[BLE] Erreur déconnexion: $e');
    }
  }

  Future<void> dispose() async {
    await _cancelSubscriptions();
    await _cancelDfuSubscriptions();
    await _disposeConn();
    await _writeWorker?.cancel();
    await _writeQ.close();
    await _dfuManager.dispose();

    final controllers = [
      _connectionController,
      _batteryController,
      _heartRateController,
      _stepCountController,
      _motionController,
      _temperatureController,
      _movementController,
      _dfuProgressController,
      _blefsProgressController,
      _musicEventsController,
      _callResponsesController,
    ];

    for (final ctrl in controllers) {
      if (!ctrl.isClosed) {
        await ctrl.close();
      }
    }
  }
}
