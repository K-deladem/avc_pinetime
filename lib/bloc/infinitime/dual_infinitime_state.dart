// ------- STATE GLOBAL -------
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc_app_template/models/arm_side.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:infinitime_dfu_library/infinitime_dfu_library.dart';

// ------- STATE PAR BRAS -------
class ArmDeviceState extends Equatable {
  final String? deviceId;
  final String? name;
  final bool connected;

  final int? battery;

  final int? steps;
  final List<int>? motion;

  final int? rssi; // dBm en temps réel

  final Set<Uuid> chars;
  final Set<Uuid> notifiable;
  final Set<Uuid> indicatable;

  final bool dfuRunning;
  final int dfuPercent;
  final String dfuPhase;

  final String log;

  final Map<String, String?>? deviceInfo;

  // ➜ dernière synchronisation (date locale)
  final DateTime? lastSync;

  const ArmDeviceState({
    this.deviceId,
    this.name,
    this.connected = false,
    this.battery,
    this.steps,
    this.motion,
    this.rssi,
    this.chars = const {},
    this.notifiable = const {},
    this.indicatable = const {},
    this.dfuRunning = false,
    this.dfuPercent = 0,
    this.dfuPhase = "",
    this.log = "",
    this.lastSync,
    this.deviceInfo,
  });

  ArmDeviceState copyWith({
    String? deviceId,
    String? name,
    bool? connected,
    int? battery,
    int? hr,
    int? steps,
    List<int>? motion,
    int? rssi,
    Set<Uuid>? chars,
    Set<Uuid>? notifiable,
    Set<Uuid>? indicatable,
    bool? dfuRunning,
    int? dfuPercent,
    String? dfuPhase,
    String? log,
    DateTime? lastSync,
    bool clearMotion = false,
    bool clearId = false,
    bool? watchfaceInstalling,
    int? watchfaceProgress,
    String? watchfacePhase,
    Map<String, String>? deviceInfo,
    bool clearDeviceInfo = false,
    double? temperature,
  }) {
    return ArmDeviceState(
      deviceId: clearId ? null : (deviceId ?? this.deviceId),
      name: name ?? this.name,
      connected: connected ?? this.connected,
      battery: battery ?? this.battery,
      steps: steps ?? this.steps,
      motion: clearMotion ? null : (motion ?? this.motion),
      rssi: rssi ?? this.rssi,
      chars: chars ?? this.chars,
      notifiable: notifiable ?? this.notifiable,
      indicatable: indicatable ?? this.indicatable,
      dfuRunning: dfuRunning ?? this.dfuRunning,
      dfuPercent: dfuPercent ?? this.dfuPercent,
      dfuPhase: dfuPhase ?? this.dfuPhase,
      log: log ?? this.log,
      lastSync: lastSync ?? this.lastSync,
      deviceInfo: clearDeviceInfo ? null : deviceInfo ?? this.deviceInfo,
    );
  }

  @override
  List<Object?> get props => [
        deviceId,
        name,
        connected,
        battery,
        steps,
        motion,
        rssi,
        chars,
        notifiable,
        indicatable,
        dfuRunning,
        dfuPercent,
        dfuPhase,
        log,
        lastSync,
      ];
}

class DualInfiniTimeState extends Equatable {
  final bool scanning;
  final Map<String, DiscoveredDevice> lastScan; // id -> device
  final ArmDeviceState left;
  final ArmDeviceState right;

  //champs pour les firmwares
  final List<FirmwareInfo> availableFirmwares;
  final bool loadingFirmwares;
  final Map<ArmSide, FirmwareInfo?> selectedFirmwares;

  const DualInfiniTimeState({
    this.scanning = false,
    this.lastScan = const {},
    this.left = const ArmDeviceState(),
    this.right = const ArmDeviceState(),
    this.availableFirmwares = const [],
    this.loadingFirmwares = false,
    this.selectedFirmwares = const {
      ArmSide.left: null,
      ArmSide.right: null,
    },
  });

  DualInfiniTimeState copyWith({
    bool? scanning,
    Map<String, DiscoveredDevice>? lastScan,
    ArmDeviceState? left,
    ArmDeviceState? right,
    List<FirmwareInfo>? availableFirmwares,
    bool? loadingFirmwares,
    Map<ArmSide, FirmwareInfo?>? selectedFirmwares,
  }) {
    return DualInfiniTimeState(
      scanning: scanning ?? this.scanning,
      lastScan: lastScan ?? this.lastScan,
      left: left ?? this.left,
      right: right ?? this.right,
      availableFirmwares: availableFirmwares ?? this.availableFirmwares,
      loadingFirmwares: loadingFirmwares ?? this.loadingFirmwares,
      selectedFirmwares: selectedFirmwares ?? this.selectedFirmwares,
    );
  }

  @override
  List<Object?> get props => [
        left,
        right,
        scanning,
        lastScan,
        availableFirmwares,
        loadingFirmwares,
        selectedFirmwares,
      ];
}
