import 'package:flutter_bloc_app_template/models/info_type.dart';

class DeviceInfoData {
  final String id;
  final InfoType infoType;
  final String armSide;
  final double value;
  final DateTime timestamp;   // <-- DateTime maintenant
  final DateTime createdAt;   // <-- DateTime maintenant

  DeviceInfoData({
    required this.id,
    required this.infoType,
    required this.armSide,
    required this.value,
    required this.timestamp,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'infoType': infoType.name,
      'armSide': armSide,
      'value': value,
      'timestamp': timestamp.toIso8601String(),   // stockage en TEXT ISO8601
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory DeviceInfoData.fromMap(Map<String, dynamic> map) {
    return DeviceInfoData(
      id: map['id'],
      infoType: InfoType.fromString(map['infoType']),
      armSide: map['armSide'],
      value: (map['value'] as num).toDouble(),
      timestamp: DateTime.parse(map['timestamp']),   // conversion ISO → DateTime
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}