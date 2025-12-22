
import 'dart:typed_data';

class PineTimeDevice {
  final String id;
  final String name;
  final int rssi;
  final List<String> advertisedServices;
  final Uint8List manufacturerData;
  final bool isConnectable;

  PineTimeDevice({
    required this.id,
    required this.name,
    required this.rssi,
    required this.advertisedServices,
    required this.manufacturerData,
    required this.isConnectable,
  });

  @override
  String toString() => 'PineTimeDevice($name, $id, ${rssi}dBm)';
}
