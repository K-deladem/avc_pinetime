import 'dart:async';
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_bloc_app_template/app/app_database.dart';
import 'package:flutter_bloc_app_template/bloc/infinitime/dual_infinitime_event.dart';
import 'package:flutter_bloc_app_template/bloc/infinitime/dual_infinitime_state.dart';
import 'package:flutter_bloc_app_template/extension/arm_side_extensions.dart';
import 'package:flutter_bloc_app_template/extension/dual_infinitime_state_extensions.dart';
import 'package:flutter_bloc_app_template/models/app_settings.dart';
import 'package:flutter_bloc_app_template/models/arm_side.dart';
import 'package:flutter_bloc_app_template/models/movement_sampling_settings.dart';
import 'package:flutter_bloc_app_template/models/connection_event.dart';
import 'package:flutter_bloc_app_template/models/device_info_data.dart';
import 'package:flutter_bloc_app_template/service/background_infinitime_service.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:infinitime_dfu_library/infinitime_dfu_library.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:synchronized/synchronized.dart';

import '../../service/firmware_source.dart';
import '../../service/chart_refresh_notifier.dart';

// ============================================================================
// CLASS: DualInfiniTimeBloc
// Description: Gestion dual-arm avec nouvelle table device_info_data
// ============================================================================

class DualInfiniTimeBloc
    extends Bloc<DualInfiniTimeEvent, DualInfiniTimeState> {
  // ========== CONSTANTES NON-CONFIGURABLES ==========
  static const int _SCAN_THROTTLE_MS = 500;
  static const int _MIN_RECONNECT_DELAY_MS = 2000;
  static const int _STABLE_CONNECTION_DELAY_MS = 3000;
  static const int _SCAN_CACHE_CLEANUP_MINUTES = 5;

  // Délais entre opérations (optimisés pour fluidité)
  static const Duration _DELAY_BEFORE_RECONNECT = Duration(milliseconds: 300);
  static const Duration _DELAY_BETWEEN_STREAMS = Duration(milliseconds: 5);  // Réduit de 20ms à 5ms
  static const Duration _DELAY_BETWEEN_OPERATIONS = Duration(milliseconds: 150);  // Réduit de 200ms à 150ms
  static const Duration _DELAY_AFTER_CONNECTION = Duration(milliseconds: 200);  // Réduit de 300ms à 200ms

  // ========== LIMITES DES BUFFERS ==========
  static const int _MAX_DEVICE_INFO_BUFFER_SIZE = 50;
  static const int _MAX_MOVEMENT_BUFFER_SIZE = 100;

  // ========== PARAMÈTRES CONFIGURABLES (depuis Settings) ==========
  late int _SCAN_TIMEOUT_SECONDS;
  late int _CONNECTION_TIMEOUT_SECONDS;
  late int _MAX_RETRY_ATTEMPTS;
  late int _MAX_RECONNECT_DELAY_MS;
  late Duration _MIN_DEVICE_INFO_RECORD_INTERVAL;
  late Duration _MIN_MOVEMENT_RECORD_INTERVAL;
  MovementSamplingSettings _movementSamplingSettings = const MovementSamplingSettings();

  // ========== BASE DE DONNÉES ==========
  final AppDatabase _db = AppDatabase.instance;

  // ========== ÉTAT DE CONNEXION ==========
  final Map<ArmSide, bool> _connectionInProgress = {
    ArmSide.left: false,
    ArmSide.right: false
  };

  final Map<ArmSide, DateTime?> _lastConnectionAttempt = {
    ArmSide.left: null,
    ArmSide.right: null
  };

  final Map<ArmSide, DateTime?> _connectionEstablishedAt = {
    ArmSide.left: null,
    ArmSide.right: null
  };

  final Map<ArmSide, DateTime?> _connectedAt = {
    ArmSide.left: null,
    ArmSide.right: null
  };

  // ========== TRACKING POUR ENREGISTREMENT INTELLIGENT ==========
  final Map<ArmSide, Map<String, DateTime>> _lastRecordTime = {
    ArmSide.left: {},
    ArmSide.right: {},
  };

  final Map<ArmSide, Map<String, dynamic>> _lastRecordedValue = {
    ArmSide.left: {},
    ArmSide.right: {},
  };

  // ========== BUFFERS POUR BATCH INSERT ==========
  /// Buffer pour device_info_data (battery, step, rssi)
  final Map<ArmSide, List<Map<String, dynamic>>> _deviceInfoBuffer = {
    ArmSide.left: [],
    ArmSide.right: [],
  };

  /// Buffer pour movement_data (magnitudeActiveTime, axisActiveTime)
  final Map<ArmSide, List<MovementData>> _movementBuffer = {
    ArmSide.left: [],
    ArmSide.right: [],
  };

  /// Tracking pour le sampling de mouvement
  final Map<ArmSide, DateTime?> _lastMovementSampleTime = {
    ArmSide.left: null,
    ArmSide.right: null,
  };
  final Map<ArmSide, double?> _lastMovementMagnitude = {
    ArmSide.left: null,
    ArmSide.right: null,
  };
  /// Buffer d'agrégation pour le mode aggregate
  final Map<ArmSide, List<MovementData>> _movementAggregateBuffer = {
    ArmSide.left: [],
    ArmSide.right: [],
  };

  /// Tracking des dernières valeurs cumulatives pour calcul des deltas
  /// IMPORTANT: magnitudeActiveTime et axisActiveTime sont cumulatifs depuis le boot de la montre
  /// On doit calculer la différence (delta) entre deux lectures successives
  final Map<ArmSide, int?> _lastMagnitudeActiveTime = {
    ArmSide.left: null,
    ArmSide.right: null,
  };
  final Map<ArmSide, int?> _lastAxisActiveTime = {
    ArmSide.left: null,
    ArmSide.right: null,
  };

  Timer? _bufferFlushTimer;
  Timer? _trackingCleanupTimer;
  Timer? _oldDataCleanupTimer;

  // ========== LOCKS FOR THREAD SAFETY ==========
  final Map<ArmSide, Lock> _connectionLocks = {
    ArmSide.left: Lock(),
    ArmSide.right: Lock(),
  };
  final Map<ArmSide, Lock> _bufferFlushLocks = {
    ArmSide.left: Lock(),
    ArmSide.right: Lock(),
  };

  // ========== BINDINGS LOADED FLAG ==========
  bool _bindingsLoaded = false;

  // ========== BLE & SESSIONS ==========
  final FlutterReactiveBle ble;
  final Map<ArmSide, InfiniTimeSession?> _sessions = {
    ArmSide.left: null,
    ArmSide.right: null
  };

  // ========== SUBSCRIPTIONS ==========
  final Map<ArmSide, StreamSubscription?> _battSubs = {};
  final Map<ArmSide, StreamSubscription?> _stepsSubs = {};
  final Map<ArmSide, StreamSubscription?> _motionSubs = {};
  final Map<ArmSide, StreamSubscription?> _dfuSubs = {};
  final Map<ArmSide, StreamSubscription?> _blejsSubs = {};
  final Map<ArmSide, StreamSubscription?> _connSubs = {};
  final Map<ArmSide, StreamSubscription?> _musicEventSubs = {};
  final Map<ArmSide, StreamSubscription?> _callEventSubs = {};
  final Map<ArmSide, StreamSubscription?> _movementSubs = {};
  final Map<String, StreamSubscription?> _subscriptions = {};

  StreamSubscription<DiscoveredDevice>? _scanSub;
  Timer? _scanTimer;
  Timer? _scanCacheCleanupTimer;
  StreamSubscription<DiscoveredDevice>? _rssiScanShared;

  // ========== RECONNEXION ==========
  final Map<ArmSide, Timer?> _reconnectTimers = {
    ArmSide.left: null,
    ArmSide.right: null
  };
  final Map<ArmSide, int> _retries = {ArmSide.left: 0, ArmSide.right: 0};

  // ========== CACHE ==========
  final Map<String, int> _lastRssiById = {};
  final Map<String, DateTime> _lastSeenAt = {};

  // ========== DEBOUNCING ==========
  final Map<ArmSide, Timer?> _rssiDebounceTimers = {
    ArmSide.left: null,
    ArmSide.right: null
  };
  final Map<ArmSide, int?> _pendingRssi = {
    ArmSide.left: null,
    ArmSide.right: null
  };

  // ============================================================================
  // CONSTRUCTEUR
  // ============================================================================

  DualInfiniTimeBloc(this.ble) : super(const DualInfiniTimeState()) {
    _registerEventHandlers();
    _listenToBackgroundService();
    _startPeriodicTasks();
    _loadSettingsConfiguration();
  }

  /// Charge la configuration depuis les settings
  Future<void> _loadSettingsConfiguration() async {
    try {
      final settings = await _db.fetchSettings();
      if (settings != null) {
        updateConfiguration(settings);
      } else {
        // Utiliser les valeurs par défaut
        _SCAN_TIMEOUT_SECONDS = 15;
        _CONNECTION_TIMEOUT_SECONDS = 30;
        _MAX_RETRY_ATTEMPTS = 5;
        _MAX_RECONNECT_DELAY_MS = 30 * 1000;
        _MIN_DEVICE_INFO_RECORD_INTERVAL = const Duration(minutes: 2);
        _MIN_MOVEMENT_RECORD_INTERVAL = const Duration(seconds: 30);
      }
      _log('Settings configuration loaded', level: _LOG_INFO);
    } catch (e) {
      _log('Error loading settings configuration: $e', level: _LOG_ERROR);
      // Utiliser les valeurs par défaut en cas d'erreur
      _SCAN_TIMEOUT_SECONDS = 15;
      _CONNECTION_TIMEOUT_SECONDS = 30;
      _MAX_RETRY_ATTEMPTS = 5;
      _MAX_RECONNECT_DELAY_MS = 30 * 1000;
      _MIN_DEVICE_INFO_RECORD_INTERVAL = const Duration(minutes: 2);
      _MIN_MOVEMENT_RECORD_INTERVAL = const Duration(seconds: 30);
    }
  }

  /// Met à jour la configuration depuis les settings (appelée quand les settings changent)
  void updateConfiguration(AppSettings settings) {
    _SCAN_TIMEOUT_SECONDS = settings.bluetoothScanTimeout;
    _CONNECTION_TIMEOUT_SECONDS = settings.bluetoothConnectionTimeout;
    _MAX_RETRY_ATTEMPTS = settings.bluetoothMaxRetries;
    _MAX_RECONNECT_DELAY_MS = 30 * 1000; // Garder à 30s max pour sécurité
    _MIN_DEVICE_INFO_RECORD_INTERVAL = Duration(minutes: settings.dataRecordInterval);
    _MIN_MOVEMENT_RECORD_INTERVAL = Duration(seconds: settings.movementRecordInterval);
    _movementSamplingSettings = settings.movementSampling;

    _log('Configuration updated: scan=${_SCAN_TIMEOUT_SECONDS}s, connection=${_CONNECTION_TIMEOUT_SECONDS}s, retries=$_MAX_RETRY_ATTEMPTS, sampling=${_movementSamplingSettings.presetName}', level: _LOG_INFO);
  }

  // ============================================================================
  // GETTERS PUBLICS pour compatibilité
  // ============================================================================

  int get scanTimeoutSeconds => _SCAN_TIMEOUT_SECONDS;
  int get connectionTimeoutSeconds => _CONNECTION_TIMEOUT_SECONDS;
  int get maxRetryAttempts => _MAX_RETRY_ATTEMPTS;
  int get maxReconnectDelaySeconds => (_MAX_RECONNECT_DELAY_MS / 1000).round();
  int get stableConnectionDelayMs => _STABLE_CONNECTION_DELAY_MS;
  int get scanThrottleMs => _SCAN_THROTTLE_MS;

  // ============================================================================
  // MÉTHODES PUBLIQUES pour débogage
  // ============================================================================

  /// Force le flush de tous les buffers (pour débogage)
  Future<void> forceFlushBuffers() async {
    _log('🔧 Manual flush requested', level: _LOG_INFO);
    await _flushAllBuffers();
  }

  /// Obtient la taille actuelle des buffers (pour débogage)
  Map<String, Map<String, int>> getBufferSizes() {
    return {
      'left': {
        'device_info': _deviceInfoBuffer[ArmSide.left]?.length ?? 0,
        'movement': _movementBuffer[ArmSide.left]?.length ?? 0,
      },
      'right': {
        'device_info': _deviceInfoBuffer[ArmSide.right]?.length ?? 0,
        'movement': _movementBuffer[ArmSide.right]?.length ?? 0,
      },
    };
  }

  // ============================================================================
  // INITIALISATION DES HANDLERS
  // ============================================================================

  void _registerEventHandlers() {
    // Binding
    on<DualLoadBindingsRequested>(_onLoadBindings);
    on<DualBindArmRequested>(_onBindArm);
    on<DualUnbindArmRequested>(_onUnbindArm);

    // Scan
    on<DualScanRequested>(_onScan);
    on<DualScanStopRequested>(_onScanStop);
    on<OnFoundDevice>(_onFoundDevice);
    on<OnScanAddDevice>(_onScanAddDevice);
    on<ScanTimedOut>(_onScanTimedOut);

    // Connexion
    on<DualBindAndConnectArmRequested>(_onBindAndConnectArm);
    on<DualConnectArmRequested>(_onConnectArm);
    on<DualDisconnectArmRequested>(_onDisconnectArm);
    on<ArmDisconnected>(_onArmDisconnected);
    on<ArmConnected>(_onArmConnected);
    on<OnArmSynced>(_onArmSynced);

    // GATT
    on<DualDiscoverGattRequested>(_onDiscoverGatt);
    on<OnArmGattDump>(_onArmGattDump);

    // Synchronisation
    on<DualSyncTimeRequested>(_onSyncTime);
    on<DualReadBatteryRequested>(_onReadBattery);
    on<DualReadDeviceInfoRequested>(_onReadDeviceInfo);

    // Musique
    on<DualMusicMetaRequested>(_onMusicMeta);
    on<DualMusicPlayPauseRequested>(_onMusicPlayPause);
    on<OnArmMusicEvent>(_onArmMusicEvent);
    on<OnArmCallEvent>(_onArmCallEvent);

    // Navigation
    on<DualNavSendRequested>(_onNavSend);
    on<DualWeatherSendRequested>(_onWeatherSend);

    // BLEFS
    on<DualBlefsReadVersionRequested>(_onBlefsReadVersion);
    on<DualBlefsSendRawRequested>(_onBlefsSendRaw);

    // Firmware
    on<DualLoadAvailableFirmwaresRequested>(_onLoadAvailableFirmwares);
    on<OnAvailableFirmwaresLoaded>(_onAvailableFirmwaresLoaded);
    on<DualSelectFirmwareRequested>(_onSelectFirmware);
    on<DualSystemFirmwareDfuStartRequested>(_onSystemFirmwareDfuStart);
    on<DualSystemFirmwareDfuAbortRequested>(_onSystemFirmwareDfuAbort);
    on<OnArmSystemFirmwareDfu>(_onSystemFirmwareDfuProgress);

    // Motion
    on<DualMotionThrottleChanged>(_onMotionThrottle);

    // Debug
    on<DualForceFlushBuffersRequested>(_onForceFlushBuffers);

    // Données basiques
    on<OnArmBattery>(_onArmBattery);
    on<OnArmSteps>(_onArmSteps);
    on<OnArmMotion>(_onArmMotion);
    on<OnArmRssi>(_onArmRssi);

    // Movement
    on<OnSubscribeToMovement>(_onSubscribeToMovement);
    on<OnUnsubscribeFromMovement>(_onUnsubscribeFromMovement);

    // Time
    on<OnSyncTimeUtc>(_onSyncTimeUtc);
    on<OnSendTime>(_onSendTime);

    // Music Advanced
    on<OnMusicSetMeta>(_onMusicSetMeta);
    on<OnMusicSetPlaying>(_onMusicSetPlaying);

    // Navigation Advanced
    on<OnNavNarrativeSet>(_onNavNarrativeSet);
    on<OnNavManDistSet>(_onNavManDistSet);
    on<OnNavProgressSet>(_onNavProgressSet);
    on<OnNavFlagsSet>(_onNavFlagsSet);

    // Weather
    on<OnWeatherWrite>(_onWeatherWrite);

    // BLEFS Advanced
    on<OnBlefsWriteRaw>(_onBlefsWriteRaw);

    // Firmware Advanced
    on<OnStartSystemFirmwareDfu>(_onStartSystemFirmwareDfu);
    on<OnAbortSystemFirmwareDfu>(_onAbortSystemFirmwareDfu);
  }

  // ============================================================================
  // TÂCHES PÉRIODIQUES
  // ============================================================================

  void _startPeriodicTasks() {
    // Cancel existing timers if any
    _scanCacheCleanupTimer?.cancel();
    _bufferFlushTimer?.cancel();
    _trackingCleanupTimer?.cancel();
    _oldDataCleanupTimer?.cancel();

    // Nettoyage du cache de scan toutes les 5 minutes
    _scanCacheCleanupTimer = Timer.periodic(
      Duration(minutes: _SCAN_CACHE_CLEANUP_MINUTES),
      (_) => _cleanupScanCache(),
    );

    // Flush du buffer toutes les 5 minutes
    _bufferFlushTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => _flushAllBuffers(),
    );

    // Nettoyage des Maps de tracking toutes les heures
    _trackingCleanupTimer = Timer.periodic(
      const Duration(hours: 1),
      (_) => _cleanupTrackingMaps(),
    );

    // Nettoyage des anciennes données toutes les 24 heures
    _oldDataCleanupTimer = Timer.periodic(
      const Duration(hours: 24),
      (_) async {
        try {
          // Garder 7 jours de données détaillées
          await _db.deleteOldSensorData(const Duration(days: 7));
          // Garder 30 jours d'événements de connexion
          await _db.deleteConnectionOldEvents(const Duration(days: 30));
          _log('Old data cleaned up', level: _LOG_INFO);
        } catch (e) {
          _log('Error cleaning old data: $e', level: _LOG_ERROR);
        }
      },
    );
  }

  void _cleanupScanCache() {
    final cutoff = DateTime.now().subtract(
      Duration(minutes: _SCAN_CACHE_CLEANUP_MINUTES),
    );
    _lastSeenAt.removeWhere((_, time) => time.isBefore(cutoff));
    _lastRssiById.removeWhere((id, _) => !_lastSeenAt.containsKey(id));
    _log('Scan cache cleaned: ${_lastSeenAt.length} devices remaining');
  }

  void _cleanupTrackingMaps() {
    // Nettoyer les entrées de tracking pour les types obsolètes
    for (final side in ArmSide.values) {
      final recordTime = _lastRecordTime[side];
      final recordValue = _lastRecordedValue[side];

      if (recordTime != null && recordTime.length > 10) {
        final sorted = recordTime.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        final toKeep = sorted.take(10).map((e) => e.key).toSet();
        recordTime.removeWhere((key, _) => !toKeep.contains(key));
        recordValue?.removeWhere((key, _) => !toKeep.contains(key));

        _log(
            'Tracking maps cleaned for ${side.displayName}: kept ${toKeep.length} entries');
      }
    }
  }

  // ============================================================================
  // SERVICE ARRIÈRE-PLAN
  // ============================================================================

  void _listenToBackgroundService() {
    try {
      // Écouter les demandes de reconnexion
      FlutterBackgroundService().on('reconnect_request').listen((data) {
        if (data != null) {
          final side = data['side'] as String?;
          if (side == 'left' && !_armState(ArmSide.left).connected) {
            add(DualConnectArmRequested(ArmSide.left));
          } else if (side == 'right' && !_armState(ArmSide.right).connected) {
            add(DualConnectArmRequested(ArmSide.right));
          }
        }
      });

      // Écouter les demandes de collecte de données
      FlutterBackgroundService().on('collect_data').listen((data) {
        if (data != null) {
          final side = data['side'] as String?;
          if (side == 'left') {
            _collectDataForArm(ArmSide.left);
          } else if (side == 'right') {
            _collectDataForArm(ArmSide.right);
          }
        }
      });

      _log('Background service listeners configured', level: _LOG_INFO);
    } catch (e) {
      _log('Background service init failed: $e', level: _LOG_WARNING);
    }
  }

  /// Collecte les données pour un bras spécifique (appelé par le service background)
  Future<void> _collectDataForArm(ArmSide side) async {
    try {
      final session = _sessions[side];
      final armState = (side == ArmSide.left) ? state.left : state.right;

      if (session == null || !armState.connected) {
        _log('Cannot collect for $side: not connected', level: _LOG_WARNING);
        return;
      }

      _log('Collecting data for $side...', level: _LOG_INFO);

      // Lire la batterie
      add(DualReadBatteryRequested(side));

      // Attendre un peu entre les lectures
      await Future.delayed(const Duration(milliseconds: 200));

      // Lire les pas (steps) si la montre les supporte
      // Note: la lecture se fait automatiquement via les streams déjà en place

      _log('Data collection triggered for $side', level: _LOG_INFO);

    } catch (e) {
      _log('Error collecting data for $side: $e', level: _LOG_ERROR);
    }
  }

  void _notifyBackgroundService(ArmSide side, String status) {
    try {
      BackgroundInfiniTimeService.updateStatus(side.displayName, status);
    } catch (_) {}
  }

  // ============================================================================
  // DIAGNOSTIC
  // ============================================================================

  static const String _LOG_INFO = 'INFO';
  static const String _LOG_WARNING = 'WARNING';
  static const String _LOG_ERROR = 'ERROR';

  void _log(String message, {String level = _LOG_INFO}) {
    if (kDebugMode || level == _LOG_WARNING || level == _LOG_ERROR) {
      print('[$level] DualBLOC: $message');
    }
  }

  void _logConnectionDiagnostic(ArmSide side, String event) {
    final arm = _armState(side);
    final established = _connectionEstablishedAt[side];
    final lastAttempt = _lastConnectionAttempt[side];
    final retries = _retries[side] ?? 0;

    _log('''
      ╔════════════════════════════════════════╗
      ║ DIAGNOSTIC CONNEXION ${side.displayName.toUpperCase()}
      ╠════════════════════════════════════════╣
      ║ Event: $event
      ║ Connected: ${arm.connected}
      ║ Device ID: ${arm.deviceId}
      ║ Retries: $retries
      ║ Last Attempt: $lastAttempt
      ║ Established At: $established
      ║ Stable: ${_isConnectionStable(side)}
      ║ Battery: ${arm.battery}%
      ║ RSSI: ${arm.rssi} dBm
      ╚════════════════════════════════════════╝
      ''');
  }

  bool _isConnectionStable(ArmSide side) {
    final establishedAt = _connectionEstablishedAt[side];
    if (establishedAt == null) return false;
    final timeSinceConnection = DateTime.now().difference(establishedAt);
    return timeSinceConnection.inMilliseconds >= _STABLE_CONNECTION_DELAY_MS;
  }

  bool _canPerformOperation(ArmSide side) {
    final arm = _armState(side);
    final inProgress = _connectionInProgress[side];
    if (inProgress == null) return false;

    return arm.connected &&
        !inProgress &&
        _isConnectionStable(side) &&
        !arm.dfuRunning;
  }

  Future<T?> _safeOperation<T>(
    ArmSide side,
    Future<T> Function() operation,
    String operationName,
  ) async {
    if (!_canPerformOperation(side)) {
      _log(
        'Operation "$operationName" refused for ${side.displayName}: unstable connection',
        level: _LOG_WARNING,
      );
      return null;
    }

    try {
      return await operation();
    } catch (e) {
      _log('Error in $operationName for ${side.displayName}: $e',
          level: _LOG_ERROR);
      _logConnectionDiagnostic(side, 'ERROR_$operationName: $e');
      return null;
    }
  }

  // ============================================================================
  // CONNEXION PRINCIPALE
  // ============================================================================

  Future<void> _performConnection(
    ArmSide side,
    Emitter<DualInfiniTimeState> emit,
  ) async {
    final lock = _connectionLocks[side];
    if (lock == null) return;

    return await lock.synchronized(() async {
      final id = _armState(side).deviceId;
      if (id == null) {
        _log('No device ID for ${side.displayName}', level: _LOG_WARNING);
        return;
      }

      _logConnectionDiagnostic(side, 'TENTATIVE_CONNEXION');

      // Skip connection attempt if already connected
      // Check both state and active session to prevent reconnection loops
      final hasActiveSession = _sessions[side] != null;
      final isConnected = _armState(side).connected;
      final isStable = _isConnectionStable(side);

      if (isConnected && (isStable || hasActiveSession)) {
        _log(
          'Already connected for ${side.displayName} (stable: $isStable, session: $hasActiveSession), skipping reconnection',
          level: _LOG_INFO,
        );
        return;
      }

      if (_connectionInProgress[side] == true) {
        _log('Connection already in progress for ${side.displayName}');
        return;
      }

      final lastAttempt = _lastConnectionAttempt[side];
      if (lastAttempt != null) {
        final timeSinceLastAttempt = DateTime.now().difference(lastAttempt);
        if (timeSinceLastAttempt.inSeconds < 3) {
          _log('Connection attempt too rapid for ${side.displayName}');
          return;
        }
      }

      _connectionInProgress[side] = true;
      _lastConnectionAttempt[side] = DateTime.now();

      try {
        // Only disconnect if there's an existing session or connection
        // Avoid disconnecting phantom connections on app restart
        if (_sessions[side] != null || _armState(side).connected) {
          // Mark as disconnected before cleanup if we were connected
          if (_armState(side).connected) {
            emit(_withArm(side, _armState(side).copyWith(connected: false)));
          }

          await _fullDisconnectAndCleanup(side);
          await Future.delayed(_DELAY_BEFORE_RECONNECT);
        } else {
          _log('No existing session for ${side.displayName}, proceeding with fresh connection', level: _LOG_INFO);
        }

        if (!await _ensureBluetoothReady()) {
          throw Exception('Bluetooth not ready');
        }

        final session = InfiniTimeSession(ble, id);

        await session.connectAndSetup().timeout(
              Duration(seconds: _CONNECTION_TIMEOUT_SECONDS),
              onTimeout: () => throw TimeoutException(
                'Connection timeout',
                Duration(seconds: _CONNECTION_TIMEOUT_SECONDS),
              ),
            );

        _sessions[side] = session;
        _connectionEstablishedAt[side] = DateTime.now();
        _connectedAt[side] = DateTime.now();

        await _setupSessionStreams(side, session);
        await Future.delayed(_DELAY_AFTER_CONNECTION);

        await _performInitialReads(side, session);

        emit(_withArm(side, _armState(side).copyWith(connected: true)));
        _retries[side] = 0;
        _restartSharedRssiIfNeeded();

        _log('Connection successful for ${side.displayName}', level: _LOG_INFO);
        _logConnectionDiagnostic(side, 'CONNEXION_REUSSIE');

        _notifyBackgroundService(side, 'connecté');

        _recordConnectionEvent(
          side,
          ConnectionEventType.connected,
          batteryAtConnection: _armState(side).battery,
          rssiAtConnection: _armState(side).rssi,
        );

        // Schedule device info read after connection is stable
        Timer(Duration(milliseconds: _STABLE_CONNECTION_DELAY_MS + 500), () {
          if (_armState(side).connected && _isConnectionStable(side)) {
            add(DualReadDeviceInfoRequested(side));
          }
        });
      } catch (error) {
        _log('Connection error for ${side.displayName}: $error',
            level: _LOG_ERROR);
        _logConnectionDiagnostic(side, 'ERREUR_CONNEXION: $error');

        _recordConnectionEvent(
          side,
          ConnectionEventType.connectionFailed,
          errorMessage: error.toString(),
        );

        await _fullDisconnectAndCleanup(side);
        _scheduleReconnectWithBackoff(side);
      } finally {
        _connectionInProgress[side] = false;
      }
    });
  }

  // ============================================================================
  // ÉVÉNEMENTS: BINDING
  // ============================================================================

  Future<void> _onLoadBindings(
    DualLoadBindingsRequested e,
    Emitter<DualInfiniTimeState> emit,
  ) async {
    try {
      // Prevent multiple loads
      if (_bindingsLoaded) {
        _log('Bindings already loaded, skipping', level: _LOG_INFO);
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final leftId = prefs.getString(ArmSide.left.deviceKey);
      final rightId = prefs.getString(ArmSide.right.deviceKey);

      final leftSyncMs = prefs.getInt(ArmSide.left.syncKey);
      final rightSyncMs = prefs.getInt(ArmSide.right.syncKey);

      if (leftId != null && rightId != null && leftId == rightId) {
        _log('Duplicate device binding detected, removing right side');
        await prefs.remove(ArmSide.right.deviceKey);
        emit(_withArm(
          ArmSide.right,
          _armState(ArmSide.right).copyWith(
            clearId: true,
            connected: false,
            clearMotion: true,
            lastSync: null,
          ),
        ));
        _bindingsLoaded = true;
        return;
      }

      emit(state.copyWith(
        left: state.left.copyWith(
          deviceId: leftId,
          lastSync: leftSyncMs != null
              ? DateTime.fromMillisecondsSinceEpoch(leftSyncMs)
              : null,
        ),
        right: state.right.copyWith(
          deviceId: rightId,
          lastSync: rightSyncMs != null
              ? DateTime.fromMillisecondsSinceEpoch(rightSyncMs)
              : null,
        ),
      ));

      _log('Bindings loaded: Left=$leftId, Right=$rightId', level: _LOG_INFO);

      // Mark as loaded BEFORE attempting connections
      _bindingsLoaded = true;

      // Delay connection attempts to allow BLE stack to initialize
      // and detect existing connections
      await Future.delayed(const Duration(milliseconds: 500));

      // Only attempt connection if not already connected
      // Check both state and session existence
      if (leftId != null && !_armState(ArmSide.left).connected && _sessions[ArmSide.left] == null) {
        _log('Initiating connection for left device', level: _LOG_INFO);
        add(DualConnectArmRequested(ArmSide.left));
      } else if (leftId != null) {
        _log('Left device already connected or session exists, skipping connection attempt', level: _LOG_INFO);
      }

      if (rightId != null && !_armState(ArmSide.right).connected && _sessions[ArmSide.right] == null) {
        _log('Initiating connection for right device', level: _LOG_INFO);
        add(DualConnectArmRequested(ArmSide.right));
      } else if (rightId != null) {
        _log('Right device already connected or session exists, skipping connection attempt', level: _LOG_INFO);
      }
    } catch (e) {
      _log('Error loading bindings: $e', level: _LOG_ERROR);
    }
  }

  Future<void> _onBindArm(
    DualBindArmRequested e,
    Emitter<DualInfiniTimeState> emit,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final other = e.side.opposite;
      final otherId = _armState(other).deviceId;
      if (otherId == e.deviceId) {
        _log(
          'Device ${e.deviceId} already bound to ${other.displayName}, removing',
        );
        await prefs.remove(other.deviceKey);
        emit(_withArm(
          other,
          _armState(other).copyWith(
            clearId: true,
            connected: false,
            clearMotion: true,
            lastSync: null,
          ),
        ));
      }

      await prefs.setString(e.side.deviceKey, e.deviceId);
      emit(_withArm(
        e.side,
        _armState(e.side).copyWith(
          deviceId: e.deviceId,
          name: e.name,
        ),
      ));

      _log('Device ${e.deviceId} bound to ${e.side.displayName}');
    } catch (e) {
      _log('Error binding arm: $e', level: _LOG_ERROR);
    }
  }

  Future<void> _onUnbindArm(
    DualUnbindArmRequested e,
    Emitter<DualInfiniTimeState> emit,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(e.side.deviceKey);
      await prefs.remove(e.side.syncKey);
      await _disconnectAndDispose(e.side);

      emit(_withArm(
        e.side,
        _armState(e.side).copyWith(
          clearId: true,
          connected: false,
          clearMotion: true,
          lastSync: null,
        ),
      ));

      // Reset bindings flag to allow reload
      _bindingsLoaded = false;

      _log('Device unbound from ${e.side.displayName}', level: _LOG_INFO);
    } catch (e) {
      _log('Error unbinding arm: $e', level: _LOG_ERROR);
    }
  }

  // ============================================================================
  // ÉVÉNEMENTS: CONNEXION
  // ============================================================================

  Future<void> _onBindAndConnectArm(
    DualBindAndConnectArmRequested e,
    Emitter<DualInfiniTimeState> emit,
  ) async {
    add(DualBindArmRequested(e.side, e.deviceId, name: e.name));
    await Future.delayed(const Duration(milliseconds: 100));
    add(DualConnectArmRequested(e.side));
  }

  Future<void> _onConnectArm(
    DualConnectArmRequested e,
    Emitter<DualInfiniTimeState> emit,
  ) async {
    await _performConnection(e.side, emit);
  }

  Future<void> _onDisconnectArm(
    DualDisconnectArmRequested e,
    Emitter<DualInfiniTimeState> emit,
  ) async {
    final connectedAt = _connectedAt[e.side];
    final durationSeconds = connectedAt != null
        ? DateTime.now().difference(connectedAt).inSeconds
        : null;

    _recordConnectionEvent(
      e.side,
      ConnectionEventType.disconnected,
      reason: 'User disconnection',
      durationSeconds: durationSeconds,
    );
    _connectedAt[e.side] = null;

    await _cancelReconnect(e.side);
    await _disconnectAndDispose(e.side);

    emit(_withArm(
      e.side,
      _armState(e.side).copyWith(connected: false, clearMotion: true),
    ));

    await _scanSub?.cancel();

    final otherStillConnected =
        ArmSide.values.any((s) => s != e.side && _armState(s).connected);
    if (!otherStillConnected) {
      await _stopSharedRssiScan();
    } else {
      _startSharedRssiScanIfNeeded();
    }

    _notifyBackgroundService(e.side, 'déconnecté');
    _log('Disconnected ${e.side.displayName}', level: _LOG_INFO);
  }

  void _onArmConnected(ArmConnected e, Emitter<DualInfiniTimeState> emit) {
    emit(_withArm(e.side, _armState(e.side).copyWith(connected: true)));
    _retries[e.side] = 0;
    final anyConnected = ArmSide.values.any((s) => _armState(s).connected);
    if (anyConnected) _startSharedRssiScanIfNeeded();
    _notifyBackgroundService(e.side, 'connecté');
    _log('Arm connected: ${e.side.displayName}', level: _LOG_INFO);
  }

  Future<void> _onArmDisconnected(
    ArmDisconnected e,
    Emitter<DualInfiniTimeState> emit,
  ) async {
    final connectedAt = _connectedAt[e.side];
    final durationSeconds = connectedAt != null
        ? DateTime.now().difference(connectedAt).inSeconds
        : null;

    _recordConnectionEvent(
      e.side,
      ConnectionEventType.disconnected,
      reason: 'Unexpected disconnection',
      durationSeconds: durationSeconds,
    );
    _connectedAt[e.side] = null;

    await _disposeArmSession(e.side);
    emit(_withArm(e.side, _armState(e.side).copyWith(connected: false)));

    _scheduleReconnectWithBackoff(e.side);
    _notifyBackgroundService(e.side, 'déconnecté');

    final anyOtherConnected =
        ArmSide.values.any((s) => s != e.side && _armState(s).connected);
    if (!anyOtherConnected) await _stopSharedRssiScan();

    _log('Arm disconnected: ${e.side.displayName}', level: _LOG_WARNING);
  }

  // ============================================================================
  // ÉVÉNEMENTS: SCAN
  // ============================================================================

  bool _isPineTime(DiscoveredDevice d) {
    final n = d.name.toLowerCase();
    return n.contains('infinitime') ||
        n.contains('pinetime') ||
        n.contains('pine time');
  }

  Future<void> _onScan(
    DualScanRequested e,
    Emitter<DualInfiniTimeState> emit,
  ) async {
    if (!(await _ensurePerms())) {
      _log('Insufficient permissions for scan', level: _LOG_ERROR);
      return;
    }

    await _stopSharedRssiScan();
    await _scanSub?.cancel();

    emit(state.copyWith(scanning: true, lastScan: {}));

    _scanSub = ble.scanForDevices(
      withServices: const [],
      scanMode: ScanMode.lowLatency,
      requireLocationServicesEnabled: true,
    ).listen(
      (d) {
        if (_isPineTime(d)) {
          final now = DateTime.now();
          final last = _lastSeenAt[d.id];
          if (last == null ||
              now.difference(last).inMilliseconds >= _SCAN_THROTTLE_MS) {
            _lastSeenAt[d.id] = now;
            add(OnFoundDevice(d));
          }
        }
      },
      onError: (e) {
        _log('Scan error: $e', level: _LOG_ERROR);
      },
    );

    _scanTimer?.cancel();
    _scanTimer = Timer(Duration(seconds: _SCAN_TIMEOUT_SECONDS), () {
      add(ScanTimedOut());
    });

    _log('Scan started', level: _LOG_INFO);
  }

  Future<void> _onScanStop(
    DualScanStopRequested e,
    Emitter<DualInfiniTimeState> emit,
  ) async {
    await _scanSub?.cancel();
    _scanSub = null;
    _scanTimer?.cancel();
    _scanTimer = null;

    emit(state.copyWith(scanning: false));

    final anyConnected = ArmSide.values.any((s) => _armState(s).connected);
    if (anyConnected) _startSharedRssiScanIfNeeded();

    _log('Scan stopped', level: _LOG_INFO);
  }

  void _onFoundDevice(OnFoundDevice e, Emitter<DualInfiniTimeState> emit) {
    bool isDeviceLinked = false;

    for (final side in ArmSide.values) {
      final id = _armState(side).deviceId;
      if (id != null && id == e.device.id) {
        isDeviceLinked = true;
        final displayName =
            e.device.name.isNotEmpty ? e.device.name : _armState(side).name;
        emit(_withArm(
          side,
          _armState(side).copyWith(
            name: displayName,
            rssi: e.device.rssi,
          ),
        ));
        break;
      }
    }

    if (!isDeviceLinked) {
      add(OnScanAddDevice(e.device));
    }
  }

  void _onScanAddDevice(OnScanAddDevice e, Emitter<DualInfiniTimeState> emit) {
    if (_isDeviceAlreadyBound(e.device.id)) {
      _log('Device ${e.device.id} already bound, ignored', level: _LOG_WARNING);
      return;
    }

    final m = Map<String, DiscoveredDevice>.from(state.lastScan);
    m[e.device.id] = e.device;
    emit(state.copyWith(lastScan: m));
  }

  bool _isDeviceAlreadyBound(String deviceId) {
    return state.left.deviceId == deviceId || state.right.deviceId == deviceId;
  }

  Future<void> _onScanTimedOut(
    ScanTimedOut e,
    Emitter<DualInfiniTimeState> emit,
  ) async {
    await _scanSub?.cancel();
    _scanSub = null;
    _scanTimer?.cancel();
    _scanTimer = null;

    emit(state.copyWith(scanning: false));

    final anyConnected = ArmSide.values.any((s) => _armState(s).connected);
    if (anyConnected) _startSharedRssiScanIfNeeded();

    _log('Scan timeout', level: _LOG_WARNING);
  }

  // ============================================================================
  // ÉVÉNEMENTS: GATT & DEVICE INFO
  // ============================================================================

  Future<void> _onDiscoverGatt(
    DualDiscoverGattRequested e,
    Emitter<DualInfiniTimeState> emit,
  ) async {
    final id = _armState(e.side).deviceId;
    if (id == null) return;

    await _scanSub?.cancel();
    await _stopSharedRssiScan();

    try {
      await ble.discoverAllServices(id);
      final services = await ble.getDiscoveredServices(id);
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

      add(OnArmGattDump(e.side, chars, noti, indi));
      _log(
        'GATT discovered for ${e.side.displayName}: ${services.length} services',
      );
    } catch (ex) {
      _log('GATT discovery error for ${e.side.displayName}: $ex',
          level: _LOG_ERROR);
    } finally {
      final anyConnected = ArmSide.values.any((s) => _armState(s).connected);
      if (anyConnected) _startSharedRssiScanIfNeeded();
    }
  }

  void _onArmGattDump(OnArmGattDump e, Emitter<DualInfiniTimeState> emit) {
    emit(_withArm(
      e.side,
      _armState(e.side).copyWith(
        chars: e.chars,
        notifiable: e.noti,
        indicatable: e.indi,
      ),
    ));
  }

  Future<void> _onReadDeviceInfo(
    DualReadDeviceInfoRequested e,
    Emitter<DualInfiniTimeState> emit,
  ) async {
    final session = _sessions[e.side];
    if (session == null) return;

    final info = await _safeOperation(
      e.side,
      () => session.readDeviceInfo(),
      'READ_DEVICE_INFO',
    );

    if (info == null) return;

    final deviceInfo = info.map((key, value) => MapEntry(key, value ?? '-'));
    emit(_withArm(e.side, _armState(e.side).copyWith(deviceInfo: deviceInfo)));

    final line = [
      'Device ${e.side.displayName}:',
      'Manufacturer: ${deviceInfo['manufacturer']}',
      'Model: ${deviceInfo['model']}',
      'Firmware: ${deviceInfo['firmware']}',
      'Hardware: ${deviceInfo['hardware']}',
    ].join(' | ');

    final cur = _armState(e.side).log;
    emit(_withArm(
      e.side,
      _armState(e.side).copyWith(log: cur.isEmpty ? line : '$cur\n$line'),
    ));

    _log('Device info read for ${e.side.displayName}', level: _LOG_INFO);
  }

  // ============================================================================
  // ÉVÉNEMENTS: SYNCHRONISATION
  // ============================================================================

  Future<void> _onSyncTime(
    DualSyncTimeRequested e,
    Emitter<DualInfiniTimeState> emit,
  ) async {
    final session = _sessions[e.side];
    if (session == null) return;

    // Envoyer l'heure locale car la montre affiche l'heure telle quelle
    final localTime = DateTime.now();
    await _safeOperation(
      e.side,
      () => session.syncTimeUtc(localTime),
      'SYNC_TIME',
    );
    add(OnArmSynced(e.side, localTime));
  }

  Future<void> _onReadBattery(
    DualReadBatteryRequested e,
    Emitter<DualInfiniTimeState> emit,
  ) async {
    final session = _sessions[e.side];
    if (session == null) return;

    final battery = await _safeOperation(
      e.side,
      () => session.readBattery(),
      'READ_BATTERY',
    );

    if (battery != null) {
      add(OnArmBattery(e.side, battery));
      _log(
        'Battery read for ${e.side.displayName}: $battery%',
        level: _LOG_INFO,
      );
    }
  }

  Future<void> _onArmSynced(
    OnArmSynced e,
    Emitter<DualInfiniTimeState> emit,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(e.side.syncKey, e.at.millisecondsSinceEpoch);
      emit(_withArm(e.side, _armState(e.side).copyWith(lastSync: e.at)));
      _log('Time synced for ${e.side.displayName}', level: _LOG_INFO);
    } catch (ex) {
      _log(
        'Error syncing time for ${e.side.displayName}: $ex',
        level: _LOG_ERROR,
      );
    }
  }

  // ============================================================================
  // FIRMWARE DFU
  // ============================================================================

  Future<void> _onLoadAvailableFirmwares(
    DualLoadAvailableFirmwaresRequested e,
    Emitter<DualInfiniTimeState> emit,
  ) async {
    emit(state.copyWith(loadingFirmwares: true));

    try {
      final firmwares = await _loadFirmwaresFromAssets();
      emit(state.copyWith(
        availableFirmwares: firmwares,
        loadingFirmwares: false,
      ));
      _log('${firmwares.length} firmwares loaded', level: _LOG_INFO);
    } catch (e) {
      _log('Error loading firmwares: $e', level: _LOG_ERROR);
      emit(state.copyWith(
        availableFirmwares: [],
        loadingFirmwares: false,
      ));
    }
  }

  void _onAvailableFirmwaresLoaded(
    OnAvailableFirmwaresLoaded e,
    Emitter<DualInfiniTimeState> emit,
  ) {
    emit(state.copyWith(
      availableFirmwares: e.firmwares,
      loadingFirmwares: false,
    ));
  }

  Future<void> _onSelectFirmware(
    DualSelectFirmwareRequested e,
    Emitter<DualInfiniTimeState> emit,
  ) async {
    final newSelectedFirmwares =
        Map<ArmSide, FirmwareInfo?>.from(state.selectedFirmwares);
    newSelectedFirmwares[e.side] = e.firmware;
    emit(state.copyWith(selectedFirmwares: newSelectedFirmwares));
    _log(
      'Firmware selected for ${e.side.displayName}: ${e.firmware.fileName}',
    );
  }

  Future<List<FirmwareInfo>> _loadFirmwaresFromAssets() async {
    try {
      final manager = FirmwareManager(FirmwareSource());
      return await manager.loadAvailableFirmwares();
    } catch (e) {
      _log('Error loading firmwares: $e', level: _LOG_ERROR);
      return [];
    }
  }

  Future<void> _onSystemFirmwareDfuStart(
    DualSystemFirmwareDfuStartRequested e,
    Emitter<DualInfiniTimeState> emit,
  ) async {
    final session = _sessions[e.side];
    if (session == null) return;

    if (!_canPerformOperation(e.side)) {
      _log(
        'DFU firmware refused for ${e.side.displayName}: unstable connection',
        level: _LOG_WARNING,
      );
      return;
    }

    try {
      emit(_withArm(e.side, _armState(e.side).copyWith(dfuRunning: true)));

      await session.startSystemFirmwareDfu(
        e.firmwarePath,
        reconnectOnComplete: true,
      );

      _log('DFU started for ${e.side.displayName}', level: _LOG_INFO);
    } catch (error) {
      _log(
        'DFU error for ${e.side.displayName}: $error',
        level: _LOG_ERROR,
      );
      emit(_withArm(
        e.side,
        _armState(e.side).copyWith(
          dfuRunning: false,
          dfuPercent: 0,
          dfuPhase: 'Error: $error',
        ),
      ));
    }
  }

  Future<void> _onSystemFirmwareDfuAbort(
    DualSystemFirmwareDfuAbortRequested e,
    Emitter<DualInfiniTimeState> emit,
  ) async {
    final session = _sessions[e.side];
    if (session == null) return;

    try {
      await session.abortSystemFirmwareDfu();
      emit(_withArm(
        e.side,
        _armState(e.side).copyWith(
          dfuRunning: false,
          dfuPercent: 0,
          dfuPhase: 'DFU aborted',
        ),
      ));
      _log('DFU aborted for ${e.side.displayName}', level: _LOG_INFO);
    } catch (ex) {
      _log(
        'DFU abort error for ${e.side.displayName}: $ex',
        level: _LOG_ERROR,
      );
    }
  }

  void _onSystemFirmwareDfuProgress(
    OnArmSystemFirmwareDfu e,
    Emitter<DualInfiniTimeState> emit,
  ) {
    emit(_withArm(
      e.side,
      _armState(e.side).copyWith(
        dfuRunning: e.p.percent < 100,
        dfuPercent: e.p.percent,
        dfuPhase: e.p.phase,
      ),
    ));
  }

  // ============================================================================
  // MUSIQUE & NAVIGATION
  // ============================================================================

  Future<void> _onMusicMeta(
    DualMusicMetaRequested e,
    Emitter<DualInfiniTimeState> emit,
  ) async {
    final session = _sessions[e.side];
    if (session == null) return;

    await _safeOperation(
      e.side,
      () => session.musicSetMeta(
        artist: e.artist,
        track: e.track,
        album: e.album,
      ),
      'MUSIC_META',
    );
  }

  Future<void> _onMusicPlayPause(
    DualMusicPlayPauseRequested e,
    Emitter<DualInfiniTimeState> emit,
  ) async {
    final session = _sessions[e.side];
    if (session == null) return;

    await _safeOperation(
      e.side,
      () => session.musicSetPlaying(e.play),
      'MUSIC_PLAY_PAUSE',
    );
  }

  void _onArmMusicEvent(OnArmMusicEvent e, Emitter<DualInfiniTimeState> emit) {
    final line = 'Music event ${e.side.displayName}: ${e.event}';
    final cur = _armState(e.side).log;
    emit(_withArm(
      e.side,
      _armState(e.side).copyWith(log: cur.isEmpty ? line : '$cur\n$line'),
    ));
  }

  void _onArmCallEvent(OnArmCallEvent e, Emitter<DualInfiniTimeState> emit) {
    final line = 'Call event ${e.side.displayName}: ${e.event}';
    final cur = _armState(e.side).log;
    emit(_withArm(
      e.side,
      _armState(e.side).copyWith(log: cur.isEmpty ? line : '$cur\n$line'),
    ));
  }

  Future<void> _onNavSend(
    DualNavSendRequested e,
    Emitter<DualInfiniTimeState> emit,
  ) async {
    final session = _sessions[e.side];
    if (session == null) return;

    await _safeOperation(e.side, () async {
      await session.navNarrativeSet(e.narrative);
      await session.navManDistSet(e.distance);
      await session.navProgressSet(e.progress);
      await session.navFlagsSet(e.flags);
    }, 'NAV_SEND');
  }

  Future<void> _onWeatherSend(
    DualWeatherSendRequested e,
    Emitter<DualInfiniTimeState> emit,
  ) async {
    final session = _sessions[e.side];
    if (session == null) return;

    await _safeOperation(
      e.side,
      () => session.weatherWrite(e.payload),
      'WEATHER_SEND',
    );
  }

  // ============================================================================
  // BLEFS
  // ============================================================================

  Future<void> _onBlefsReadVersion(
    DualBlefsReadVersionRequested e,
    Emitter<DualInfiniTimeState> emit,
  ) async {
    final session = _sessions[e.side];
    if (session == null) {
      _log('Session not available for ${e.side.displayName}');
      return;
    }

    final v = await _safeOperation(
      e.side,
      () => session.blefsReadVersion(),
      'BLEFS_READ_VERSION',
    );

    if (v != null) {
      _log('BLEFS version for ${e.side.displayName}: $v', level: _LOG_INFO);
    }
  }

  Future<void> _onBlefsSendRaw(
    DualBlefsSendRawRequested e,
    Emitter<DualInfiniTimeState> emit,
  ) async {
    final session = _sessions[e.side];
    if (session == null) return;

    await _safeOperation(
      e.side,
      () => session.blefsWriteRaw(e.payload),
      'BLEFS_SEND_RAW',
    );
  }

  // ============================================================================
  // MOTION & DATA - NOUVELLE STRUCTURE
  // ============================================================================

  Future<void> _onMotionThrottle(
    DualMotionThrottleChanged e,
    Emitter<DualInfiniTimeState> emit,
  ) async {
    final session = _sessions[e.side];
    if (session == null) return;
    session.motionMinInterval = e.minInterval;
  }

  void _onArmBattery(OnArmBattery e, Emitter<DualInfiniTimeState> emit) {
    _log('OnArmBattery: side=${e.side.displayName}, value=${e.v}%');
    emit(_withArm(e.side, _armState(e.side).copyWith(battery: e.v)));

    // Enregistrer dans device_info_data avec throttling
    final lastValue = _lastRecordedValue[e.side]?['battery'];
    if (lastValue == null || (e.v - lastValue).abs() > 1) {
      _log('Battery changed significantly, buffering...');
      _bufferDeviceInfo(e.side, 'battery', e.v.toDouble());

      final recordMap = _lastRecordedValue[e.side];
      if (recordMap != null) {
        recordMap['battery'] = e.v;
      }
    }
  }

  void _onArmSteps(OnArmSteps e, Emitter<DualInfiniTimeState> emit) {
    _log(' Steps data received: side=${e.side.displayName}, value=${e.v} steps');
    emit(_withArm(e.side, _armState(e.side).copyWith(steps: e.v)));

    // Enregistrer immédiatement sans throttling
    _log('Recording steps to buffer...');
    _bufferDeviceInfo(e.side, 'steps', e.v.toDouble());

    final recordTime = _lastRecordTime[e.side];
    if (recordTime != null) {
      recordTime['steps'] = DateTime.now();
    }
  }

  void _onArmMotion(OnArmMotion e, Emitter<DualInfiniTimeState> emit) {
    _log(
        'OnArmMotion: side=${e.side.displayName}, xyz=[${e.xyz[0]}, ${e.xyz[1]}, ${e.xyz[2]}]');
    emit(_withArm(
        e.side, _armState(e.side).copyWith(motion: List<int>.from(e.xyz))));

    // Les données motion ne sont pas enregistrées directement
    // Elles seront enregistrées via le Movement stream (service BLE 0x0006)
    // qui fournit des données agrégées et analysées
  }

  void _onArmRssi(OnArmRssi e, Emitter<DualInfiniTimeState> emit) {
    _log('OnArmRssi: side=${e.side.displayName}, rssi=${e.rssi} dBm');
    emit(_withArm(e.side, _armState(e.side).copyWith(rssi: e.rssi)));

    // Enregistrer RSSI dans device_info_data avec throttling
    // Enregistrer immédiatement sans throttling
    _log('Recording RSSI to buffer...');
    _bufferDeviceInfo(e.side, 'rssi', e.rssi.toDouble());

    final recordTime = _lastRecordTime[e.side];
    if (recordTime != null) {
      recordTime['rssi'] = DateTime.now();
    }
  }

  // ============================================================================
  // BUFFER MANAGEMENT - NOUVELLE STRUCTURE
  // ============================================================================

  /// Ajoute une donnée au buffer device_info
  void _bufferDeviceInfo(ArmSide side, String infoType, double value) {
    final buffer = _deviceInfoBuffer[side];
    if (buffer == null) {
      _log('ERROR: Device info buffer not initialized for $side',
          level: _LOG_ERROR);
      return;
    }

    // Protection OOM
    if (buffer.length >= _MAX_DEVICE_INFO_BUFFER_SIZE) {
      _log(
        'WARNING: Device info buffer full (${buffer.length}), flushing...',
        level: _LOG_WARNING,
      );
      _flushDeviceInfoBuffer(side);
    }

    buffer.add({
      'armSide': side.name,
      'infoType': infoType,
      'value': value,
      'timestamp': DateTime.now(),
    });

    _log('Buffered $infoType for ${side.displayName}: $value (buffer size: ${buffer.length})');

    // Flush automatique toutes les 5 entrées (réduit de 20 pour des résultats plus rapides)
    if (buffer.length >= 5) {
      _log('Buffer threshold reached (5 entries), flushing device_info...');
      _flushDeviceInfoBuffer(side);
    }
  }

  /// Ajoute une donnée au buffer movement avec filtrage selon les paramètres de sampling
  /// Calcule également les deltas pour magnitudeActiveTime et axisActiveTime
  void _bufferMovement(
    ArmSide side,
    MovementData movement,
  ) {
    final buffer = _movementBuffer[side];
    if (buffer == null) {
      _log('ERROR: Movement buffer not initialized for $side',
          level: _LOG_ERROR);
      return;
    }

    // Appliquer le filtrage selon le mode de sampling
    if (!_shouldSampleMovement(side, movement)) {
      return; // Échantillon filtré
    }

    // Protection OOM
    if (buffer.length >= _MAX_MOVEMENT_BUFFER_SIZE) {
      _log(
        'WARNING: Movement buffer full (${buffer.length}), flushing...',
        level: _LOG_WARNING,
      );
      _flushMovementBuffer(side);
    }

    // Calculer les deltas pour magnitudeActiveTime et axisActiveTime
    // Ces valeurs sont cumulatives depuis le boot de la montre
    final lastMag = _lastMagnitudeActiveTime[side];
    final lastAxis = _lastAxisActiveTime[side];

    int magnitudeDelta = 0;
    int axisDelta = 0;

    if (lastMag != null && lastAxis != null) {
      // Calculer la différence (delta) depuis la dernière lecture
      // Si la valeur actuelle est inférieure (montre redémarrée), on prend la valeur actuelle comme delta
      magnitudeDelta = movement.magnitudeActiveTime >= lastMag
          ? movement.magnitudeActiveTime - lastMag
          : movement.magnitudeActiveTime;
      axisDelta = movement.axisActiveTime >= lastAxis
          ? movement.axisActiveTime - lastAxis
          : movement.axisActiveTime;

      _log('Delta calculated for ${side.displayName}: magDelta=${magnitudeDelta}ms, axisDelta=${axisDelta}ms');
    } else {
      // Première lecture, pas de delta calculable (on considère 0)
      _log('First movement reading for ${side.displayName}, no delta yet');
    }

    // Mettre à jour les dernières valeurs cumulatives
    _lastMagnitudeActiveTime[side] = movement.magnitudeActiveTime;
    _lastAxisActiveTime[side] = movement.axisActiveTime;

    buffer.add(movement);

    _log('Buffered movement for ${side.displayName}: mag=${movement.magnitudeActiveTime}ms, axis=${movement.axisActiveTime}ms (buffer size: ${buffer.length})');

    // Flush automatique selon maxSamplesPerFlush configuré
    final flushThreshold = _movementSamplingSettings.maxSamplesPerFlush ~/ 6; // ~10 par défaut
    if (buffer.length >= flushThreshold) {
      _log('Movement buffer threshold reached ($flushThreshold entries), flushing...');
      _flushMovementBuffer(side);
    }
  }

  /// Détermine si un échantillon de mouvement doit être gardé selon les paramètres de sampling
  bool _shouldSampleMovement(ArmSide side, MovementData movement) {
    final now = DateTime.now();
    final lastSampleTime = _lastMovementSampleTime[side];
    final lastMagnitude = _lastMovementMagnitude[side];
    final currentMagnitude = movement.getAccelerationMagnitude();

    switch (_movementSamplingSettings.mode) {
      case MovementSamplingMode.all:
        // Tout garder
        _lastMovementSampleTime[side] = now;
        _lastMovementMagnitude[side] = currentMagnitude;
        return true;

      case MovementSamplingMode.interval:
        // Garder un échantillon par intervalle
        if (lastSampleTime == null) {
          _lastMovementSampleTime[side] = now;
          _lastMovementMagnitude[side] = currentMagnitude;
          return true;
        }

        final elapsed = now.difference(lastSampleTime).inMilliseconds;
        if (elapsed >= _movementSamplingSettings.intervalMs) {
          _lastMovementSampleTime[side] = now;
          _lastMovementMagnitude[side] = currentMagnitude;
          return true;
        }
        return false;

      case MovementSamplingMode.threshold:
        // Garder uniquement lors de changements significatifs
        if (lastMagnitude == null) {
          _lastMovementSampleTime[side] = now;
          _lastMovementMagnitude[side] = currentMagnitude;
          return true;
        }

        final change = (currentMagnitude - lastMagnitude).abs();
        if (change >= _movementSamplingSettings.changeThreshold) {
          _lastMovementSampleTime[side] = now;
          _lastMovementMagnitude[side] = currentMagnitude;
          return true;
        }
        return false;

      case MovementSamplingMode.aggregate:
        // Accumuler et calculer la moyenne sur l'intervalle
        return _handleAggregateMode(side, movement, now);

      case MovementSamplingMode.recordsPerTimeUnit:
        // Utiliser l'intervalle calculé à partir du nombre d'enregistrements par unité de temps
        if (lastSampleTime == null) {
          _lastMovementSampleTime[side] = now;
          _lastMovementMagnitude[side] = currentMagnitude;
          return true;
        }

        final elapsed = now.difference(lastSampleTime).inMilliseconds;
        final calculatedInterval = _movementSamplingSettings.calculatedIntervalMs;
        if (elapsed >= calculatedInterval) {
          _lastMovementSampleTime[side] = now;
          _lastMovementMagnitude[side] = currentMagnitude;
          return true;
        }
        return false;
    }
  }

  /// Gère le mode d'agrégation - accumule les données et calcule une moyenne
  bool _handleAggregateMode(ArmSide side, MovementData movement, DateTime now) {
    final aggregateBuffer = _movementAggregateBuffer[side];
    if (aggregateBuffer == null) return false;

    aggregateBuffer.add(movement);

    final lastSampleTime = _lastMovementSampleTime[side];
    if (lastSampleTime == null) {
      _lastMovementSampleTime[side] = now;
      return false; // Attendre d'avoir plus de données
    }

    final elapsed = now.difference(lastSampleTime).inMilliseconds;
    if (elapsed >= _movementSamplingSettings.intervalMs && aggregateBuffer.isNotEmpty) {
      // Calculer la moyenne et remplacer le mouvement actuel par l'agrégat
      // Note: On ne peut pas modifier movement, donc on ajoute directement au buffer principal
      final avgMovement = _calculateAggregateMovement(aggregateBuffer);
      aggregateBuffer.clear();
      _lastMovementSampleTime[side] = now;

      // Ajouter directement au buffer principal
      final buffer = _movementBuffer[side];
      if (buffer != null) {
        buffer.add(avgMovement);
        _log('Aggregated ${aggregateBuffer.length} samples for ${side.displayName}');
      }
      return false; // On a déjà ajouté manuellement
    }

    return false; // En cours d'accumulation
  }

  /// Calcule un MovementData agrégé à partir d'une liste
  MovementData _calculateAggregateMovement(List<MovementData> samples) {
    if (samples.isEmpty) {
      return MovementData(
        timestampMs: DateTime.now().millisecondsSinceEpoch,
        magnitudeActiveTime: 0,
        axisActiveTime: 0,
        movementDetected: false,
        anyMovement: false,
        accelX: 0,
        accelY: 0,
        accelZ: 0,
      );
    }

    final count = samples.length;
    double sumX = 0, sumY = 0, sumZ = 0;
    int maxMagnitudeTime = 0, maxAxisTime = 0;
    bool anyDetected = false, anyMoved = false;

    for (final s in samples) {
      sumX += s.accelX;
      sumY += s.accelY;
      sumZ += s.accelZ;
      if (s.magnitudeActiveTime > maxMagnitudeTime) {
        maxMagnitudeTime = s.magnitudeActiveTime;
      }
      if (s.axisActiveTime > maxAxisTime) {
        maxAxisTime = s.axisActiveTime;
      }
      anyDetected = anyDetected || s.movementDetected;
      anyMoved = anyMoved || s.anyMovement;
    }

    return MovementData(
      timestampMs: samples.last.timestampMs,
      magnitudeActiveTime: maxMagnitudeTime,
      axisActiveTime: maxAxisTime,
      movementDetected: anyDetected,
      anyMovement: anyMoved,
      accelX: sumX / count,
      accelY: sumY / count,
      accelZ: sumZ / count,
    );
  }

  /// Flush le buffer device_info d'un bras
  Future<void> _flushDeviceInfoBuffer(ArmSide side) async {
    final lock = _bufferFlushLocks[side];
    if (lock == null) return;

    return await lock.synchronized(() async {
      final buffer = _deviceInfoBuffer[side];
      if (buffer == null || buffer.isEmpty) {
        _log('Device info buffer is empty for ${side.displayName}, skipping flush');
        return;
      }

      _log(
          'Flushing ${buffer.length} device info records for ${side.displayName}...');

      final dataToInsert = List<Map<String, dynamic>>.from(buffer);

      try {
        await _db.insertBatchDeviceInfo(dataToInsert);
        buffer.clear();
        _log(
            'Flushed ${dataToInsert.length} device info records for ${side.displayName}', level: _LOG_INFO);

        // Notifier les graphiques qu'il y a de nouvelles données
        ChartRefreshNotifier().notifyAllDataUpdated();
      } catch (e) {
        _log('Error flushing device info buffer: $e', level: _LOG_ERROR);
      }
    });
  }

  /// Flush le buffer movement d'un bras
  Future<void> _flushMovementBuffer(ArmSide side) async {
    final lock = _bufferFlushLocks[side];
    if (lock == null) return;

    return await lock.synchronized(() async {
      final buffer = _movementBuffer[side];
      if (buffer == null || buffer.isEmpty) {
        _log('Movement buffer is empty for ${side.displayName}, skipping flush');
        return;
      }

      _log(
          'Flushing ${buffer.length} movement records for ${side.displayName}...');

      final dataToInsert = List<MovementData>.from(buffer);

      try {
        await _db.insertBatchMovementData(side.name, dataToInsert);
        buffer.clear();
        _log(
            'Flushed ${dataToInsert.length} movement records for ${side.displayName}', level: _LOG_INFO);

        // Notifier les graphiques qu'il y a de nouvelles données de mouvement
        ChartRefreshNotifier().notifyMovementDataUpdated();
      } catch (e) {
        _log('Error flushing movement buffer: $e', level: _LOG_ERROR);
      }
    });
  }

  /// Flush tous les buffers
  Future<void> _flushAllBuffers() async {
    _log('Periodic flush check starting...');
    bool hasFlushed = false;
    for (final side in ArmSide.values) {
      // Skip ArmSide.none as it has no buffers
      if (side == ArmSide.none) continue;

      final deviceInfoSize = _deviceInfoBuffer[side]!.length;
      final movementSize = _movementBuffer[side]!.length;

      _log('Buffer sizes for ${side.displayName}: device_info=$deviceInfoSize, movement=$movementSize');

      if (_deviceInfoBuffer[side]!.isNotEmpty) {
        await _flushDeviceInfoBuffer(side);
        hasFlushed = true;
      }
      if (_movementBuffer[side]!.isNotEmpty) {
        await _flushMovementBuffer(side);
        hasFlushed = true;
      }
    }
    if (hasFlushed) {
      _log('Periodic buffer flush completed', level: _LOG_INFO);
    } else {
      _log('No data to flush (all buffers empty)');
    }
  }

  // ============================================================================
  // ENREGISTREMENT ÉVÉNEMENTS DE CONNEXION
  // ============================================================================

  void _recordConnectionEvent(
    ArmSide side,
    ConnectionEventType type, {
    String? reason,
    int? durationSeconds,
    String? errorMessage,
    int? batteryAtConnection,
    int? rssiAtConnection,
  }) {
    final event = ConnectionEvent(
      armSide: side.technicalName,
      type: type,
      timestamp: DateTime.now(),
      reason: reason,
      durationSeconds: durationSeconds,
      errorMessage: errorMessage,
      batteryAtConnection: batteryAtConnection,
      rssiAtConnection: rssiAtConnection,
    );

    _db.insertConnectionEvent(event).catchError((e) {
      _log('Error recording connection event: $e', level: _LOG_ERROR);
    });
  }

  // ============================================================================
  // STREAMS SETUP
  // ============================================================================

  Future<void> _setupSessionStreams(
      ArmSide side, InfiniTimeSession session) async {
    try {
      // Annuler tous les anciens streams
      await _battSubs[side]?.cancel();
      await _stepsSubs[side]?.cancel();
      await _motionSubs[side]?.cancel();
      await _dfuSubs[side]?.cancel();
      await _blejsSubs[side]?.cancel();
      await _connSubs[side]?.cancel();
      await _musicEventSubs[side]?.cancel();
      await _callEventSubs[side]?.cancel();
      await _movementSubs[side]?.cancel();

      _log(
          'All previous streams cancelled for ${side.displayName} before creating new ones');

      // Connection stream
      _connSubs[side] = session.connectionStream.listen(
        (st) {
          if (st == InfiniTimeConnectionState.disconnected) {
            add(ArmDisconnected(side));
          } else if (st == InfiniTimeConnectionState.connected) {
            add(ArmConnected(side));
          }
        },
        onError: (error) {
          _log('Connection stream error for ${side.displayName}: $error');
          add(ArmDisconnected(side));
        },
        cancelOnError: false,
      );

      await Future.delayed(_DELAY_BETWEEN_STREAMS);

      // Battery
      _battSubs[side] = session.battery.listen(
        (v) => add(OnArmBattery(side, v)),
        onError: (e) =>
            _log('Battery stream error for ${side.displayName}: $e'),
        cancelOnError: false,
      );

      await Future.delayed(_DELAY_BETWEEN_STREAMS);

      // Steps
      _stepsSubs[side] = session.steps.listen(
        (v) => add(OnArmSteps(side, v)),
        onError: (e) => _log('Steps stream error for ${side.displayName}: $e'),
        cancelOnError: false,
      );

      await Future.delayed(_DELAY_BETWEEN_STREAMS);

      // Motion
      _motionSubs[side] = session.motion.listen(
        (v) => add(OnArmMotion(side, v)),
        onError: (e) => _log('Motion stream error for ${side.displayName}: $e'),
        cancelOnError: false,
      );

      await Future.delayed(_DELAY_BETWEEN_STREAMS);

      // DFU
      _dfuSubs[side] = session.dfuProgress.listen(
        (p) => add(OnArmSystemFirmwareDfu(side, p)),
        onError: (e) => _log('DFU stream error for ${side.displayName}: $e'),
        cancelOnError: false,
      );

      await Future.delayed(_DELAY_BETWEEN_STREAMS);

      // Music Events
      _musicEventSubs[side] = session.musicEvents.listen(
        (ev) => add(OnArmMusicEvent(side, ev)),
        onError: (e) => _log('Music stream error for ${side.displayName}: $e'),
        cancelOnError: false,
      );

      await Future.delayed(_DELAY_BETWEEN_STREAMS);

      // Call Events
      _callEventSubs[side] = session.callResponses.listen(
        (ev) => add(OnArmCallEvent(side, ev)),
        onError: (e) => _log('Call stream error for ${side.displayName}: $e'),
        cancelOnError: false,
      );

      await Future.delayed(_DELAY_BETWEEN_STREAMS);

      // Movement Stream - NOUVELLE GESTION (Enregistrement immédiat)
      _movementSubs[side] = session.movementStream.listen(
        (movement) {
          _log(' Movement data received for ${side.displayName}: mag=${movement.magnitudeActiveTime}ms, axis=${movement.axisActiveTime}ms');

          // Enregistrer immédiatement sans throttling
          _bufferMovement(
            side,
            movement,
          );

          final recordTime = _lastRecordTime[side];
          if (recordTime != null) {
            recordTime['movement'] = DateTime.now();
          }
        },
        onError: (e) =>
            _log('Movement stream error for ${side.displayName}: $e'),
        cancelOnError: false,
      );

      _log('Session streams setup for ${side.displayName}', level: _LOG_INFO);
    } catch (e) {
      _log(
        'Stream setup error for ${side.displayName}: $e',
        level: _LOG_ERROR,
      );
      rethrow;
    }
  }

  Future<void> _performInitialReads(
    ArmSide side,
    InfiniTimeSession session,
  ) async {
    try {
      // Read battery with retries
      for (int attempt = 0; attempt < 3; attempt++) {
        try {
          final battery = await session.readBattery();
          if (battery != null) {
            add(OnArmBattery(side, battery));
            break;
          }
        } catch (e) {
          if (attempt == 2) {
            _log('Failed to read battery for ${side.displayName}');
          }
          await Future.delayed(_DELAY_BETWEEN_OPERATIONS * (attempt + 1));
        }
      }

      add(DualDiscoverGattRequested(side));

      // Sync time with retries
      // Note: On envoie l'heure locale car la montre affiche l'heure telle quelle
      // sans appliquer de conversion de fuseau horaire
      for (int attempt = 0; attempt < 3; attempt++) {
        try {
          final localTime = DateTime.now();
          await session.syncTimeUtc(localTime);
          add(OnArmSynced(side, localTime));
          break;
        } catch (e) {
          if (attempt == 2) {
            _log('Failed to sync time for ${side.displayName}');
          }
          await Future.delayed(_DELAY_BETWEEN_OPERATIONS * (attempt + 1));
        }
      }

      // Send connection notification to watch
      _log('Attempting to send connection notification to ${side.displayName}');
      for (int attempt = 0; attempt < 3; attempt++) {
        try {
          final armName = side == ArmSide.left ? 'Gauche' : 'Droite';
          _log('Sending notification (attempt ${attempt + 1}/3): $armName');
          await session.sendNotification(
            title: 'Connexion',
            message: 'Bras $armName',
          );
          _log('✓ Connection notification sent successfully to ${side.displayName}', level: _LOG_INFO);
          break;
        } catch (e) {
          _log('Notification attempt ${attempt + 1} failed: $e', level: _LOG_WARNING);
          if (attempt == 2) {
            _log('Failed to send notification to ${side.displayName} after 3 attempts: $e', level: _LOG_ERROR);
          } else {
            await Future.delayed(_DELAY_BETWEEN_OPERATIONS * (attempt + 1));
          }
        }
      }

      // Note: DualReadDeviceInfoRequested removed from initial reads
      // to avoid "unstable connection" errors. Device info will be read
      // later once connection is stable.

      _log('Initial reads completed for ${side.displayName}', level: _LOG_INFO);
    } catch (e) {
      _log(
        'Initial reads error for ${side.displayName}: $e',
        level: _LOG_ERROR,
      );
    }
  }

  // ============================================================================
  // NOUVEAUX HANDLERS (MOUVEMENT, TEMPS)
  // ============================================================================

  Future<void> _onSubscribeToMovement(
    OnSubscribeToMovement e,
    Emitter<DualInfiniTimeState> emit,
  ) async {
    _log('Movement stream already active for ${e.side.displayName}');
  }

  Future<void> _onUnsubscribeFromMovement(
    OnUnsubscribeFromMovement e,
    Emitter<DualInfiniTimeState> emit,
  ) async {
    _log(
        'Movement stream managed by session lifecycle for ${e.side.displayName}');
  }

  Future<void> _onSyncTimeUtc(
    OnSyncTimeUtc e,
    Emitter<DualInfiniTimeState> emit,
  ) async {
    try {
      final session = _sessions[e.side];
      if (session == null) {
        _log('Session not available for ${e.side.displayName}');
        return;
      }

      // Utiliser l'heure fournie ou l'heure locale par défaut
      // Note: Malgré le nom "Utc", on envoie l'heure locale car la montre
      // affiche l'heure telle quelle sans conversion de fuseau
      final timeToSend = e.time ?? DateTime.now();
      await session.syncTimeUtc(timeToSend);

      add(OnArmSynced(e.side, timeToSend));
      _log('Time synced for ${e.side.displayName}: $timeToSend');
    } catch (e) {
      _log('Error syncing time: $e', level: _LOG_ERROR);
    }
  }

  Future<void> _onSendTime(
    OnSendTime e,
    Emitter<DualInfiniTimeState> emit,
  ) async {
    try {
      final session = _sessions[e.side];
      if (session == null) {
        _log('Session not available for ${e.side.displayName}');
        return;
      }

      final now = e.time ?? DateTime.now();
      await session.sendTime(dateTime:now);

      _log('Time sent to ${e.side.displayName}: $now');
      emit(_withArm(e.side, _armState(e.side).copyWith(lastSync: now)));
    } catch (e) {
      _log('Error sending time: $e', level: _LOG_ERROR);
    }
  }

  Future<void> _onMusicSetMeta(
    OnMusicSetMeta e,
    Emitter<DualInfiniTimeState> emit,
  ) async {
    try {
      final session = _sessions[e.side];
      if (session == null) {
        _log('Session not available for ${e.side.displayName}');
        return;
      }

      await session.musicSetMeta(
        artist: e.artist,
        track: e.track,
        album: e.album,
      );

      _log('Music metadata set for ${e.side.displayName}');
    } catch (e) {
      _log('Error setting music metadata: $e', level: _LOG_ERROR);
    }
  }

  Future<void> _onMusicSetPlaying(
    OnMusicSetPlaying e,
    Emitter<DualInfiniTimeState> emit,
  ) async {
    try {
      final session = _sessions[e.side];
      if (session == null) {
        _log('Session not available for ${e.side.displayName}');
        return;
      }

      await session.musicSetPlaying(e.playing);
      _log('Music playing state set for ${e.side.displayName}: ${e.playing}');
    } catch (e) {
      _log('Error setting music playing state: $e', level: _LOG_ERROR);
    }
  }

  Future<void> _onNavNarrativeSet(
    OnNavNarrativeSet e,
    Emitter<DualInfiniTimeState> emit,
  ) async {
    try {
      final session = _sessions[e.side];
      if (session == null) {
        _log('Session not available for ${e.side.displayName}');
        return;
      }

      await session.navNarrativeSet(e.narrative);
      _log('Navigation narrative set for ${e.side.displayName}');
    } catch (e) {
      _log('Error setting navigation narrative: $e', level: _LOG_ERROR);
    }
  }

  Future<void> _onNavManDistSet(
    OnNavManDistSet e,
    Emitter<DualInfiniTimeState> emit,
  ) async {
    try {
      final session = _sessions[e.side];
      if (session == null) {
        _log('Session not available for ${e.side.displayName}');
        return;
      }

      await session.navManDistSet(e.distance.toString());
      _log('Navigation distance set for ${e.side.displayName}: ${e.distance}m');
    } catch (e) {
      _log('Error setting navigation distance: $e', level: _LOG_ERROR);
    }
  }

  Future<void> _onNavProgressSet(
    OnNavProgressSet e,
    Emitter<DualInfiniTimeState> emit,
  ) async {
    try {
      final session = _sessions[e.side];
      if (session == null) {
        _log('Session not available for ${e.side.displayName}');
        return;
      }

      await session.navProgressSet(e.progress);
      _log('Navigation progress set for ${e.side.displayName}: ${e.progress}%');
    } catch (e) {
      _log('Error setting navigation progress: $e', level: _LOG_ERROR);
    }
  }

  Future<void> _onNavFlagsSet(
    OnNavFlagsSet e,
    Emitter<DualInfiniTimeState> emit,
  ) async {
    try {
      final session = _sessions[e.side];
      if (session == null) {
        _log('Session not available for ${e.side.displayName}');
        return;
      }

      await session.navFlagsSet(e.flags);
      _log('Navigation flags set for ${e.side.displayName}');
    } catch (e) {
      _log('Error setting navigation flags: $e', level: _LOG_ERROR);
    }
  }

  Future<void> _onWeatherWrite(
    OnWeatherWrite e,
    Emitter<DualInfiniTimeState> emit,
  ) async {
    try {
      final session = _sessions[e.side];
      if (session == null) {
        _log('Session not available for ${e.side.displayName}');
        return;
      }

      await session.weatherWrite(e.payload);
      _log('Weather data written for ${e.side.displayName}');
    } catch (e) {
      _log('Error writing weather data: $e', level: _LOG_ERROR);
    }
  }

  Future<void> _onBlefsWriteRaw(
    OnBlefsWriteRaw e,
    Emitter<DualInfiniTimeState> emit,
  ) async {
    try {
      final session = _sessions[e.side];
      if (session == null) {
        _log('Session not available for ${e.side.displayName}');
        return;
      }

      await session.blefsWriteRaw(e.payload);
      _log('BLEFS raw data written for ${e.side.displayName}');
    } catch (e) {
      _log('Error writing BLEFS raw data: $e', level: _LOG_ERROR);
    }
  }

  Future<void> _onStartSystemFirmwareDfu(
    OnStartSystemFirmwareDfu e,
    Emitter<DualInfiniTimeState> emit,
  ) async {
    try {
      final session = _sessions[e.side];
      if (session == null) {
        _log('Session not available for ${e.side.displayName}');
        return;
      }

      await session.startSystemFirmwareDfu(
        e.firmwarePath,
        reconnectOnComplete: e.reconnectOnComplete ?? true,
      );

      _log('System firmware DFU started for ${e.side.displayName}');
    } catch (e) {
      _log('Error starting firmware DFU: $e', level: _LOG_ERROR);
    }
  }

  Future<void> _onAbortSystemFirmwareDfu(
    OnAbortSystemFirmwareDfu e,
    Emitter<DualInfiniTimeState> emit,
  ) async {
    try {
      final session = _sessions[e.side];
      if (session == null) {
        _log('Session not available for ${e.side.displayName}');
        return;
      }

      await session.abortSystemFirmwareDfu();
      _log('System firmware DFU aborted for ${e.side.displayName}');
    } catch (e) {
      _log('Error aborting firmware DFU: $e', level: _LOG_ERROR);
    }
  }

  // ============================================================================
  // RECONNECTION & RETRY
  // ============================================================================

  void _scheduleReconnectWithBackoff(ArmSide side) {
    final id = _armState(side).deviceId;
    if (id == null) return;

    _reconnectTimers[side]?.cancel();

    _recordConnectionEvent(
      side,
      ConnectionEventType.reconnecting,
      reason: 'Backoff reconnection scheduled',
    );

    final attempt = _retries[side] ?? 0;
    final baseDelay = _MIN_RECONNECT_DELAY_MS * (1 << attempt.clamp(0, 4));
    final jitter = (baseDelay * 0.1 * (Random().nextDouble() - 0.5)).round();
    final delayMs = (baseDelay + jitter)
        .clamp(_MIN_RECONNECT_DELAY_MS, _MAX_RECONNECT_DELAY_MS);

    _retries[side] = (attempt + 1).clamp(0, _MAX_RETRY_ATTEMPTS);

    _log(
      'Reconnect scheduled for ${side.displayName} in ${delayMs}ms (attempt ${attempt + 1}/$_MAX_RETRY_ATTEMPTS)',
    );

    _reconnectTimers[side] = Timer(Duration(milliseconds: delayMs.toInt()), () {
      if (!_armState(side).connected && _armState(side).deviceId != null) {
        add(DualConnectArmRequested(side));
      }
    });
  }

  // ============================================================================
  // RSSI SCAN
  // ============================================================================

  void _startSharedRssiScanIfNeeded() {
    if (_rssiScanShared != null) return;

    _rssiScanShared = ble.scanForDevices(
      withServices: const [],
      scanMode: ScanMode.lowPower,
      requireLocationServicesEnabled: true,
    ).listen((d) {
      for (final side in ArmSide.values) {
        if (side == ArmSide.none) continue; // Skip ArmSide.none
        if (_armState(side).deviceId == d.id) {
          final prev = _lastRssiById[d.id];
          final now = DateTime.now();
          final lastSeen = _lastSeenAt[d.id];

          final shouldUpdate = prev == null ||
              lastSeen == null ||
              now.difference(lastSeen).inSeconds >= 2 ||
              (prev - d.rssi).abs() >= 5;

          if (shouldUpdate) {
            _lastRssiById[d.id] = d.rssi;
            _lastSeenAt[d.id] = now;
            add(OnArmRssi(side, d.rssi));
          }
        }
      }
    }, onError: (e) {
      _log('RSSI scan error: $e', level: _LOG_ERROR);
    });

    _log('RSSI scan started (throttled mode)', level: _LOG_INFO);
  }

  void _restartSharedRssiIfNeeded() {
    final anyConnected = ArmSide.values.any((s) => _armState(s).connected);
    if (anyConnected && _rssiScanShared == null) {
      Timer(const Duration(seconds: 2), () {
        if (ArmSide.values.any((s) => _armState(s).connected)) {
          _startSharedRssiScanIfNeeded();
        }
      });
    }
  }

  Future<void> _stopSharedRssiScan() async {
    await _rssiScanShared?.cancel();
    _rssiScanShared = null;
  }

  // ============================================================================
  // CLEANUP
  // ============================================================================

  Future<void> _fullDisconnectAndCleanup(ArmSide side) async {
    try {
      await _cancelReconnect(side);
      await _scanSub?.cancel();
      await _stopSharedRssiScan();
      await _disposeArmSession(side);
      await Future.delayed(const Duration(milliseconds: 300));
    } catch (e) {
      _log('Cleanup error for ${side.displayName}: $e', level: _LOG_ERROR);
    }
  }

  Future<void> _disposeArmSession(ArmSide side) async {
    try {
      // Cancel all stream subscriptions
      await _battSubs[side]?.cancel();
      await _stepsSubs[side]?.cancel();
      await _motionSubs[side]?.cancel();
      await _dfuSubs[side]?.cancel();
      await _blejsSubs[side]?.cancel();
      await _connSubs[side]?.cancel();
      await _musicEventSubs[side]?.cancel();
      await _callEventSubs[side]?.cancel();
      await _movementSubs[side]?.cancel();

      _battSubs[side] = null;
      _stepsSubs[side] = null;
      _motionSubs[side] = null;
      _dfuSubs[side] = null;
      _blejsSubs[side] = null;
      _connSubs[side] = null;
      _musicEventSubs[side] = null;
      _callEventSubs[side] = null;
      _movementSubs[side] = null;

      // Annuler les timers de debounce
      _rssiDebounceTimers[side]?.cancel();
      _rssiDebounceTimers[side] = null;
      _pendingRssi[side] = null;

      // Flush et nettoyer les buffers
      await _flushDeviceInfoBuffer(side);
      await _flushMovementBuffer(side);
      _deviceInfoBuffer[side]?.clear();
      _movementBuffer[side]?.clear();
      _log('Buffers cleared and flushed for ${side.displayName}');

      // Réinitialiser les dernières valeurs
      _lastRecordedValue[side]?.clear();
      _lastRecordTime[side]?.clear();
      // Réinitialiser le tracking des valeurs cumulatives pour les deltas
      _lastMagnitudeActiveTime[side] = null;
      _lastAxisActiveTime[side] = null;
      _log('Last recorded values cleared for ${side.displayName}');

      await _sessions[side]?.dispose();
      _sessions[side] = null;
    } catch (e) {
      _log('Dispose error for ${side.displayName}: $e', level: _LOG_ERROR);
    }
  }

  Future<void> _disconnectAndDispose(ArmSide side) async {
    await _cancelReconnect(side);
    await _disposeArmSession(side);
  }

  Future<void> _cancelReconnect(ArmSide side) async {
    _reconnectTimers[side]?.cancel();
    _reconnectTimers[side] = null;
  }

  // ============================================================================
  // PERMISSIONS
  // ============================================================================

  Future<bool> _ensurePerms() async {
    final Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.bluetoothAdvertise,
      Permission.locationWhenInUse,
    ].request();

    final allGranted = statuses.values.every((s) => s.isGranted);

    if (!allGranted) {
      final denied = statuses.entries
          .where((e) => !e.value.isGranted)
          .map((e) => e.key.toString())
          .join(', ');
      _log('Permissions denied: $denied', level: _LOG_ERROR);
    }

    return allGranted;
  }

  Future<bool> _ensureBluetoothReady() async {
    try {
      return await _ensurePerms();
    } catch (e) {
      _log('Bluetooth not ready: $e', level: _LOG_ERROR);
      return false;
    }
  }

  // ============================================================================
  // UTILITIES
  // ============================================================================

  ArmDeviceState _armState(ArmSide side) =>
      side == ArmSide.left ? state.left : state.right;

  DualInfiniTimeState _withArm(ArmSide side, ArmDeviceState newState) {
    return side == ArmSide.left
        ? state.copyWith(left: newState)
        : state.copyWith(right: newState);
  }

  // ============================================================================
  // PUBLIC API - NOUVELLES MÉTHODES DB
  // ============================================================================

  /// Récupère les device_info pour un bras
  Future<Future<List<DeviceInfoData>>> getDeviceInfo(
    ArmSide side,
    String infoType, {
    Duration period = const Duration(days: 7),
  }) async {
    final startDate = DateTime.now().subtract(period);
    return _db.getDeviceInfo(
      side.name,
      infoType,
      startDate: startDate,
    );
  }

  /// Récupère la dernière valeur device_info
  Future<Future<DeviceInfoData?>> getLatestDeviceInfo(
      ArmSide side, String infoType) async {
    return _db.getLatestDeviceInfo(side.name, infoType);
  }

  /// Récupère les statistiques device_info
  Future<Map<String, dynamic>> getDeviceInfoStats(
    ArmSide side,
    String infoType,
    DateTime date,
  ) async {
    return _db.calculateDeviceInfoStats(side.name, infoType, date);
  }

  /// Récupère les données de mouvement pour comparaison
  Future<List<Map<String, dynamic>>> getMovementData(
    ArmSide side, {
    Duration period = const Duration(days: 7),
  }) async {
    final startDate = DateTime.now().subtract(period);
    return _db.getMovementData(
      side.name,
      startDate: startDate,
    );
  }

  /// Compare les mouvements des deux bras
  Future<Map<String, dynamic>> compareArmsMovement({
    Duration period = const Duration(days: 7),
  }) async {
    final startDate = DateTime.now().subtract(period);
    return _db.compareArmsMovement(
      startDate: startDate,
      endDate: DateTime.now(),
    );
  }

  /// Récupère les statistiques de mouvement journalières
  Future<Map<String, dynamic>> getDailyMovementStats(
    ArmSide side,
    DateTime date,
  ) async {
    return _db.getDailyMovementStats(side.name, date);
  }

  /// Récupère l'historique de connexion
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

  Future<ConnectionEvent?> getLastConnection(ArmSide side) async {
    return _db.getLastConnection(side.technicalName);
  }

  Future<ConnectionEvent?> getLastDisconnection(ArmSide side) async {
    return _db.getLastDisconnection(side.technicalName);
  }

  Future<ConnectionStatistics> getConnectionStatistics(
    ArmSide side, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return _db.calculateConnectionStats(
      side.displayName.toLowerCase(),
      startDate: startDate,
      endDate: endDate,
    );
  }

  Future<List<ConnectionEvent>> getDailyConnectionEvents(
    ArmSide side,
    DateTime date,
  ) async {
    return _db.getDailyConnectionEvents(
      side.displayName.toLowerCase(),
      date,
    );
  }


// ============================================================================
// FIRMWARE & WATCHFACE PUBLIC API
// ============================================================================

  void updateSystemFirmware(ArmSide side, String firmwarePath) {
    add(DualSystemFirmwareDfuStartRequested(side, firmwarePath));
  }

  void abortSystemFirmwareUpdate(ArmSide side) {
    add(DualSystemFirmwareDfuAbortRequested(side));
  }

  void loadAvailableFirmwares() {
    add(DualLoadAvailableFirmwaresRequested());
  }

  void selectFirmware(ArmSide side, FirmwareInfo firmware) {
    add(DualSelectFirmwareRequested(side, firmware));
  }

  void updateSystemFirmwareSelected(ArmSide side) {
    final selectedFirmware = state.getSelectedFirmware(side);
    if (selectedFirmware != null && state.canInstallFirmware(side)) {
      add(DualSystemFirmwareDfuStartRequested(
          side, selectedFirmware.assetPath));
    } else {
      _log('Cannot install: firmware not selected or conditions not met');
    }
  }

  List<FirmwareInfo> get availableFirmwares => state.availableFirmwares;

  bool get isLoadingFirmwares => state.loadingFirmwares;

  FirmwareInfo? getSelectedFirmware(ArmSide side) =>
      state.getSelectedFirmware(side);

  bool hasFirmwareSelected(ArmSide side) => state.hasFirmwareSelected(side);

  bool canInstallFirmware(ArmSide side) => state.canInstallFirmware(side);

// ============================================================================
// DEBUG HANDLERS
// ============================================================================

  Future<void> _onForceFlushBuffers(
    DualForceFlushBuffersRequested e,
    Emitter<DualInfiniTimeState> emit,
  ) async {
    await forceFlushBuffers();
  }

// ============================================================================
// CLEANUP & CLOSE
// ============================================================================
  @override
  Future<void> close() async {
    _log('Closing DualInfiniTimeBloc', level: _LOG_INFO);
// Flush tous les buffers avant de fermer
    await _flushAllBuffers();

// Cancel all scan-related subscriptions
    await _scanSub?.cancel();
    _scanTimer?.cancel();
    _scanCacheCleanupTimer?.cancel();
    _bufferFlushTimer?.cancel();
    _trackingCleanupTimer?.cancel();
    _oldDataCleanupTimer?.cancel();
    await _rssiScanShared?.cancel();
    _rssiScanShared = null;

// Cancel all sensor stream subscriptions
    for (final side in ArmSide.values) {
      await _battSubs[side]?.cancel();
      await _stepsSubs[side]?.cancel();
      await _motionSubs[side]?.cancel();
      await _dfuSubs[side]?.cancel();
      await _blejsSubs[side]?.cancel();
      await _connSubs[side]?.cancel();
      await _musicEventSubs[side]?.cancel();
      await _callEventSubs[side]?.cancel();
      await _movementSubs[side]?.cancel();

      _rssiDebounceTimers[side]?.cancel();

      await _disposeArmSession(side);
      await _cancelReconnect(side);
    }

// Clear all subscription maps
    _battSubs.clear();
    _stepsSubs.clear();
    _motionSubs.clear();
    _dfuSubs.clear();
    _blejsSubs.clear();
    _connSubs.clear();
    _musicEventSubs.clear();
    _callEventSubs.clear();
    _movementSubs.clear();
    _reconnectTimers.updateAll((_, __) => null);
    _rssiDebounceTimers.updateAll((_, __) => null);

    for (final sub in _subscriptions.values) {
      await sub?.cancel();
    }
    _subscriptions.clear();

    _log('DualInfiniTimeBloc closed', level: _LOG_INFO);

    return super.close();
  }
}
