// dual_infinitime_event.dart - VERSION CORRIGÉE SANS DOUBLONS
import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc_app_template/models/arm_side.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:infinitime_dfu_library/infinitime_dfu_library.dart';

// ============================================================================
// BASE EVENT
// ============================================================================

abstract class DualInfiniTimeEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

// ============================================================================
// BINDING EVENTS
// ============================================================================

class DualLoadBindingsRequested extends DualInfiniTimeEvent {}

class DualBindAndConnectArmRequested extends DualInfiniTimeEvent {
  final ArmSide side;
  final String deviceId;
  final String? name;

  DualBindAndConnectArmRequested(this.side, this.deviceId, {this.name});

  @override
  List<Object?> get props => [side, deviceId, name];
}

class DualBindArmRequested extends DualInfiniTimeEvent {
  final ArmSide side;
  final String deviceId;
  final String? name;

  DualBindArmRequested(this.side, this.deviceId, {this.name});

  @override
  List<Object?> get props => [side, deviceId, name];
}

class DualUnbindArmRequested extends DualInfiniTimeEvent {
  final ArmSide side;

  DualUnbindArmRequested(this.side);

  @override
  List<Object?> get props => [side];
}

// ============================================================================
// SCAN EVENTS
// ============================================================================

class DualScanRequested extends DualInfiniTimeEvent {}

class DualScanStopRequested extends DualInfiniTimeEvent {}

class OnFoundDevice extends DualInfiniTimeEvent {
  final DiscoveredDevice device;

  OnFoundDevice(this.device);

  @override
  List<Object?> get props => [device];
}

class OnScanAddDevice extends DualInfiniTimeEvent {
  final DiscoveredDevice device;

  OnScanAddDevice(this.device);

  @override
  List<Object?> get props => [device];
}

class ScanTimedOut extends DualInfiniTimeEvent {}

// ============================================================================
// CONNECTION EVENTS
// ============================================================================

class DualConnectArmRequested extends DualInfiniTimeEvent {
  final ArmSide side;

  DualConnectArmRequested(this.side);

  @override
  List<Object?> get props => [side];
}

class DualDisconnectArmRequested extends DualInfiniTimeEvent {
  final ArmSide side;

  DualDisconnectArmRequested(this.side);

  @override
  List<Object?> get props => [side];
}

class ArmConnected extends DualInfiniTimeEvent {
  final ArmSide side;

  ArmConnected(this.side);

  @override
  List<Object?> get props => [side];
}

class ArmDisconnected extends DualInfiniTimeEvent {
  final ArmSide side;

  ArmDisconnected(this.side);

  @override
  List<Object?> get props => [side];
}

// ============================================================================
// GATT DISCOVERY
// ============================================================================

class DualDiscoverGattRequested extends DualInfiniTimeEvent {
  final ArmSide side;

  DualDiscoverGattRequested(this.side);

  @override
  List<Object?> get props => [side];
}

class OnArmGattDump extends DualInfiniTimeEvent {
  final ArmSide side;
  final Set<Uuid> chars;
  final Set<Uuid> noti;
  final Set<Uuid> indi;

  OnArmGattDump(this.side, this.chars, this.noti, this.indi);

  @override
  List<Object?> get props => [side, chars, noti, indi];
}

// ============================================================================
// DEVICE INFO & SYNC
// ============================================================================

class DualReadDeviceInfoRequested extends DualInfiniTimeEvent {
  final ArmSide side;

  DualReadDeviceInfoRequested(this.side);

  @override
  List<Object?> get props => [side];
}

class DualSyncTimeRequested extends DualInfiniTimeEvent {
  final ArmSide side;

  DualSyncTimeRequested(this.side);

  @override
  List<Object?> get props => [side];
}

class DualReadBatteryRequested extends DualInfiniTimeEvent {
  final ArmSide side;

  DualReadBatteryRequested(this.side);

  @override
  List<Object?> get props => [side];
}

class OnArmSynced extends DualInfiniTimeEvent {
  final ArmSide side;
  final DateTime at;

  OnArmSynced(this.side, this.at);

  @override
  List<Object?> get props => [side, at];
}

// ============================================================================
// SENSOR DATA EVENTS
// ============================================================================

class OnArmBattery extends DualInfiniTimeEvent {
  final ArmSide side;
  final int v;

  OnArmBattery(this.side, this.v);

  @override
  List<Object?> get props => [side, v];
}

class OnArmHr extends DualInfiniTimeEvent {
  final ArmSide side;
  final int v;

  OnArmHr(this.side, this.v);

  @override
  List<Object?> get props => [side, v];
}

class OnArmSteps extends DualInfiniTimeEvent {
  final ArmSide side;
  final int v;

  OnArmSteps(this.side, this.v);

  @override
  List<Object?> get props => [side, v];
}

class OnArmMotion extends DualInfiniTimeEvent {
  final ArmSide side;
  final List<int> xyz;

  OnArmMotion(this.side, this.xyz);

  @override
  List<Object?> get props => [side, xyz];
}

class OnArmRssi extends DualInfiniTimeEvent {
  final ArmSide side;
  final int rssi;

  OnArmRssi(this.side, this.rssi);

  @override
  List<Object?> get props => [side, rssi];
}

// ============================================================================
// TEMPÉRATURE (NOUVEAU)
// ============================================================================

class OnSubscribeToTemperature extends DualInfiniTimeEvent {
  final ArmSide side;

   OnSubscribeToTemperature(this.side);

  @override
  List<Object?> get props => [side];
}

class OnUnsubscribeFromTemperature extends DualInfiniTimeEvent {
  final ArmSide side;

   OnUnsubscribeFromTemperature(this.side);

  @override
  List<Object?> get props => [side];
}

class OnArmTemperature extends DualInfiniTimeEvent {
  final ArmSide side;
  final double v;

   OnArmTemperature(this.side, this.v);

  @override
  List<Object?> get props => [side, v];
}

// ============================================================================
// MOUVEMENT (NOUVEAU)
// ============================================================================

class OnSubscribeToMovement extends DualInfiniTimeEvent {
  final ArmSide side;

   OnSubscribeToMovement(this.side);

  @override
  List<Object?> get props => [side];
}

class OnUnsubscribeFromMovement extends DualInfiniTimeEvent {
  final ArmSide side;

   OnUnsubscribeFromMovement(this.side);

  @override
  List<Object?> get props => [side];
}

// ============================================================================
// MUSIC EVENTS
// ============================================================================

class DualMusicMetaRequested extends DualInfiniTimeEvent {
  final ArmSide side;
  final String artist;
  final String track;
  final String album;

  DualMusicMetaRequested(
      this.side, {
        required this.artist,
        required this.track,
        required this.album,
      });

  @override
  List<Object?> get props => [side, artist, track, album];
}

class DualMusicPlayPauseRequested extends DualInfiniTimeEvent {
  final ArmSide side;
  final bool play;

  DualMusicPlayPauseRequested(this.side, this.play);

  @override
  List<Object?> get props => [side, play];
}

class OnArmMusicEvent extends DualInfiniTimeEvent {
  final ArmSide side;
  final int event;

  OnArmMusicEvent(this.side, this.event);

  @override
  List<Object?> get props => [side, event];
}

class OnMusicSetMeta extends DualInfiniTimeEvent {
  final ArmSide side;
  final String? artist;
  final String? track;
  final String? album;

   OnMusicSetMeta(
      this.side, {
        this.artist,
        this.track,
        this.album,
      });

  @override
  List<Object?> get props => [side, artist, track, album];
}

class OnMusicSetPlaying extends DualInfiniTimeEvent {
  final ArmSide side;
  final bool playing;

   OnMusicSetPlaying(this.side, this.playing);

  @override
  List<Object?> get props => [side, playing];
}

// ============================================================================
// CALL EVENTS
// ============================================================================

class OnArmCallEvent extends DualInfiniTimeEvent {
  final ArmSide side;
  final int event;

  OnArmCallEvent(this.side, this.event);

  @override
  List<Object?> get props => [side, event];
}

// ============================================================================
// TIME EVENTS (NOUVEAU)
// ============================================================================

class OnSyncTimeUtc extends DualInfiniTimeEvent {
  final ArmSide side;
  final DateTime? time;

   OnSyncTimeUtc(this.side, [this.time]);

  @override
  List<Object?> get props => [side, time];
}

class OnSendTime extends DualInfiniTimeEvent {
  final ArmSide side;
  final DateTime? time;

   OnSendTime(this.side, [this.time]);

  @override
  List<Object?> get props => [side, time];
}

// ============================================================================
// NAVIGATION EVENTS
// ============================================================================

class DualNavSendRequested extends DualInfiniTimeEvent {
  final ArmSide side;
  final String narrative;
  final String distance;
  final int progress;
  final int flags;

  DualNavSendRequested(
      this.side, {
        required this.narrative,
        required this.distance,
        required this.progress,
        required this.flags,
      });

  @override
  List<Object?> get props => [side, narrative, distance, progress, flags];
}

class OnNavNarrativeSet extends DualInfiniTimeEvent {
  final ArmSide side;
  final String narrative;

   OnNavNarrativeSet(this.side, this.narrative);

  @override
  List<Object?> get props => [side, narrative];
}

class OnNavManDistSet extends DualInfiniTimeEvent {
  final ArmSide side;
  final int distance;

   OnNavManDistSet(this.side, this.distance);

  @override
  List<Object?> get props => [side, distance];
}

class OnNavProgressSet extends DualInfiniTimeEvent {
  final ArmSide side;
  final int progress;

   OnNavProgressSet(this.side, this.progress);

  @override
  List<Object?> get props => [side, progress];
}

class OnNavFlagsSet extends DualInfiniTimeEvent {
  final ArmSide side;
  final int flags;

   OnNavFlagsSet(this.side, this.flags);

  @override
  List<Object?> get props => [side, flags];
}

// ============================================================================
// WEATHER EVENTS
// ============================================================================

class DualWeatherSendRequested extends DualInfiniTimeEvent {
  final ArmSide side;
  final Uint8List payload;

  DualWeatherSendRequested(this.side, this.payload);

  @override
  List<Object?> get props => [side, payload];
}

class OnWeatherWrite extends DualInfiniTimeEvent {
  final ArmSide side;
  final Uint8List payload;

   OnWeatherWrite(this.side, this.payload);

  @override
  List<Object?> get props => [side, payload];
}

// ============================================================================
// BLEFS EVENTS
// ============================================================================

class DualBlefsReadVersionRequested extends DualInfiniTimeEvent {
  final ArmSide side;

  DualBlefsReadVersionRequested(this.side);

  @override
  List<Object?> get props => [side];
}

class DualBlefsSendRawRequested extends DualInfiniTimeEvent {
  final ArmSide side;
  final Uint8List payload;

  DualBlefsSendRawRequested(this.side, this.payload);

  @override
  List<Object?> get props => [side, payload];
}

class OnBlefsReadVersion extends DualInfiniTimeEvent {
  final ArmSide side;

   OnBlefsReadVersion(this.side);

  @override
  List<Object?> get props => [side];
}

class OnBlefsWriteRaw extends DualInfiniTimeEvent {
  final ArmSide side;
  final Uint8List payload;

   OnBlefsWriteRaw(this.side, this.payload);

  @override
  List<Object?> get props => [side, payload];
}

// ============================================================================
// FIRMWARE DFU EVENTS
// ============================================================================

class DualSystemFirmwareDfuStartRequested extends DualInfiniTimeEvent {
  final ArmSide side;
  final String firmwarePath;

  DualSystemFirmwareDfuStartRequested(this.side, this.firmwarePath);

  @override
  List<Object?> get props => [side, firmwarePath];
}

class DualSystemFirmwareDfuAbortRequested extends DualInfiniTimeEvent {
  final ArmSide side;

  DualSystemFirmwareDfuAbortRequested(this.side);

  @override
  List<Object?> get props => [side];
}

class OnArmSystemFirmwareDfu extends DualInfiniTimeEvent {
  final ArmSide side;
  final DfuProgress p;

  OnArmSystemFirmwareDfu(this.side, this.p);

  @override
  List<Object?> get props => [side, p];
}

class OnStartSystemFirmwareDfu extends DualInfiniTimeEvent {
  final ArmSide side;
  final String firmwarePath;
  final bool? reconnectOnComplete;

   OnStartSystemFirmwareDfu(
      this.side,
      this.firmwarePath, {
        this.reconnectOnComplete,
      });

  @override
  List<Object?> get props => [side, firmwarePath, reconnectOnComplete];
}

class OnAbortSystemFirmwareDfu extends DualInfiniTimeEvent {
  final ArmSide side;

   OnAbortSystemFirmwareDfu(this.side);

  @override
  List<Object?> get props => [side];
}

// ============================================================================
// FIRMWARE MANAGEMENT EVENTS
// ============================================================================

class DualLoadAvailableFirmwaresRequested extends DualInfiniTimeEvent {}

class OnAvailableFirmwaresLoaded extends DualInfiniTimeEvent {
  final List<FirmwareInfo> firmwares;

  OnAvailableFirmwaresLoaded(this.firmwares);

  @override
  List<Object?> get props => [firmwares];
}

class DualSelectFirmwareRequested extends DualInfiniTimeEvent {
  final ArmSide side;
  final FirmwareInfo firmware;

  DualSelectFirmwareRequested(this.side, this.firmware);

  @override
  List<Object?> get props => [side, firmware];
}


// ============================================================================
// MOTION THROTTLE EVENTS
// ============================================================================

class DualMotionThrottleChanged extends DualInfiniTimeEvent {
  final ArmSide side;
  final Duration minInterval;

  DualMotionThrottleChanged(this.side, this.minInterval);

  @override
  List<Object?> get props => [side, minInterval];
}

// ============================================================================
// DEBUG EVENTS
// ============================================================================

class DualForceFlushBuffersRequested extends DualInfiniTimeEvent {
  @override
  List<Object?> get props => [];
}