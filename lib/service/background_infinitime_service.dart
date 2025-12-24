// lib/services/background_infinitime_service.dart

import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_bloc_app_template/utils/app_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

@pragma('vm:entry-point')
class BackgroundInfiniTimeService {
  static const String _channelId = 'infinitime_background_channel';
  static const int _notificationId = 789;

  static bool _isInitialized = false;
  static bool _isRunning = false;

  @pragma('vm:entry-point')
  static Future<void> initialize() async {
    if (_isInitialized) return;

    final service = FlutterBackgroundService();

    await service.configure(
      iosConfiguration: IosConfiguration(
        autoStart: true, // Activer pour iOS aussi
        onForeground: _onForeground,
        onBackground: _onBackground,
      ),
      androidConfiguration: AndroidConfiguration(
        onStart: _onStart,
        autoStart: true, // Démarrage automatique pour persister
        isForegroundMode: true,
        notificationChannelId: _channelId,
        initialNotificationTitle: 'InfiniTime Service',
        initialNotificationContent: 'Surveillance des montres PineTime',
        foregroundServiceNotificationId: _notificationId,
        autoStartOnBoot: true, // Démarrage auto au boot
      ),
    );
    _isInitialized = true;
    AppLogger.i('Service InfiniTime coordinateur initialisé');
  }

  @pragma('vm:entry-point')
  static Future<void> start() async {
    if (!_isInitialized) await initialize();
    if (_isRunning) return;

    final service = FlutterBackgroundService();
    await service.startService();
    _isRunning = true;
    AppLogger.i('Service InfiniTime coordinateur démarré');
  }

  @pragma('vm:entry-point')
  static Future<void> stop() async {
    final service = FlutterBackgroundService();
    service.invoke("stopService");
    _isRunning = false;
    AppLogger.i('Service InfiniTime coordinateur arrêté');
  }

  static void updateStatus(String side, String status) {
    final service = FlutterBackgroundService();
    service.invoke('status_update', {'side': side, 'status': status});
  }

  static void requestReconnection(String side) {
    final service = FlutterBackgroundService();
    service.invoke('reconnect_request', {'side': side});
  }

  @pragma('vm:entry-point')
  static void _onStart(ServiceInstance service) async {
    DartPluginRegistrant.ensureInitialized();
    AppLogger.i('=== Service coordinateur: onStart appelé ===');

    // Configurer la notification initiale pour Android
    if (service is AndroidServiceInstance) {
      try {
        await service.setAsForegroundService();
        await service.setForegroundNotificationInfo(
          title: "InfiniTime Service",
          content: "Initialisation...",
        );
        AppLogger.i('Notification foreground configurée');
      } catch (e) {
        AppLogger.e('Erreur configuration notification', error: e);
      }
    }

    service.on('stopService').listen((event) {
      AppLogger.i('Service coordinateur: arrêt demandé');
      service.stopSelf();
    });

    try {
      final coordinator = ConnectionCoordinator._();
      await coordinator._initialize(service);
      AppLogger.i('=== Coordinateur de connexions initialisé ===');
    } catch (e) {
      AppLogger.e('Erreur lors de l\'initialisation du coordinateur', error: e);
    }
  }

  @pragma('vm:entry-point')
  static bool _onBackground(ServiceInstance service) {
    WidgetsFlutterBinding.ensureInitialized();
    AppLogger.i("iOS: Service en arrière-plan");

    // Sur iOS, on démarre aussi le coordinateur
    try {
      final coordinator = ConnectionCoordinator._();
      coordinator._initialize(service);
      AppLogger.i('iOS: Coordinateur initialisé en arrière-plan');
    } catch (e) {
      AppLogger.e('iOS: Erreur initialisation coordinateur en arrière-plan', error: e);
    }

    return true;
  }

  @pragma('vm:entry-point')
  static void _onForeground(ServiceInstance service) {
    AppLogger.i("iOS: Service en avant-plan");

    // Sur iOS, on peut aussi initialiser le coordinateur en foreground
    try {
      final coordinator = ConnectionCoordinator._();
      coordinator._initialize(service);
      AppLogger.i('iOS: Coordinateur initialisé en avant-plan');
    } catch (e) {
      AppLogger.e('iOS: Erreur initialisation coordinateur en avant-plan', error: e);
    }
  }
}

/// Coordinateur pour la gestion des connexions et des mises à jour du service.
@pragma('vm:entry-point')
class ConnectionCoordinator {
  final Map<String, String?> _deviceIds = {};
  final Map<String, String> _lastKnownStatus = {};
  ServiceInstance? _service;
  bool _isServiceRunning = false;

  // Timers gérés pour un nettoyage propre
  final List<Timer> _activeTimers = [];

  final _Debouncer _notifyDebouncer = _Debouncer(const Duration(milliseconds: 250));

  @pragma('vm:entry-point')
  ConnectionCoordinator._();

  /// Arrête tous les timers actifs
  void _stopAllTimers() {
    _isServiceRunning = false;
    for (final timer in _activeTimers) {
      timer.cancel();
    }
    _activeTimers.clear();
    _notifyDebouncer.dispose();
  }

  @pragma('vm:entry-point')
  Future<void> _initialize(ServiceInstance service) async {
    _service = service;
    _isServiceRunning = true;
    AppLogger.i('=== Initialisation coordinateur avec collecte de données ===');

    try {
      final prefs = await SharedPreferences.getInstance();
      _deviceIds['left'] = prefs.getString('arm_left_device_id');
      _deviceIds['right'] = prefs.getString('arm_right_device_id');

      AppLogger.d('Devices surveillés:');
      AppLogger.d('  Gauche: ${_deviceIds['left'] ?? "aucun"}');
      AppLogger.d('  Droite: ${_deviceIds['right'] ?? "aucun"}');

      for (final side in ['left', 'right']) {
        if (_deviceIds[side] != null) {
          _lastKnownStatus[side] = 'surveillé';
        }
      }

      service.on('status_update').listen((data) {
        if (data != null) {
          final side = data['side'] as String?;
          final status = data['status'] as String?;
          if (side != null && status != null) {
            _lastKnownStatus[side] = status;
            AppLogger.d('Statut reçu du BLoC: $side = $status');

            // Optimisation : mise à jour immédiate
            _notifyDebouncer.run(_updateNotification);
          }
        }
      });

      service.on('stopService').listen((event) {
        _stopAllTimers();
        AppLogger.i('Service arrêté - nettoyage des timers');
      });

      // Timer pour surveillance des connexions (toutes les 2 minutes)
      _activeTimers.add(Timer.periodic(const Duration(minutes: 2), (timer) async {
        if (!_isServiceRunning) {
          timer.cancel();
          return;
        }
        try {
          await _checkAndCoordinate();
        } catch (e) {
          AppLogger.e('Erreur lors de la vérification des connexions', error: e);
        }
      }));

      // Timer pour collecte de données (toutes les 5 minutes - optimisé batterie)
      _activeTimers.add(Timer.periodic(const Duration(minutes: 5), (timer) async {
        if (!_isServiceRunning) {
          timer.cancel();
          return;
        }
        try {
          await _collectDataFromDevices();
        } catch (e) {
          AppLogger.e('Erreur lors de la collecte de données', error: e);
        }
      }));

      // Timer pour maintenir le service en vie et gérer les reconnexions
      _activeTimers.add(Timer.periodic(const Duration(minutes: 1), (timer) async {
        if (!_isServiceRunning) {
          timer.cancel();
          return;
        }
        try {
          await _ensureConnectionsAlive();
        } catch (e) {
          AppLogger.e('Erreur lors du maintien des connexions', error: e);
        }
      }));

      // Collecte initiale immédiate
      await _collectDataFromDevices();

      // Notification initiale immédiate
      await _updateNotification();

      AppLogger.i('=== Coordinateur configuré avec collecte active et reconnexion auto ===');

    } catch (e) {
      AppLogger.e('Erreur lors de l\'initialisation du coordinateur', error: e);
    }
  }

  @pragma('vm:entry-point')
  Future<void> _checkAndCoordinate() async {
    AppLogger.d('Vérification des connexions...');

    for (final side in ['left', 'right']) {
      final deviceId = _deviceIds[side];
      if (deviceId != null) {
        final status = _lastKnownStatus[side] ?? 'inconnu';

        AppLogger.d('  $side: $status');

        if (status == 'déconnecté' || status == 'inconnu') {
          AppLogger.i('Demande de reconnexion pour $side');
          _service?.invoke('reconnect_request', {'side': side});
        }
      }
    }
  }

  /// Vérifie et maintient les connexions actives
  @pragma('vm:entry-point')
  Future<void> _ensureConnectionsAlive() async {
    AppLogger.d('Maintien des connexions...');

    for (final side in ['left', 'right']) {
      final deviceId = _deviceIds[side];
      if (deviceId != null) {
        final status = _lastKnownStatus[side] ?? 'inconnu';

        // Reconnexion si déconnecté ou inconnu
        if (status == 'déconnecté' || status == 'inconnu') {
          AppLogger.i('Tentative de reconnexion automatique pour $side');
          _service?.invoke('reconnect_request', {'side': side});
        }
      }
    }

    // Mise à jour de la notification
    await _updateNotification();
  }

  /// Collecte les données des montres configurées
  @pragma('vm:entry-point')
  Future<void> _collectDataFromDevices() async {
    AppLogger.i('=== Début collecte de données ===');

    try {
      // Collecter pour le bras gauche
      if (_deviceIds['left'] != null) {
        await _collectDataForSide('left', _deviceIds['left']!);
      }

      // Collecter pour le bras droit
      if (_deviceIds['right'] != null) {
        await _collectDataForSide('right', _deviceIds['right']!);
      }

      AppLogger.i('=== Collecte de données terminée ===');
    } catch (e) {
      AppLogger.e('Erreur lors de la collecte de données', error: e);
    }
  }

  /// Collecte les données pour un côté spécifique (optimisé batterie)
  @pragma('vm:entry-point')
  Future<void> _collectDataForSide(String side, String deviceId) async {
    AppLogger.d('Collecte données pour $side ($deviceId)...');

    try {
      // Note: La collecte se fait via le DualInfiniTimeBloc qui maintient
      // les connexions. Ici on déclenche juste une lecture si connecté.

      // Vérifier si déjà connecté via le statut
      final status = _lastKnownStatus[side] ?? 'inconnu';

      if (status == 'connecté') {
        // Envoyer une demande de collecte au BLoC via le service
        _service?.invoke('collect_data', {'side': side});
        AppLogger.d('Demande de collecte envoyée pour $side');
      } else {
        AppLogger.d('$side non connecté, collecte ignorée');
      }

    } catch (e) {
      AppLogger.e('Erreur collecte $side', error: e);
    }
  }

  @pragma('vm:entry-point')
  Future<void> _updateNotification() async {
    if (_service is AndroidServiceInstance) {
      try {
        final status = _getStatusText();
        await (_service as AndroidServiceInstance).setForegroundNotificationInfo(
          title: "InfiniTime Service",
          content: status,
        );
      } catch (e) {
        AppLogger.e('Erreur lors de la mise à jour de la notification', error: e);
      }
    }
  }

  @pragma('vm:entry-point')
  String _getStatusText() {
    final leftConfigured = _deviceIds['left'] != null;
    final rightConfigured = _deviceIds['right'] != null;

    if (!leftConfigured && !rightConfigured) {
      return 'Aucune montre configurée';
    }

    final parts = <String>[];

    if (leftConfigured) {
      final status = _lastKnownStatus['left'] ?? 'inconnu';
      parts.add('Gauche:${_getStatusIcon(status)}');
    }

    if (rightConfigured) {
      final status = _lastKnownStatus['right'] ?? 'inconnu';
      parts.add('Droite:${_getStatusIcon(status)}');
    }

    return parts.join(' ');
  }

  /// Converts a status string to its corresponding icon
  @pragma('vm:entry-point')
  String _getStatusIcon(String status) {
    switch (status) {
      case 'connecté':
        return 'connecté';
      case 'connexion':
        return 'connexion';
      case 'déconnecté':
        return 'déconnecté';
      case 'inconnu':
        return 'inconnu';
      default:
        return '○ ○ ○';
    }
  }
}

class _Debouncer {
  _Debouncer(this.delay);
  final Duration delay;
  Timer? _t;
  void run(FutureOr<void> Function() action) {
    _t?.cancel();
    _t = Timer(delay, () => action());
  }
  void dispose() => _t?.cancel();
}
