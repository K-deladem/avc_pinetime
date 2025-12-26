import 'package:equatable/equatable.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:infinitime_dfu_library/infinitime_dfu_library.dart';

import '../../models/arm_side.dart';

/// État d'un bras (montre)
class ArmState extends Equatable {
  final String? deviceId;
  final String? name;
  final bool connected;
  final bool connecting;
  final int? battery;
  final int? steps;
  final int? heartRate;
  final List<int>? motion;
  final int? rssi;
  final double? temperature;
  final DateTime? lastSync;
  final bool dfuRunning;
  final int dfuPercent;
  final String? dfuPhase;
  final Set<Uuid> chars;
  final Set<Uuid> noti;
  final Set<Uuid> indi;
  final int retryCount;
  final String log;
  final Map<String, String>? deviceInfo;
  final String? connectionError;

  const ArmState({
    this.deviceId,
    this.name,
    this.connected = false,
    this.connecting = false,
    this.battery,
    this.steps,
    this.heartRate,
    this.motion,
    this.rssi,
    this.temperature,
    this.lastSync,
    this.dfuRunning = false,
    this.dfuPercent = 0,
    this.dfuPhase,
    this.chars = const {},
    this.noti = const {},
    this.indi = const {},
    this.retryCount = 0,
    this.log = '',
    this.deviceInfo,
    this.connectionError,
  });

  bool get isBound => deviceId != null;
  bool get isReady => connected && !dfuRunning;

  bool get hasConnectionError => connectionError != null;

  ArmState copyWith({
    String? deviceId,
    bool clearId = false,
    String? name,
    bool? connected,
    bool? connecting,
    int? battery,
    int? steps,
    int? heartRate,
    List<int>? motion,
    bool clearMotion = false,
    int? rssi,
    double? temperature,
    DateTime? lastSync,
    bool? dfuRunning,
    int? dfuPercent,
    String? dfuPhase,
    Set<Uuid>? chars,
    Set<Uuid>? noti,
    Set<Uuid>? indi,
    int? retryCount,
    String? log,
    Map<String, String>? deviceInfo,
    String? connectionError,
    bool clearConnectionError = false,
  }) {
    return ArmState(
      deviceId: clearId ? null : (deviceId ?? this.deviceId),
      name: name ?? this.name,
      connected: connected ?? this.connected,
      connecting: connecting ?? this.connecting,
      battery: battery ?? this.battery,
      steps: steps ?? this.steps,
      heartRate: heartRate ?? this.heartRate,
      motion: clearMotion ? null : (motion ?? this.motion),
      rssi: rssi ?? this.rssi,
      temperature: temperature ?? this.temperature,
      lastSync: lastSync ?? this.lastSync,
      dfuRunning: dfuRunning ?? this.dfuRunning,
      dfuPercent: dfuPercent ?? this.dfuPercent,
      dfuPhase: dfuPhase ?? this.dfuPhase,
      chars: chars ?? this.chars,
      noti: noti ?? this.noti,
      indi: indi ?? this.indi,
      retryCount: retryCount ?? this.retryCount,
      log: log ?? this.log,
      deviceInfo: deviceInfo ?? this.deviceInfo,
      connectionError: clearConnectionError ? null : (connectionError ?? this.connectionError),
    );
  }

  @override
  List<Object?> get props => [
        deviceId,
        name,
        connected,
        connecting,
        battery,
        steps,
        heartRate,
        motion,
        rssi,
        temperature,
        lastSync,
        dfuRunning,
        dfuPercent,
        dfuPhase,
        chars,
        noti,
        indi,
        retryCount,
        log,
        deviceInfo,
        connectionError,
      ];
}

/// État global du DeviceBloc
class DeviceState extends Equatable {
  final ArmState left;
  final ArmState right;
  final bool scanning;
  final List<DiscoveredDevice> discoveredDevices;
  final List<FirmwareInfo> availableFirmwares;
  final Map<ArmSide, FirmwareInfo?> selectedFirmwares;
  final bool loadingFirmwares;

  const DeviceState({
    this.left = const ArmState(),
    this.right = const ArmState(),
    this.scanning = false,
    this.discoveredDevices = const [],
    this.availableFirmwares = const [],
    this.selectedFirmwares = const {},
    this.loadingFirmwares = false,
  });

  /// Obtient l'état d'un bras spécifique
  ArmState getArm(ArmSide side) {
    switch (side) {
      case ArmSide.left:
        return left;
      case ArmSide.right:
        return right;
      case ArmSide.none:
        return const ArmState();
    }
  }

  /// Vérifie si au moins un bras est connecté
  bool get anyConnected => left.connected || right.connected;

  /// Vérifie si les deux bras sont connectés
  bool get bothConnected => left.connected && right.connected;

  DeviceState copyWith({
    ArmState? left,
    ArmState? right,
    bool? scanning,
    List<DiscoveredDevice>? discoveredDevices,
    List<FirmwareInfo>? availableFirmwares,
    Map<ArmSide, FirmwareInfo?>? selectedFirmwares,
    bool? loadingFirmwares,
  }) {
    return DeviceState(
      left: left ?? this.left,
      right: right ?? this.right,
      scanning: scanning ?? this.scanning,
      discoveredDevices: discoveredDevices ?? this.discoveredDevices,
      availableFirmwares: availableFirmwares ?? this.availableFirmwares,
      selectedFirmwares: selectedFirmwares ?? this.selectedFirmwares,
      loadingFirmwares: loadingFirmwares ?? this.loadingFirmwares,
    );
  }

  /// Copie avec mise à jour d'un bras spécifique
  DeviceState withArm(ArmSide side, ArmState armState) {
    switch (side) {
      case ArmSide.left:
        return copyWith(left: armState);
      case ArmSide.right:
        return copyWith(right: armState);
      case ArmSide.none:
        return this;
    }
  }

  @override
  List<Object?> get props => [
        left,
        right,
        scanning,
        discoveredDevices,
        availableFirmwares,
        selectedFirmwares,
        loadingFirmwares,
      ];
}
