// models/battery_data.dart

import 'package:uuid/uuid.dart';

class BatteryData {
  final String id;
  final String armSide; // 'left' ou 'right'
  final int level; // Niveau de batterie 0-100%
  final DateTime timestamp;
  final int? rssi;

  BatteryData({
    String? id,
    required this.armSide,
    required this.level,
    required this.timestamp,
    this.rssi,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() => {
    'id': id,
    'armSide': armSide,
    'level': level,
    'timestamp': timestamp.toIso8601String(),
    'rssi': rssi,
  };

  factory BatteryData.fromJson(Map<String, dynamic> json) => BatteryData(
    id: json['id'] as String?,
    armSide: json['armSide'] as String? ?? 'unknown',
    level: json['level'] as int? ?? 0,
    timestamp: json['timestamp'] != null
        ? DateTime.parse(json['timestamp'] as String)
        : DateTime.now(),
    rssi: json['rssi'] as int?,
  );

  @override
  String toString() => 'Battery($level%, $armSide, $timestamp)';
}

class BatteryStats {
  final String armSide;
  final DateTime date;
  final int? minLevel;
  final int? maxLevel;
  final double? avgLevel;
  final int recordCount;

  BatteryStats({
    required this.armSide,
    required this.date,
    this.minLevel,
    this.maxLevel,
    this.avgLevel,
    required this.recordCount,
  });

  Map<String, dynamic> toJson() => {
    'armSide': armSide,
    'date': date.toIso8601String(),
    'minLevel': minLevel,
    'maxLevel': maxLevel,
    'avgLevel': avgLevel,
    'recordCount': recordCount,
  };
}
