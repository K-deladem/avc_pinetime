// lib/src/models/enums.dart

/// Types d'événements musicaux
enum MusicEvent {
  play(0x00, "PLAY"),
  pause(0x01, "PAUSE"),
  next(0x03, "NEXT"),
  previous(0x04, "PREVIOUS"),
  volumeUp(0x05, "VOLUME_UP"),
  volumeDown(0x06, "VOLUME_DOWN");

  final int value;
  final String displayName;

  const MusicEvent(this.value, this.displayName);

  static MusicEvent? fromValue(int value) {
    for (final event in MusicEvent.values) {
      if (event.value == value) return event;
    }
    return null;
  }
}

/// Direction de navigation
enum NavDirection {
  turnLeft(0x00, "Turn Left"),
  turnRight(0x01, "Turn Right"),
  turnSharpLeft(0x02, "Turn Sharp Left"),
  turnSharpRight(0x03, "Turn Sharp Right"),
  turnSlightLeft(0x04, "Turn Slight Left"),
  turnSlightRight(0x05, "Turn Slight Right"),
  continueRoute(0x06, "Continue"),
  uTurn(0x07, "U-Turn"),
  finish(0x08, "Finish");

  final int value;
  final String displayName;

  const NavDirection(this.value, this.displayName);

  static NavDirection? fromValue(int value) {
    for (final dir in NavDirection.values) {
      if (dir.value == value) return dir;
    }
    return null;
  }
}

/// Code de réponse DFU
enum DfuResponse {
  success(0x01, "Success"),
  invalidState(0x02, "Invalid State"),
  notSupported(0x03, "Not Supported"),
  dataSizeExceeds(0x04, "Data Size Exceeds Limit"),
  crcError(0x05, "CRC Error"),
  operationFailed(0x06, "Operation Failed");

  final int value;
  final String message;

  const DfuResponse(this.value, this.message);

  static DfuResponse? fromValue(int value) {
    for (final response in DfuResponse.values) {
      if (response.value == value) return response;
    }
    return null;
  }
}

/// État de connexion de la session InfiniTime
enum InfiniTimeConnectionState {
  connecting,
  connected,
  disconnecting,
  disconnected,
  unknown,
}

/// État de la mise à jour DFU
enum DfuUpdateState {
  idle,
  preparing,
  initialized,
  sending,
  validating,
  activating,
  completed,
  failed,
  cancelled,
}
