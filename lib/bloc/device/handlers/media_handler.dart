import 'dart:typed_data';

import 'package:infinitime_dfu_library/infinitime_dfu_library.dart';

import '../../../utils/app_logger.dart';

/// Handler pour la musique, navigation et météo
class MediaHandler {
  // ========== MUSIQUE ==========

  /// Envoie les métadonnées musicales à la montre
  static Future<bool> sendMusicMeta(
    InfiniTimeSession session, {
    required String artist,
    required String track,
    required String album,
  }) async {
    try {
      await session.musicSetMeta(
        artist: artist,
        track: track,
        album: album,
      );
      AppLogger.debug('Music meta sent: $artist - $track');
      return true;
    } catch (e, stackTrace) {
      AppLogger.error('Error sending music meta', e, stackTrace);
      return false;
    }
  }

  /// Envoie l'état play/pause à la montre
  static Future<bool> sendMusicPlayPause(
    InfiniTimeSession session,
    bool isPlaying,
  ) async {
    try {
      await session.musicSetPlaying(isPlaying);
      AppLogger.debug('Music playing state sent: $isPlaying');
      return true;
    } catch (e, stackTrace) {
      AppLogger.error('Error sending music state', e, stackTrace);
      return false;
    }
  }

  /// Traite un événement musique reçu de la montre
  static MusicCommand parseMusicEvent(int eventCode) {
    switch (eventCode) {
      case 0:
        return MusicCommand.play;
      case 1:
        return MusicCommand.pause;
      case 2:
        return MusicCommand.next;
      case 3:
        return MusicCommand.previous;
      case 4:
        return MusicCommand.volumeUp;
      case 5:
        return MusicCommand.volumeDown;
      default:
        return MusicCommand.unknown;
    }
  }

  // ========== APPELS ==========

  /// Traite un événement d'appel reçu de la montre
  static CallAction parseCallEvent(int eventCode) {
    switch (eventCode) {
      case 0:
        return CallAction.accept;
      case 1:
        return CallAction.reject;
      case 2:
        return CallAction.mute;
      default:
        return CallAction.unknown;
    }
  }

  // ========== NAVIGATION ==========

  /// Envoie les données de navigation à la montre
  static Future<bool> sendNavigation(
    InfiniTimeSession session, {
    required String narrative,
    required String distance,
    required int progress,
    required int flags,
  }) async {
    try {
      await session.navNarrativeSet(narrative);
      await session.navManDistSet(distance);
      await session.navProgressSet(progress);
      await session.navFlagsSet(flags);
      AppLogger.debug('Navigation sent: $narrative, $distance');
      return true;
    } catch (e, stackTrace) {
      AppLogger.error('Error sending navigation', e, stackTrace);
      return false;
    }
  }

  // ========== MÉTÉO ==========

  /// Envoie les données météo à la montre
  static Future<bool> sendWeather(
    InfiniTimeSession session,
    Uint8List payload,
  ) async {
    try {
      await session.weatherWrite(payload);
      AppLogger.debug('Weather sent: ${payload.length} bytes');
      return true;
    } catch (e, stackTrace) {
      AppLogger.error('Error sending weather', e, stackTrace);
      return false;
    }
  }

  // ========== BLEFS (Fichiers) ==========

  /// Lit la version BLEFS
  static Future<String?> readBlefsVersion(InfiniTimeSession session) async {
    try {
      final version = await session.blefsReadVersion();
      AppLogger.debug('BLEFS version: $version');
      return version;
    } catch (e, stackTrace) {
      AppLogger.error('Error reading BLEFS version', e, stackTrace);
      return null;
    }
  }

  /// Envoie des données brutes BLEFS
  static Future<bool> sendBlefsRaw(
    InfiniTimeSession session,
    Uint8List payload,
  ) async {
    try {
      await session.blefsWriteRaw(payload);
      AppLogger.debug('BLEFS raw sent: ${payload.length} bytes');
      return true;
    } catch (e, stackTrace) {
      AppLogger.error('Error sending BLEFS raw', e, stackTrace);
      return false;
    }
  }
}

/// Commandes musicales
enum MusicCommand {
  play,
  pause,
  next,
  previous,
  volumeUp,
  volumeDown,
  unknown,
}

/// Actions d'appel
enum CallAction {
  accept,
  reject,
  mute,
  unknown,
}
