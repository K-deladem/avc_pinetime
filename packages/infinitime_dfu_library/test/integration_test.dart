import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/foundation.dart';
import 'package:infinitime_dfu_library/infinitime_dfu_library.dart';

void main() {
  group('Library Tests', () {
    test('Enumerations exist and have values', () {
      expect(NavDirection.values, isNotEmpty);
      expect(MusicEvent.values, isNotEmpty);
      expect(InfiniTimeConnectionState.values, isNotEmpty);
    });

    test('FirmwareInfo can be created', () {
      final info = FirmwareInfo(
        assetPath: '/assets/test.bin',
        fileName: 'test.bin',
        version: '1.0.0',
      );
      expect(info.assetPath, equals('/assets/test.bin'));
      expect(info.fileName, equals('test.bin'));
      expect(info.version, equals('1.0.0'));
    });

    test('DfuFiles can be created and validated', () {
      final firmware = Uint8List(2048); // 2KB
      final initPacket = Uint8List(128);

      final files = DfuFiles(
        firmware: firmware,
        initPacket: initPacket,
         path:  '/assets/test.bin');

      expect(files.firmware.length, equals(2048));
      expect(files.initPacket.length, equals(128));
      expect(files.validate(), true);
    });

    test('DfuProtocolHelper creates packets', () {
      final packet = DfuProtocolHelper.createStartDfuPacket();
      expect(packet, isNotEmpty);

      final sizePacket = DfuProtocolHelper.createSizePacket(firmwareSize: 4096);
      expect(sizePacket.length, equals(12));
    });

    test('DataParser can parse battery level', () {
      final level = DataParser.parseBatteryLevel([85]);
      expect(level, equals(85));
    });

    test('DataParser can parse heart rate', () {
      final hr = DataParser.parseHeartRate([72]);
      expect(hr, equals(72));
    });
  });
}