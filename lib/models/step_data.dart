// models/step_data.dart

import 'package:uuid/uuid.dart';

class StepData {
  final String id;
  final String armSide; // 'left' ou 'right'
  final int stepCount; // Nombre de pas
  final DateTime timestamp;
  final int? rssi;

  StepData({
    String? id,
    required this.armSide,
    required this.stepCount,
    required this.timestamp,
    this.rssi,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() => {
    'id': id,
    'armSide': armSide,
    'stepCount': stepCount,
    'timestamp': timestamp.toIso8601String(),
    'rssi': rssi,
  };

  factory StepData.fromJson(Map<String, dynamic> json) => StepData(
    id: json['id'] as String?,
    armSide: json['armSide'] as String? ?? 'unknown',
    stepCount: json['stepCount'] as int? ?? 0,
    timestamp: json['timestamp'] != null
        ? DateTime.parse(json['timestamp'] as String)
        : DateTime.now(),
    rssi: json['rssi'] as int?,
  );

  @override
  String toString() => 'Steps($stepCount steps, $armSide, $timestamp)';
}

class StepStats {
  final String armSide;
  final DateTime date;
  final int? minSteps;
  final int? maxSteps;
  final double? avgSteps;
  final int totalSteps;
  final int recordCount;

  StepStats({
    required this.armSide,
    required this.date,
    this.minSteps,
    this.maxSteps,
    this.avgSteps,
    required this.totalSteps,
    required this.recordCount,
  });

  Map<String, dynamic> toJson() => {
    'armSide': armSide,
    'date': date.toIso8601String(),
    'minSteps': minSteps,
    'maxSteps': maxSteps,
    'avgSteps': avgSteps,
    'totalSteps': totalSteps,
    'recordCount': recordCount,
  };
}
