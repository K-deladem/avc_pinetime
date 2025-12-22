import 'package:flutter_bloc_app_template/models/arm_side.dart';

class WatchDevice {
  final String id;
  final String name;
  final String manufacturer;
  final String model;
  final String firmwareVersion;
  final String hardwareVersion;
  final ArmSide armSide;
  final int? batteryLevel;
  final bool isLastConnected;
  final DateTime? lastConnectionTime;
  final DateTime? lastSyncTime;

  WatchDevice({
    required this.id,
    required this.name,
    required this.manufacturer,
    required this.model,
    required this.firmwareVersion,
    required this.hardwareVersion,
    required this.armSide,
    this.batteryLevel,
    this.isLastConnected = false,
    this.lastConnectionTime,
    this.lastSyncTime,
  });

  factory WatchDevice.fromMap(Map<String, dynamic> map) => WatchDevice(
    id: map['id'],
    name: map['name'],
    manufacturer: map['manufacturer'],
    model: map['model'],
    firmwareVersion: map['firmwareVersion'],
    hardwareVersion: map['hardwareVersion'],
    armSide: ArmSide.values.byName(map['armSide']),
    batteryLevel: map['batteryLevel'],
    isLastConnected: map['isLastConnected'] == 1,
    lastConnectionTime: map['lastConnectionTime'] != null ? DateTime.tryParse(map['lastConnectionTime']) : null,
    lastSyncTime: map['lastSyncTime'] != null ? DateTime.tryParse(map['lastSyncTime']) : null,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'manufacturer': manufacturer,
    'model': model,
    'firmwareVersion': firmwareVersion,
    'hardwareVersion': hardwareVersion,
    'armSide': armSide.name,
    'batteryLevel': batteryLevel,
    'isLastConnected': isLastConnected ? 1 : 0,
    'lastConnectionTime': lastConnectionTime?.toIso8601String(),
    'lastSyncTime': lastSyncTime?.toIso8601String(),
  };

  factory WatchDevice.fromJson(Map<String, dynamic> json) => WatchDevice(
    id: json['id'],
    name: json['name'],
    manufacturer: json['manufacturer'],
    model: json['model'],
    firmwareVersion: json['firmwareVersion'],
    hardwareVersion: json['hardwareVersion'],
    armSide: ArmSide.values.byName(json['armSide']),
    batteryLevel: json['batteryLevel'],
    isLastConnected: json['isLastConnected'] ?? false,
    lastConnectionTime: json['lastConnectionTime'] != null ? DateTime.parse(json['lastConnectionTime']) : null,
    lastSyncTime: json['lastSyncTime'] != null ? DateTime.parse(json['lastSyncTime']) : null,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'manufacturer': manufacturer,
    'model': model,
    'firmwareVersion': firmwareVersion,
    'hardwareVersion': hardwareVersion,
    'armSide': armSide.name,
    'batteryLevel': batteryLevel,
    'isLastConnected': isLastConnected,
    'lastConnectionTime': lastConnectionTime?.toIso8601String(),
    'lastSyncTime': lastSyncTime?.toIso8601String(),
  };

  WatchDevice copyWith({
    String? name,
    String? manufacturer,
    String? model,
    String? firmwareVersion,
    String? hardwareVersion,
    bool? isLastConnected,
    DateTime? lastConnectionTime,
    DateTime? lastSyncTime,
    int? batteryLevel,
  }) {
    return WatchDevice(
      id: id,
      name: name ?? this.name,
      manufacturer: manufacturer ?? this.manufacturer,
      model: model ?? this.model,
      firmwareVersion: firmwareVersion ?? this.firmwareVersion,
      hardwareVersion: hardwareVersion ?? this.hardwareVersion,
      armSide: armSide,
      isLastConnected: isLastConnected ?? this.isLastConnected,
      lastConnectionTime: lastConnectionTime ?? this.lastConnectionTime,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      batteryLevel: batteryLevel ?? this.batteryLevel,
    );
  }
}
