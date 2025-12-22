// Modèle pour l'historique
import 'package:flutter_bloc_app_template/models/arm_side.dart';

class DeviceHistoryEntry {
  final String id;
  final String name;
  final DateTime lastConnected;
  final ArmSide? lastPosition;
  final List<String> serviceUuids;
  final int? lastRssi;
  bool isFavorite;
  int connectionCount;

  DeviceHistoryEntry({
    required this.id,
    required this.name,
    required this.lastConnected,
    this.lastPosition,
    this.serviceUuids = const [],
    this.lastRssi,
    this.isFavorite = false,
    this.connectionCount = 1,
  });

  factory DeviceHistoryEntry.fromJson(Map<String, dynamic> json) {
    return DeviceHistoryEntry(
      id: json['id'],
      name: json['name'],
      lastConnected: DateTime.parse(json['lastConnected']),
      lastPosition: json['lastPosition'] != null
          ? ArmSide.values.firstWhere((e) => e.name == json['lastPosition'])
          : null,
      serviceUuids: List<String>.from(json['serviceUuids'] ?? []),
      lastRssi: json['lastRssi'],
      isFavorite: json['isFavorite'] ?? false,
      connectionCount: json['connectionCount'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'lastConnected': lastConnected.toIso8601String(),
    'lastPosition': lastPosition?.name,
    'serviceUuids': serviceUuids,
    'lastRssi': lastRssi,
    'isFavorite': isFavorite,
    'connectionCount': connectionCount,
  };
}