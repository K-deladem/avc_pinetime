import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:infinitime_dfu_library/infinitime_dfu_library.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/app_database.dart';
import '../../extension/arm_side_extensions.dart';
import '../../models/app_settings.dart';
import '../../models/arm_side.dart';
import '../../models/connection_event.dart';
import '../../models/movement_sampling_settings.dart';
import '../../service/chart_refresh_notifier.dart';
import '../../service/watch_vibration_service.dart';
import '../../utils/app_logger.dart';
import 'handlers/handlers.dart';
import 'device_event.dart';
import 'device_state.dart';

/// DeviceBloc - Coordinateur principal pour la gestion des montres
/// Remplace DualInfiniTimeBloc avec une architecture plus modulaire
class DeviceBloc extends Bloc<DeviceEvent, DeviceState> {
  final FlutterReactiveBle ble;
  final AppDatabase _db = AppDatabase.instance;

  // ========== CONFIGURATION ==========
  int _scanTimeoutSeconds = 15;
  int _connectionTimeoutSeconds = 30;
  int _maxRetryAttempts = 5;
  MovementSamplingSettings _samplingSettings = const MovementSamplingSettings();

  // ========== HANDLERS ==========
  late final SensorDataHandler _sensorHandler;

  // ========== SESSIONS ==========
  final Map<ArmSide, InfiniTimeSession?> _sessions = {
    ArmSide.left: null,
    ArmSide.right: null,
  };

  // ========== SUBSCRIPTIONS ==========
  final Map<ArmSide, StreamSubscription?> _battSubs = {};
  final Map<ArmSide, StreamSubscription?> _stepsSubs = {};
  final Map<ArmSide, StreamSubscription?> _motionSubs = {};
  final Map<ArmSide, StreamSubscription?> _dfuSubs = {};
  final Map<ArmSide, StreamSubscription?> _connSubs = {};
  final Map<ArmSide, StreamSubscription?> _musicEventSubs = {};
  final Map<ArmSide, StreamSubscription?> _movementSubs = {};

  StreamSubscription<DiscoveredDevice>? _scanSub;
  Timer? _scanTimer;
  Timer? _bufferFlushTimer;

  // ========== FLAGS ==========
  bool _bindingsLoaded = false;
  final Map<ArmSide, bool> _connectionInProgress = {
    ArmSide.left: false,
    ArmSide.right: false,
  };
  final Map<ArmSide, DateTime?> _connectionEstablishedAt = {
    ArmSide.left: null,
    ArmSide.right: null,
  };

  // ========== RECONNECTION ==========
  final Map<ArmSide, Timer?> _reconnectTimers = {
    ArmSide.left: null,
    ArmSide.right: null,
  };
  final Map<ArmSide, int> _retries = {
    ArmSide.left: 0,
    ArmSide.right: 0,
  };

  DeviceBloc(this.ble) : super(const DeviceState()) {
    _sensorHandler = SensorDataHandler(database: _db);
    _registerHandlers();
    _startPeriodicTasks();
    _loadConfiguration();
  }

  // ========== GETTERS ==========
  int get scanTimeoutSeconds => _scanTimeoutSeconds;
  int get connectionTimeoutSeconds => _connectionTimeoutSeconds;
  InfiniTimeSession? getSession(ArmSide side) => _sessions[side];

  /// Getters pour la compatibilité avec DualInfiniTimeBloc
  List<FirmwareInfo> get availableFirmwares => state.availableFirmwares;
  bool get isLoadingFirmwares => state.loadingFirmwares;

  /// Méthodes publiques pour la compatibilité
  void loadAvailableFirmwares() {
    add(const LoadFirmwares());
  }

  void updateSystemFirmware(ArmSide side, String firmwarePath) {
    add(StartDfu(side, firmwarePath));
  }

  void abortSystemFirmwareUpdate(ArmSide side) {
    add(AbortDfu(side));
  }

  void _registerHandlers() {
    // Binding
    on<LoadBindings>(_onLoadBindings);
    on<BindDevice>(_onBindDevice);
    on<UnbindDevice>(_onUnbindDevice);
    on<BindAndConnect>(_onBindAndConnect);

    // Scan
    on<StartScan>(_onStartScan);
    on<StopScan>(_onStopScan);
    on<DeviceDiscovered>(_onDeviceDiscovered);
    on<ScanTimeout>(_onScanTimeout);

    // Connection
    on<ConnectDevice>(_onConnectDevice);
    on<DisconnectDevice>(_onDisconnectDevice);
    on<DeviceConnected>(_onDeviceConnected);
    on<DeviceDisconnected>(_onDeviceDisconnected);
    on<RetryConnection>(_onRetryConnection);
    on<CancelReconnection>(_onCancelReconnection);

    // Sync
    on<SyncTime>(_onSyncTime);
    on<ReadBattery>(_onReadBattery);
    on<ReadDeviceInfo>(_onReadDeviceInfo);
    on<DiscoverGatt>(_onDiscoverGatt);
    on<GattDiscovered>(_onGattDiscovered);
    on<TimeSynced>(_onTimeSynced);

    // Sensor data
    on<BatteryUpdated>(_onBatteryUpdated);
    on<StepsUpdated>(_onStepsUpdated);
    on<MotionUpdated>(_onMotionUpdated);
    on<RssiUpdated>(_onRssiUpdated);
    on<MovementDataReceived>(_onMovementDataReceived);

    // Firmware
    on<LoadFirmwares>(_onLoadFirmwares);
    on<SelectFirmware>(_onSelectFirmware);
    on<StartDfu>(_onStartDfu);
    on<AbortDfu>(_onAbortDfu);
    on<DfuProgressUpdate>(_onDfuProgress);

    // Music
    on<SendMusicMeta>(_onSendMusicMeta);
    on<SendMusicPlayPause>(_onSendMusicPlayPause);
    on<MusicEventReceived>(_onMusicEventReceived);

    // Navigation & Weather
    on<SendNavigation>(_onSendNavigation);
    on<SendWeather>(_onSendWeather);

    // Utility
    on<FlushBuffers>(_onFlushBuffers);
  }

  void _startPeriodicTasks() {
    _bufferFlushTimer?.cancel();
    _bufferFlushTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => _flushAllBuffers(),
    );
  }

  Future<void> _loadConfiguration() async {
    try {
      final settings = await _db.fetchSettings();
      if (settings != null) {
        updateConfiguration(settings);
      }
    } catch (e) {
      AppLogger.error('Error loading configuration', e);
    }
  }

  void updateConfiguration(AppSettings settings) {
    _scanTimeoutSeconds = settings.bluetoothScanTimeout;
    _connectionTimeoutSeconds = settings.bluetoothConnectionTimeout;
    _maxRetryAttempts = settings.bluetoothMaxRetries;
    _samplingSettings = settings.movementSampling;
    _sensorHandler.updateSamplingSettings(settings.movementSampling);
  }

  // ========== BINDING HANDLERS ==========

  Future<void> _onLoadBindings(LoadBindings event, Emitter<DeviceState> emit) async {
    if (_bindingsLoaded) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final leftId = prefs.getString(ArmSide.left.deviceKey);
      final rightId = prefs.getString(ArmSide.right.deviceKey);
      final leftSyncMs = prefs.getInt(ArmSide.left.syncKey);
      final rightSyncMs = prefs.getInt(ArmSide.right.syncKey);

      // Vérifier les doublons
      if (leftId != null && rightId != null && leftId == rightId) {
        await prefs.remove(ArmSide.right.deviceKey);
        emit(state.withArm(ArmSide.right, const ArmState()));
        _bindingsLoaded = true;
        return;
      }

      emit(state.copyWith(
        left: state.left.copyWith(
          deviceId: leftId,
          lastSync: leftSyncMs != null ? DateTime.fromMillisecondsSinceEpoch(leftSyncMs) : null,
        ),
        right: state.right.copyWith(
          deviceId: rightId,
          lastSync: rightSyncMs != null ? DateTime.fromMillisecondsSinceEpoch(rightSyncMs) : null,
        ),
      ));

      _bindingsLoaded = true;

      // Connexion automatique après délai
      // IMPORTANT: Espacer les connexions pour éviter la surcharge BLE
      await Future.delayed(const Duration(milliseconds: 500));

      if (leftId != null && !state.left.connected && _sessions[ArmSide.left] == null) {
        add(const ConnectDevice(ArmSide.left));
        // Attendre avant de lancer la deuxième connexion
        await Future.delayed(const Duration(seconds: 2));
      }
      if (rightId != null && !state.right.connected && _sessions[ArmSide.right] == null) {
        add(const ConnectDevice(ArmSide.right));
      }
    } catch (e) {
      AppLogger.error('Error loading bindings', e);
    }
  }

  Future<void> _onBindDevice(BindDevice event, Emitter<DeviceState> emit) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final other = event.side.opposite;
      final otherId = state.getArm(other).deviceId;

      // Vérifier les doublons
      if (otherId == event.deviceId) {
        await prefs.remove(other.deviceKey);
        emit(state.withArm(other, const ArmState()));
      }

      await prefs.setString(event.side.deviceKey, event.deviceId);
      emit(state.withArm(
        event.side,
        state.getArm(event.side).copyWith(deviceId: event.deviceId, name: event.name),
      ));
    } catch (e) {
      AppLogger.error('Error binding device', e);
    }
  }

  Future<void> _onUnbindDevice(UnbindDevice event, Emitter<DeviceState> emit) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(event.side.deviceKey);
      await prefs.remove(event.side.syncKey);
      await _disconnectAndDispose(event.side);

      emit(state.withArm(event.side, const ArmState()));
      _bindingsLoaded = false;
    } catch (e) {
      AppLogger.error('Error unbinding device', e);
    }
  }

  Future<void> _onBindAndConnect(BindAndConnect event, Emitter<DeviceState> emit) async {
    add(BindDevice(event.side, event.deviceId, name: event.name));
    await Future.delayed(const Duration(milliseconds: 100));
    add(ConnectDevice(event.side));
  }

  // ========== SCAN HANDLERS ==========

  Future<void> _onStartScan(StartScan event, Emitter<DeviceState> emit) async {
    if (state.scanning) return;

    emit(state.copyWith(scanning: true, discoveredDevices: []));

    _scanSub?.cancel();
    _scanTimer?.cancel();

    _scanSub = ble.scanForDevices(
      withServices: [],
      scanMode: ScanMode.lowLatency,
    ).listen(
      (device) {
        if (device.name.toLowerCase().contains('infinitime') ||
            device.name.toLowerCase().contains('pinetime')) {
          add(DeviceDiscovered(device));
        }
      },
      onError: (e) {
        AppLogger.error('Scan error', e);
        add(const StopScan());
      },
    );

    _scanTimer = Timer(Duration(seconds: _scanTimeoutSeconds), () {
      add(const ScanTimeout());
    });
  }

  Future<void> _onStopScan(StopScan event, Emitter<DeviceState> emit) async {
    _scanSub?.cancel();
    _scanTimer?.cancel();
    emit(state.copyWith(scanning: false));
  }

  void _onDeviceDiscovered(DeviceDiscovered event, Emitter<DeviceState> emit) {
    final existingIndex = state.discoveredDevices.indexWhere((d) => d.id == event.device.id);
    final updatedDevices = List<DiscoveredDevice>.from(state.discoveredDevices);

    if (existingIndex >= 0) {
      updatedDevices[existingIndex] = event.device;
    } else {
      updatedDevices.add(event.device);
    }

    emit(state.copyWith(discoveredDevices: updatedDevices));
  }

  Future<void> _onScanTimeout(ScanTimeout event, Emitter<DeviceState> emit) async {
    await _scanSub?.cancel();
    _scanTimer?.cancel();
    emit(state.copyWith(scanning: false));
  }

  // ========== CONNECTION HANDLERS ==========

  Future<void> _onConnectDevice(ConnectDevice event, Emitter<DeviceState> emit) async {
    final side = event.side;
    final otherSide = side == ArmSide.left ? ArmSide.right : ArmSide.left;
    final deviceId = state.getArm(side).deviceId;

    // Éviter les connexions multiples
    if (deviceId == null) {
      AppLogger.warning('No device ID for $side');
      return;
    }

    if (_connectionInProgress[side] == true) {
      AppLogger.warning('Connection already in progress for $side');
      return;
    }

    // Éviter les connexions simultanées sur les deux bras (peut surcharger BLE)
    if (_connectionInProgress[otherSide] == true) {
      AppLogger.info('Waiting for $otherSide connection to complete before connecting $side');
      // Réessayer après un délai
      Future.delayed(const Duration(seconds: 3), () {
        if (!isClosed && !_connectionInProgress[side]!) {
          add(ConnectDevice(side));
        }
      });
      return;
    }

    _connectionInProgress[side] = true;

    // Clear any previous error et marquer comme "connecting"
    emit(state.withArm(side, state.getArm(side).copyWith(
      connecting: true,
      clearConnectionError: true,
    )));

    String? errorType;
    bool success = false;

    try {
      final session = InfiniTimeSession(ble, deviceId);
      _sessions[side] = session;

      await session.connectAndSetup().timeout(
        Duration(seconds: _connectionTimeoutSeconds),
        onTimeout: () {
          throw TimeoutException(
            'Connection timeout after $_connectionTimeoutSeconds seconds',
            Duration(seconds: _connectionTimeoutSeconds),
          );
        },
      );

      // Connection successful
      _connectionEstablishedAt[side] = DateTime.now();
      _retries[side] = 0;
      success = true;
    } on TimeoutException catch (e) {
      AppLogger.error('Connection timeout', e);
      errorType = 'timeout';
    } catch (e) {
      AppLogger.error('Connection error', e);
      errorType = _categorizeError(e);
    } finally {
      _connectionInProgress[side] = false;
    }

    // Émettre l'état après le try-catch (pas dans un callback)
    if (success) {
      add(DeviceConnected(side));
    } else if (errorType != null) {
      await _handleConnectionFailure(side, emit, errorType);
    }
  }

  /// Catégoriser l'erreur pour afficher un message approprié
  String _categorizeError(dynamic error) {
    final errorStr = error.toString().toLowerCase();
    if (errorStr.contains('timeout')) return 'timeout';
    if (errorStr.contains('status=255') || errorStr.contains('gatt')) return 'gatt_error';
    if (errorStr.contains('bluetooth') || errorStr.contains('ble')) return 'bluetooth_error';
    if (errorStr.contains('permission')) return 'permission_error';
    return 'unknown';
  }

  Future<void> _handleConnectionFailure(ArmSide side, Emitter<DeviceState> emit, String errorType) async {
    _retries[side] = (_retries[side] ?? 0) + 1;

    // Nettoyer la session en échec
    await _cleanupSession(side);

    emit(state.withArm(
      side,
      state.getArm(side).copyWith(
        connecting: false,
        connected: false,
        retryCount: _retries[side],
        connectionError: errorType,
      ),
    ));

    // Réessayer automatiquement seulement si on n'a pas atteint le max
    if (_retries[side]! < _maxRetryAttempts) {
      _scheduleReconnection(side);
    } else {
      AppLogger.warning('Max retry attempts reached for $side');
    }
  }

  /// Nettoyer une session en échec
  Future<void> _cleanupSession(ArmSide side) async {
    try {
      final session = _sessions[side];
      if (session != null) {
        await session.disconnect();
      }
    } catch (_) {
      // Ignorer les erreurs de nettoyage
    }
    _sessions[side] = null;
  }

  void _scheduleReconnection(ArmSide side) {
    _reconnectTimers[side]?.cancel();

    // Délai exponentiel : 2s, 4s, 6s, 8s, 10s
    final delay = Duration(seconds: 2 * (_retries[side] ?? 1));
    AppLogger.info('Scheduling reconnection for $side in ${delay.inSeconds}s (attempt ${_retries[side]}/$_maxRetryAttempts)');

    _reconnectTimers[side] = Timer(delay, () {
      if (!isClosed) {
        add(ConnectDevice(side));
      }
    });
  }

  /// Réessayer manuellement la connexion (réinitialise le compteur)
  void _onRetryConnection(RetryConnection event, Emitter<DeviceState> emit) {
    final side = event.side;

    // Annuler toute tentative en cours
    _reconnectTimers[side]?.cancel();

    // Réinitialiser le compteur et l'erreur
    _retries[side] = 0;

    emit(state.withArm(
      side,
      state.getArm(side).copyWith(
        retryCount: 0,
        clearConnectionError: true,
      ),
    ));

    // Relancer la connexion
    add(ConnectDevice(side));
  }

  /// Annuler les tentatives de reconnexion automatique
  void _onCancelReconnection(CancelReconnection event, Emitter<DeviceState> emit) {
    final side = event.side;

    // Annuler le timer
    _reconnectTimers[side]?.cancel();
    _reconnectTimers[side] = null;

    // Réinitialiser l'état
    _retries[side] = 0;
    _connectionInProgress[side] = false;

    emit(state.withArm(
      side,
      state.getArm(side).copyWith(
        connecting: false,
        retryCount: 0,
        clearConnectionError: true,
      ),
    ));
  }

  Future<void> _onDisconnectDevice(DisconnectDevice event, Emitter<DeviceState> emit) async {
    await _disconnectAndDispose(event.side);
    emit(state.withArm(
      event.side,
      state.getArm(event.side).copyWith(connected: false, connecting: false),
    ));
  }

  void _onDeviceConnected(DeviceConnected event, Emitter<DeviceState> emit) {
    emit(state.withArm(
      event.side,
      state.getArm(event.side).copyWith(connected: true, connecting: false),
    ));

    // Setup subscriptions
    _setupSubscriptions(event.side);

    // Configurer les sessions pour le WatchVibrationService (notifications/alertes)
    _updateVibrationServiceSessions();

    // Auto sync et lecture des informations
    // Note: DiscoverGatt doit être appelé en premier pour découvrir les services disponibles
    add(DiscoverGatt(event.side));
    add(SyncTime(event.side));
    add(ReadBattery(event.side));
    // ReadDeviceInfo sera appelé après un délai pour laisser le temps à la découverte GATT
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!isClosed) {
        add(ReadDeviceInfo(event.side));
      }
    });

    // Envoyer une notification à la montre pour indiquer le bras assigné
    _sendArmAssignmentNotification(event.side);
  }

  /// Envoie une notification à la montre pour indiquer le bras assigné
  Future<void> _sendArmAssignmentNotification(ArmSide side) async {
    final session = _sessions[side];
    if (session == null) {
      AppLogger.warning('Cannot send arm notification: no session for $side');
      return;
    }

    try {
      // Attendre un peu pour que la connexion soit stable
      await Future.delayed(const Duration(milliseconds: 800));

      final armLabel = side == ArmSide.left ? 'Gauche' : 'Droite';
      await session.sendNotification(
        title: 'Bras $armLabel',
        message: 'Montre configurée pour le bras $armLabel',
      );
      AppLogger.info('Arm assignment notification sent to $side watch');
    } catch (e) {
      AppLogger.error('Failed to send arm assignment notification', e);
    }
  }

  Future<void> _onDeviceDisconnected(DeviceDisconnected event, Emitter<DeviceState> emit) async {
    emit(state.withArm(
      event.side,
      state.getArm(event.side).copyWith(connected: false, connecting: false),
    ));

    // Mettre à jour le WatchVibrationService (retirer la session déconnectée)
    _updateVibrationServiceSessions();

    if (event.unexpected && state.getArm(event.side).deviceId != null) {
      _scheduleReconnection(event.side);
    }
  }

  /// Met à jour les sessions dans le WatchVibrationService pour les notifications
  void _updateVibrationServiceSessions() {
    WatchVibrationService().configureSessions(
      leftSession: _sessions[ArmSide.left],
      rightSession: _sessions[ArmSide.right],
    );
    AppLogger.info('WatchVibrationService sessions updated: left=${_sessions[ArmSide.left] != null}, right=${_sessions[ArmSide.right] != null}');
  }

  void _setupSubscriptions(ArmSide side) {
    final session = _sessions[side];
    if (session == null) return;

    // Battery
    _battSubs[side]?.cancel();
    _battSubs[side] = session.battery.listen((value) {
      add(BatteryUpdated(side, value));
    });

    // Steps
    _stepsSubs[side]?.cancel();
    _stepsSubs[side] = session.steps.listen((value) {
      add(StepsUpdated(side, value));
    });

    // Motion
    _motionSubs[side]?.cancel();
    _motionSubs[side] = session.motion.listen((xyz) {
      add(MotionUpdated(side, xyz));
    });

    // Movement
    _movementSubs[side]?.cancel();
    _movementSubs[side] = session.movementStream.listen((data) {
      add(MovementDataReceived(side, data));
    });

    // Music events
    _musicEventSubs[side]?.cancel();
    _musicEventSubs[side] = session.musicEvents.listen((event) {
      add(MusicEventReceived(side, event));
    });

    // DFU
    _dfuSubs[side]?.cancel();
    _dfuSubs[side] = session.dfuProgress.listen((progress) {
      add(DfuProgressUpdate(side, progress.percent, progress.phase));
    });

    // Connection state
    _connSubs[side]?.cancel();
    _connSubs[side] = session.connectionStream.listen((connState) {
      if (connState == InfiniTimeConnectionState.disconnected) {
        add(DeviceDisconnected(side, unexpected: true));
      }
    });
  }

  // ========== SYNC HANDLERS ==========

  Future<void> _onSyncTime(SyncTime event, Emitter<DeviceState> emit) async {
    final session = _sessions[event.side];
    if (session == null) {
      AppLogger.warning('SyncTime: No session for ${event.side}, watch not connected');
      return;
    }

    // Vérifier que la montre est connectée
    if (!state.getArm(event.side).connected) {
      AppLogger.warning('SyncTime: Watch ${event.side} is not connected');
      return;
    }

    try {
      final now = DateTime.now();
      DateTime timeToSync;

      if (event.timezoneOffsetHours != null) {
        // Utiliser le fuseau horaire personnalisé
        // Calculer l'heure dans le fuseau personnalisé
        final customOffset = Duration(
          hours: event.timezoneOffsetHours!.floor(),
          minutes: ((event.timezoneOffsetHours! % 1) * 60).round(),
        );
        final phoneOffset = now.timeZoneOffset;
        // Convertir: heure locale -> UTC -> heure dans le fuseau personnalisé
        timeToSync = now.subtract(phoneOffset).add(customOffset);
        AppLogger.info('SyncTime: Using custom timezone UTC${event.timezoneOffsetHours! >= 0 ? "+" : ""}${event.timezoneOffsetHours}');
      } else {
        // Utiliser l'heure locale du téléphone
        timeToSync = now;
      }

      AppLogger.info('SyncTime: Syncing time for ${event.side} to $timeToSync');
      await session.syncTimeUtc(timeToSync);
      add(TimeSynced(event.side, timeToSync));
      AppLogger.info('SyncTime: Time synced successfully for ${event.side}');
    } catch (e) {
      AppLogger.error('SyncTime: Error syncing time for ${event.side}', e);
    }
  }

  Future<void> _onReadBattery(ReadBattery event, Emitter<DeviceState> emit) async {
    final session = _sessions[event.side];
    if (session == null) return;

    try {
      final battery = await session.readBattery();
      if (battery != null) {
        add(BatteryUpdated(event.side, battery));
      }
    } catch (e) {
      AppLogger.error('Error reading battery', e);
    }
  }

  Future<void> _onReadDeviceInfo(ReadDeviceInfo event, Emitter<DeviceState> emit) async {
    final session = _sessions[event.side];
    if (session == null) {
      AppLogger.warning('ReadDeviceInfo: No session for ${event.side}');
      return;
    }

    try {
      AppLogger.info('ReadDeviceInfo: Reading device info for ${event.side}...');
      final info = await session.readDeviceInfo();
      AppLogger.info('ReadDeviceInfo: Raw info received: $info');

      // Convertir Map<String, String?> en Map<String, String> (sans les valeurs null)
      final deviceInfo = <String, String>{};
      info.forEach((key, value) {
        if (value != null && value.isNotEmpty) {
          deviceInfo[key] = value;
        }
      });

      AppLogger.info('ReadDeviceInfo: Filtered deviceInfo: $deviceInfo');

      if (deviceInfo.isNotEmpty) {
        // Mettre à jour l'état avec les informations du périphérique
        emit(state.withArm(
          event.side,
          state.getArm(event.side).copyWith(deviceInfo: deviceInfo),
        ));
        AppLogger.info('Device info updated for ${event.side}: $deviceInfo');
      } else {
        AppLogger.warning('ReadDeviceInfo: No valid device info for ${event.side}');
      }
    } catch (e, stackTrace) {
      AppLogger.error('Error reading device info for ${event.side}', e, stackTrace);
    }
  }

  Future<void> _onDiscoverGatt(DiscoverGatt event, Emitter<DeviceState> emit) async {
    final deviceId = state.getArm(event.side).deviceId;
    if (deviceId == null) return;

    try {
      await ble.discoverAllServices(deviceId);
      final services = await ble.getDiscoveredServices(deviceId);

      final chars = <Uuid>{};
      final noti = <Uuid>{};
      final indi = <Uuid>{};

      for (final s in services) {
        for (final c in s.characteristics) {
          chars.add(c.id);
          if (c.isNotifiable) noti.add(c.id);
          if (c.isIndicatable) indi.add(c.id);
        }
      }

      add(GattDiscovered(event.side, chars, noti, indi));
    } catch (e) {
      AppLogger.error('Error discovering GATT', e);
    }
  }

  void _onGattDiscovered(GattDiscovered event, Emitter<DeviceState> emit) {
    emit(state.withArm(
      event.side,
      state.getArm(event.side).copyWith(
        chars: event.chars,
        noti: event.noti,
        indi: event.indi,
      ),
    ));
  }

  Future<void> _onTimeSynced(TimeSynced event, Emitter<DeviceState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(event.side.syncKey, event.at.millisecondsSinceEpoch);

    emit(state.withArm(
      event.side,
      state.getArm(event.side).copyWith(lastSync: event.at),
    ));
  }

  // ========== SENSOR DATA HANDLERS ==========

  void _onBatteryUpdated(BatteryUpdated event, Emitter<DeviceState> emit) {
    emit(state.withArm(
      event.side,
      state.getArm(event.side).copyWith(battery: event.value),
    ));
    _sensorHandler.bufferDeviceInfo(event.side, 'battery', event.value.toDouble());
  }

  void _onStepsUpdated(StepsUpdated event, Emitter<DeviceState> emit) {
    emit(state.withArm(
      event.side,
      state.getArm(event.side).copyWith(steps: event.value),
    ));
    _sensorHandler.bufferDeviceInfo(event.side, 'steps', event.value.toDouble());
  }

  void _onMotionUpdated(MotionUpdated event, Emitter<DeviceState> emit) {
    emit(state.withArm(
      event.side,
      state.getArm(event.side).copyWith(motion: event.xyz),
    ));
  }

  void _onRssiUpdated(RssiUpdated event, Emitter<DeviceState> emit) {
    emit(state.withArm(
      event.side,
      state.getArm(event.side).copyWith(rssi: event.value),
    ));
    _sensorHandler.bufferDeviceInfo(event.side, 'rssi', event.value.toDouble());
  }

  void _onMovementDataReceived(MovementDataReceived event, Emitter<DeviceState> emit) {
    final rssi = state.getArm(event.side).rssi;
    _sensorHandler.bufferMovement(event.side, event.data, rssi);
  }

  // ========== FIRMWARE HANDLERS ==========

  Future<void> _onLoadFirmwares(LoadFirmwares event, Emitter<DeviceState> emit) async {
    emit(state.copyWith(loadingFirmwares: true));

    try {
      final firmwares = await FirmwareHandler.loadAvailableFirmwares();
      emit(state.copyWith(availableFirmwares: firmwares, loadingFirmwares: false));
    } catch (e) {
      AppLogger.error('Error loading firmwares', e);
      emit(state.copyWith(availableFirmwares: [], loadingFirmwares: false));
    }
  }

  void _onSelectFirmware(SelectFirmware event, Emitter<DeviceState> emit) {
    final updated = Map<ArmSide, FirmwareInfo?>.from(state.selectedFirmwares);
    updated[event.side] = event.firmware;
    emit(state.copyWith(selectedFirmwares: updated));
  }

  Future<void> _onStartDfu(StartDfu event, Emitter<DeviceState> emit) async {
    final session = _sessions[event.side];
    if (session == null) return;

    emit(state.withArm(
      event.side,
      state.getArm(event.side).copyWith(dfuRunning: true, dfuPercent: 0),
    ));

    final success = await FirmwareHandler.startDfu(session, event.firmwarePath);
    if (!success) {
      emit(state.withArm(
        event.side,
        state.getArm(event.side).copyWith(dfuRunning: false, dfuPhase: 'Error'),
      ));
    }
  }

  Future<void> _onAbortDfu(AbortDfu event, Emitter<DeviceState> emit) async {
    final session = _sessions[event.side];
    if (session == null) return;

    await FirmwareHandler.abortDfu(session);
    emit(state.withArm(
      event.side,
      state.getArm(event.side).copyWith(dfuRunning: false, dfuPercent: 0, dfuPhase: 'Aborted'),
    ));
  }

  void _onDfuProgress(DfuProgressUpdate event, Emitter<DeviceState> emit) {
    emit(state.withArm(
      event.side,
      state.getArm(event.side).copyWith(
        dfuRunning: event.percent < 100,
        dfuPercent: event.percent,
        dfuPhase: event.phase,
      ),
    ));
  }

  // ========== MUSIC HANDLERS ==========

  Future<void> _onSendMusicMeta(SendMusicMeta event, Emitter<DeviceState> emit) async {
    final session = _sessions[event.side];
    if (session == null) return;

    await MediaHandler.sendMusicMeta(
      session,
      artist: event.artist,
      track: event.track,
      album: event.album,
    );
  }

  Future<void> _onSendMusicPlayPause(SendMusicPlayPause event, Emitter<DeviceState> emit) async {
    final session = _sessions[event.side];
    if (session == null) return;

    await MediaHandler.sendMusicPlayPause(session, event.play);
  }

  void _onMusicEventReceived(MusicEventReceived event, Emitter<DeviceState> emit) {
    final command = MediaHandler.parseMusicEvent(event.event);
    AppLogger.debug('Music command received: $command');
  }

  // ========== NAVIGATION & WEATHER HANDLERS ==========

  Future<void> _onSendNavigation(SendNavigation event, Emitter<DeviceState> emit) async {
    final session = _sessions[event.side];
    if (session == null) return;

    await MediaHandler.sendNavigation(
      session,
      narrative: event.narrative,
      distance: event.distance,
      progress: event.progress,
      flags: event.flags,
    );
  }

  Future<void> _onSendWeather(SendWeather event, Emitter<DeviceState> emit) async {
    final session = _sessions[event.side];
    if (session == null) return;

    await MediaHandler.sendWeather(session, event.payload);
  }

  // ========== UTILITY HANDLERS ==========

  Future<void> _onFlushBuffers(FlushBuffers event, Emitter<DeviceState> emit) async {
    await _flushAllBuffers();
  }

  Future<void> _flushAllBuffers() async {
    await _sensorHandler.flushAllBuffers(
      leftRssi: state.left.rssi,
      rightRssi: state.right.rssi,
    );
    ChartRefreshNotifier().notifyAllDataUpdated();
  }

  Future<void> _disconnectAndDispose(ArmSide side) async {
    _reconnectTimers[side]?.cancel();
    _battSubs[side]?.cancel();
    _stepsSubs[side]?.cancel();
    _motionSubs[side]?.cancel();
    _dfuSubs[side]?.cancel();
    _connSubs[side]?.cancel();
    _musicEventSubs[side]?.cancel();
    _movementSubs[side]?.cancel();

    try {
      await _sessions[side]?.dispose();
    } catch (e) {
      AppLogger.warning('Error disposing session: $e');
    }
    _sessions[side] = null;
  }

  // ========== PUBLIC API ==========

  /// Récupère l'historique des événements de connexion pour un bras donné
  Future<List<ConnectionEvent>> getConnectionHistory(
    ArmSide side, {
    Duration period = const Duration(days: 7),
  }) async {
    final startDate = DateTime.now().subtract(period);
    return _db.getConnectionHistory(
      side.technicalName,
      startDate: startDate,
    );
  }

  @override
  Future<void> close() async {
    _scanSub?.cancel();
    _scanTimer?.cancel();
    _bufferFlushTimer?.cancel();

    for (final side in [ArmSide.left, ArmSide.right]) {
      await _disconnectAndDispose(side);
    }

    await _flushAllBuffers();
    return super.close();
  }
}
