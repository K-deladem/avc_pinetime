import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:infinitime_dfu_library/infinitime_dfu_library.dart';

import '../../models/arm_side.dart';

/// Événement de base
abstract class DeviceEvent extends Equatable {
  const DeviceEvent();

  @override
  List<Object?> get props => [];
}

// ============================================================================
// BINDING EVENTS
// ============================================================================

class LoadBindings extends DeviceEvent {
  const LoadBindings();
}

class BindDevice extends DeviceEvent {
  final ArmSide side;
  final String deviceId;
  final String? name;

  const BindDevice(this.side, this.deviceId, {this.name});

  @override
  List<Object?> get props => [side, deviceId, name];
}

class UnbindDevice extends DeviceEvent {
  final ArmSide side;

  const UnbindDevice(this.side);

  @override
  List<Object?> get props => [side];
}

class BindAndConnect extends DeviceEvent {
  final ArmSide side;
  final String deviceId;
  final String? name;

  const BindAndConnect(this.side, this.deviceId, {this.name});

  @override
  List<Object?> get props => [side, deviceId, name];
}

// ============================================================================
// SCAN EVENTS
// ============================================================================

class StartScan extends DeviceEvent {
  const StartScan();
}

class StopScan extends DeviceEvent {
  const StopScan();
}

class DeviceDiscovered extends DeviceEvent {
  final DiscoveredDevice device;

  const DeviceDiscovered(this.device);

  @override
  List<Object?> get props => [device];
}

class ScanTimeout extends DeviceEvent {
  const ScanTimeout();
}

// ============================================================================
// CONNECTION EVENTS
// ============================================================================

class ConnectDevice extends DeviceEvent {
  final ArmSide side;

  const ConnectDevice(this.side);

  @override
  List<Object?> get props => [side];
}

class DisconnectDevice extends DeviceEvent {
  final ArmSide side;

  const DisconnectDevice(this.side);

  @override
  List<Object?> get props => [side];
}

class DeviceConnected extends DeviceEvent {
  final ArmSide side;

  const DeviceConnected(this.side);

  @override
  List<Object?> get props => [side];
}

class DeviceDisconnected extends DeviceEvent {
  final ArmSide side;
  final bool unexpected;

  const DeviceDisconnected(this.side, {this.unexpected = false});

  @override
  List<Object?> get props => [side, unexpected];
}

/// Réessayer la connexion manuellement (réinitialise le compteur de tentatives)
class RetryConnection extends DeviceEvent {
  final ArmSide side;

  const RetryConnection(this.side);

  @override
  List<Object?> get props => [side];
}

/// Annuler les tentatives de reconnexion automatique
class CancelReconnection extends DeviceEvent {
  final ArmSide side;

  const CancelReconnection(this.side);

  @override
  List<Object?> get props => [side];
}

// ============================================================================
// SYNC EVENTS
// ============================================================================

class SyncTime extends DeviceEvent {
  final ArmSide side;
  /// Offset du fuseau horaire en heures (ex: 2.0 pour UTC+2, -5.0 pour UTC-5)
  /// Si null, utilise le fuseau horaire du téléphone
  final double? timezoneOffsetHours;

  const SyncTime(this.side, {this.timezoneOffsetHours});

  @override
  List<Object?> get props => [side, timezoneOffsetHours];
}

class ReadBattery extends DeviceEvent {
  final ArmSide side;

  const ReadBattery(this.side);

  @override
  List<Object?> get props => [side];
}

class ReadDeviceInfo extends DeviceEvent {
  final ArmSide side;

  const ReadDeviceInfo(this.side);

  @override
  List<Object?> get props => [side];
}

class DiscoverGatt extends DeviceEvent {
  final ArmSide side;

  const DiscoverGatt(this.side);

  @override
  List<Object?> get props => [side];
}

// ============================================================================
// SENSOR DATA EVENTS
// ============================================================================

class BatteryUpdated extends DeviceEvent {
  final ArmSide side;
  final int value;

  const BatteryUpdated(this.side, this.value);

  @override
  List<Object?> get props => [side, value];
}

class StepsUpdated extends DeviceEvent {
  final ArmSide side;
  final int value;

  const StepsUpdated(this.side, this.value);

  @override
  List<Object?> get props => [side, value];
}

class MotionUpdated extends DeviceEvent {
  final ArmSide side;
  final List<int> xyz;

  const MotionUpdated(this.side, this.xyz);

  @override
  List<Object?> get props => [side, xyz];
}

class RssiUpdated extends DeviceEvent {
  final ArmSide side;
  final int value;

  const RssiUpdated(this.side, this.value);

  @override
  List<Object?> get props => [side, value];
}

class MovementDataReceived extends DeviceEvent {
  final ArmSide side;
  final MovementData data;

  const MovementDataReceived(this.side, this.data);

  @override
  List<Object?> get props => [side, data];
}

// ============================================================================
// FIRMWARE EVENTS
// ============================================================================

class LoadFirmwares extends DeviceEvent {
  const LoadFirmwares();
}

class SelectFirmware extends DeviceEvent {
  final ArmSide side;
  final FirmwareInfo firmware;

  const SelectFirmware(this.side, this.firmware);

  @override
  List<Object?> get props => [side, firmware];
}

class StartDfu extends DeviceEvent {
  final ArmSide side;
  final String firmwarePath;

  const StartDfu(this.side, this.firmwarePath);

  @override
  List<Object?> get props => [side, firmwarePath];
}

class AbortDfu extends DeviceEvent {
  final ArmSide side;

  const AbortDfu(this.side);

  @override
  List<Object?> get props => [side];
}

class DfuProgressUpdate extends DeviceEvent {
  final ArmSide side;
  final int percent;
  final String phase;

  const DfuProgressUpdate(this.side, this.percent, this.phase);

  @override
  List<Object?> get props => [side, percent, phase];
}

// ============================================================================
// MUSIC EVENTS
// ============================================================================

class SendMusicMeta extends DeviceEvent {
  final ArmSide side;
  final String artist;
  final String track;
  final String album;

  const SendMusicMeta(this.side, {
    required this.artist,
    required this.track,
    required this.album,
  });

  @override
  List<Object?> get props => [side, artist, track, album];
}

class SendMusicPlayPause extends DeviceEvent {
  final ArmSide side;
  final bool play;

  const SendMusicPlayPause(this.side, this.play);

  @override
  List<Object?> get props => [side, play];
}

class MusicEventReceived extends DeviceEvent {
  final ArmSide side;
  final int event;

  const MusicEventReceived(this.side, this.event);

  @override
  List<Object?> get props => [side, event];
}

// ============================================================================
// NAVIGATION & WEATHER EVENTS
// ============================================================================

class SendNavigation extends DeviceEvent {
  final ArmSide side;
  final String narrative;
  final String distance;
  final int progress;
  final int flags;

  const SendNavigation(this.side, {
    required this.narrative,
    required this.distance,
    required this.progress,
    required this.flags,
  });

  @override
  List<Object?> get props => [side, narrative, distance, progress, flags];
}

class SendWeather extends DeviceEvent {
  final ArmSide side;
  final Uint8List payload;

  const SendWeather(this.side, this.payload);

  @override
  List<Object?> get props => [side, payload];
}

// ============================================================================
// UTILITY EVENTS
// ============================================================================

class FlushBuffers extends DeviceEvent {
  const FlushBuffers();
}

class GattDiscovered extends DeviceEvent {
  final ArmSide side;
  final Set<Uuid> chars;
  final Set<Uuid> noti;
  final Set<Uuid> indi;

  const GattDiscovered(this.side, this.chars, this.noti, this.indi);

  @override
  List<Object?> get props => [side, chars, noti, indi];
}

class TimeSynced extends DeviceEvent {
  final ArmSide side;
  final DateTime at;

  const TimeSynced(this.side, this.at);

  @override
  List<Object?> get props => [side, at];
}
