import 'package:flutter_test/flutter_test.dart';
import 'package:infinitime_dfu_library/infinitime_dfu_library.dart';

void main() {
  group('Enumerations Tests', () {
    group('NavDirection', () {
      test('NavDirection has correct values', () {
        expect(NavDirection.turnLeft.value, 0x00);
        expect(NavDirection.turnRight.value, 0x01);
        expect(NavDirection.turnSharpLeft.value, 0x02);
        expect(NavDirection.turnSharpRight.value, 0x03);
        expect(NavDirection.turnSlightLeft.value, 0x04);
        expect(NavDirection.turnSlightRight.value, 0x05);
        expect(NavDirection.continueRoute.value, 0x06);
        expect(NavDirection.uTurn.value, 0x07);
        expect(NavDirection.finish.value, 0x08);
      });

      test('NavDirection has correct displayNames', () {
        expect(NavDirection.turnLeft.displayName, "Turn Left");
        expect(NavDirection.turnRight.displayName, "Turn Right");
        expect(NavDirection.turnSharpLeft.displayName, "Turn Sharp Left");
        expect(NavDirection.turnSharpRight.displayName, "Turn Sharp Right");
        expect(NavDirection.turnSlightLeft.displayName, "Turn Slight Left");
        expect(NavDirection.turnSlightRight.displayName, "Turn Slight Right");
        expect(NavDirection.continueRoute.displayName, "Continue");
        expect(NavDirection.uTurn.displayName, "U-Turn");
        expect(NavDirection.finish.displayName, "Finish");
      });

      test('NavDirection.fromValue returns correct values', () {
        expect(NavDirection.fromValue(0x00), NavDirection.turnLeft);
        expect(NavDirection.fromValue(0x01), NavDirection.turnRight);
        expect(NavDirection.fromValue(0x02), NavDirection.turnSharpLeft);
        expect(NavDirection.fromValue(0x06), NavDirection.continueRoute);
        expect(NavDirection.fromValue(0x08), NavDirection.finish);
      });

      test('NavDirection.fromValue returns null for invalid values', () {
        expect(NavDirection.fromValue(0xFF), null);
        expect(NavDirection.fromValue(-1), null);
        expect(NavDirection.fromValue(999), null);
      });
    });

    group('MusicEvent', () {
      test('MusicEvent has correct values', () {
        expect(MusicEvent.play.value, 0x00);
        expect(MusicEvent.pause.value, 0x01);
        expect(MusicEvent.next.value, 0x03);
        expect(MusicEvent.previous.value, 0x04);
        expect(MusicEvent.volumeUp.value, 0x05);
        expect(MusicEvent.volumeDown.value, 0x06);
      });

      test('MusicEvent has correct displayNames', () {
        expect(MusicEvent.play.displayName, "PLAY");
        expect(MusicEvent.pause.displayName, "PAUSE");
        expect(MusicEvent.next.displayName, "NEXT");
        expect(MusicEvent.previous.displayName, "PREVIOUS");
        expect(MusicEvent.volumeUp.displayName, "VOLUME_UP");
        expect(MusicEvent.volumeDown.displayName, "VOLUME_DOWN");
      });

      test('MusicEvent.fromValue returns correct values', () {
        expect(MusicEvent.fromValue(0x00), MusicEvent.play);
        expect(MusicEvent.fromValue(0x01), MusicEvent.pause);
        expect(MusicEvent.fromValue(0x03), MusicEvent.next);
        expect(MusicEvent.fromValue(0x04), MusicEvent.previous);
        expect(MusicEvent.fromValue(0x05), MusicEvent.volumeUp);
        expect(MusicEvent.fromValue(0x06), MusicEvent.volumeDown);
      });

      test('MusicEvent.fromValue returns null for invalid values', () {
        expect(MusicEvent.fromValue(0xFF), null);
        expect(MusicEvent.fromValue(0x02), null); // Gap in values
        expect(MusicEvent.fromValue(-1), null);
      });
    });

    group('InfiniTimeConnectionState', () {
      test('InfiniTimeConnectionState has all required states', () {
        final states = InfiniTimeConnectionState.values;
        expect(states.contains(InfiniTimeConnectionState.connecting), true);
        expect(states.contains(InfiniTimeConnectionState.connected), true);
        expect(states.contains(InfiniTimeConnectionState.disconnecting), true);
        expect(states.contains(InfiniTimeConnectionState.disconnected), true);
        expect(states.contains(InfiniTimeConnectionState.unknown), true);
      });

      test('InfiniTimeConnectionState can be created', () {
        final state = InfiniTimeConnectionState.connected;
        expect(state, isA<InfiniTimeConnectionState>());
        expect(state, InfiniTimeConnectionState.connected);
      });
    });
  });

  group('Enum Naming Tests', () {
    test('NavDirection name does not conflict with external packages', () {
      // This test ensures NavDirection is properly named
      final direction = NavDirection.turnLeft;
      expect(direction.runtimeType.toString(), contains('NavDirection'));
    });

    test('InfiniTimeConnectionState is clearly prefixed with InfiniTime', () {
      // This test ensures the naming avoids conflicts
      final state = InfiniTimeConnectionState.connected;
      expect(state.runtimeType.toString(), contains('InfiniTimeConnectionState'));
    });

    test('MusicEvent name does not conflict', () {
      final event = MusicEvent.play;
      expect(event.runtimeType.toString(), contains('MusicEvent'));
    });
  });

  group('Enum Performance Tests', () {
    test('NavDirection displayName is direct property (fast access)', () {
      final stopwatch = Stopwatch()..start();
      for (int i = 0; i < 10000; i++) {
        final _ = NavDirection.turnLeft.displayName;
      }
      stopwatch.stop();

      // Should be very fast since displayName is a direct property
      expect(stopwatch.elapsedMilliseconds, lessThan(50));
    });

    test('MusicEvent displayName is direct property (fast access)', () {
      final stopwatch = Stopwatch()..start();
      for (int i = 0; i < 10000; i++) {
        final _ = MusicEvent.play.displayName;
      }
      stopwatch.stop();

      // Should be very fast since displayName is a direct property
      expect(stopwatch.elapsedMilliseconds, lessThan(50));
    });

    test('fromValue lookup is efficient', () {
      final stopwatch = Stopwatch()..start();
      for (int i = 0; i < 1000; i++) {
        NavDirection.fromValue(0x03);
        MusicEvent.fromValue(0x05);
      }
      stopwatch.stop();

      // Should complete quickly
      expect(stopwatch.elapsedMilliseconds, lessThan(100));
    });
  });
}