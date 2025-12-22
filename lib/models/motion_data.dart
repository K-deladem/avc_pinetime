// models/motion_data.dart

import 'package:uuid/uuid.dart';

class MotionData {
  final String id;
  final String armSide; // 'left' ou 'right'
  final int x; // Valeur X de l'accéléromètre/gyroscope
  final int y; // Valeur Y de l'accéléromètre/gyroscope
  final int z; // Valeur Z de l'accéléromètre/gyroscope
  final DateTime timestamp;
  final int? rssi;

  MotionData({
    String? id,
    required this.armSide,
    required this.x,
    required this.y,
    required this.z,
    required this.timestamp,
    this.rssi,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() => {
    'id': id,
    'armSide': armSide,
    'x': x,
    'y': y,
    'z': z,
    'timestamp': timestamp.toIso8601String(),
    'rssi': rssi,
  };

  factory MotionData.fromJson(Map<String, dynamic> json) => MotionData(
    id: json['id'] as String?,
    armSide: json['armSide'] as String? ?? 'unknown',
    x: json['x'] as int? ?? 0,
    y: json['y'] as int? ?? 0,
    z: json['z'] as int? ?? 0,
    timestamp: json['timestamp'] != null
        ? DateTime.parse(json['timestamp'] as String)
        : DateTime.now(),
    rssi: json['rssi'] as int?,
  );

  /// Calcule la magnitude du vecteur de mouvement
  double getMagnitude() {
    return (x * x + y * y + z * z).toDouble();
  }

  @override
  String toString() => 'Motion(x:$x, y:$y, z:$z, $armSide, $timestamp)';
}

class MotionStats {
  final String armSide;
  final DateTime date;
  final double? avgX;
  final double? avgY;
  final double? avgZ;
  final double? avgMagnitude;
  final int recordCount;

  MotionStats({
    required this.armSide,
    required this.date,
    this.avgX,
    this.avgY,
    this.avgZ,
    this.avgMagnitude,
    required this.recordCount,
  });

  Map<String, dynamic> toJson() => {
    'armSide': armSide,
    'date': date.toIso8601String(),
    'avgX': avgX,
    'avgY': avgY,
    'avgZ': avgZ,
    'avgMagnitude': avgMagnitude,
    'recordCount': recordCount,
  };
}
