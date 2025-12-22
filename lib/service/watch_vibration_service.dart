import 'package:flutter_bloc_app_template/extension/vibration_arm.dart';
import 'package:flutter_bloc_app_template/extension/vibration_mode.dart';
import 'package:flutter_bloc_app_template/models/app_settings.dart';
import 'package:flutter_bloc_app_template/models/arm_side.dart';
import 'package:flutter_bloc_app_template/utils/app_logger.dart';
import 'package:infinitime_dfu_library/infinitime_dfu_library.dart';

/// Service pour déclencher les vibrations des montres selon la configuration
class WatchVibrationService {
  static final WatchVibrationService _instance = WatchVibrationService._internal();
  factory WatchVibrationService() => _instance;
  WatchVibrationService._internal();

  // Sessions actives des montres (injectées depuis le DualInfiniTimeBloc)
  InfiniTimeSession? _leftSession;
  InfiniTimeSession? _rightSession;

  /// Configure les sessions des montres
  void configureSessions({
    InfiniTimeSession? leftSession,
    InfiniTimeSession? rightSession,
  }) {
    _leftSession = leftSession;
    _rightSession = rightSession;
    AppLogger.i('Sessions configurées: Left=${leftSession != null}, Right=${rightSession != null}');
  }

  /// Déclenche une vibration selon les paramètres de l'application
  Future<void> triggerVibration(AppSettings settings, {String? reason}) async {
    try {
      AppLogger.i('Déclenchement vibration: ${reason ?? "notification"}');

      // Déterminer quelle(s) montre(s) faire vibrer
      final targetArm = settings.vibrationTargetArm;
      final mode = settings.vibrationMode;

      List<InfiniTimeSession?> sessionsToVibrate = [];

      if (targetArm == VibrationArm.left || targetArm == VibrationArm.both) {
        sessionsToVibrate.add(_leftSession);
      }
      if (targetArm == VibrationArm.right || targetArm == VibrationArm.both) {
        sessionsToVibrate.add(_rightSession);
      }

      // Appliquer la vibration selon le mode
      for (final session in sessionsToVibrate) {
        if (session != null) {
          await _applyVibrationMode(session, mode, settings);
        }
      }

      AppLogger.i('Vibration déclenchée avec succès');
    } catch (e) {
      AppLogger.e('Erreur lors du déclenchement de la vibration', error: e);
    }
  }

  /// Applique le pattern de vibration selon le mode
  Future<void> _applyVibrationMode(
    InfiniTimeSession session,
    VibrationMode mode,
    AppSettings settings,
  ) async {
    switch (mode) {
      case VibrationMode.short:
        // Vibration courte: 200ms ON
        await _vibratePattern(session, onMs: 200, offMs: 0, repeat: 1);
        break;

      case VibrationMode.long:
        // Vibration longue: 500ms ON
        await _vibratePattern(session, onMs: 500, offMs: 0, repeat: 1);
        break;

      case VibrationMode.doubleShort:
        // Double vibration courte: 200ms ON, 100ms OFF, 200ms ON
        await _vibratePattern(session, onMs: 200, offMs: 100, repeat: 2);
        break;

      case VibrationMode.custom:
        // Pattern personnalisé depuis les settings
        final onMs = settings.vibrationOnMs;
        final offMs = settings.vibrationOffMs;
        final repeat = settings.vibrationRepeat;
        await _vibratePattern(session, onMs: onMs, offMs: offMs, repeat: repeat);
        break;

      default:
        AppLogger.w('Mode de vibration inconnu: $mode');
    }
  }

  /// Exécute un pattern de vibration
  Future<void> _vibratePattern(
    InfiniTimeSession session, {
    required int onMs,
    required int offMs,
    required int repeat,
  }) async {
    for (int i = 0; i < repeat; i++) {
      // Activer la vibration via sendNotification
      await session.sendNotification(
        title: 'Rappel',
        message: 'Objectif de rééducation',
      );

      // Attendre la durée ON
      await Future.delayed(Duration(milliseconds: onMs));

      // Si ce n'est pas la dernière répétition et qu'il y a un délai OFF
      if (i < repeat - 1 && offMs > 0) {
        await Future.delayed(Duration(milliseconds: offMs));
      }
    }
  }

  /// Vibration simple d'une montre spécifique (pour tests)
  Future<void> vibrateSingle(ArmSide side) async {
    final session = side == ArmSide.left ? _leftSession : _rightSession;

    if (session == null) {
      AppLogger.w('Session non disponible pour ${side.label}');
      return;
    }

    await session.sendNotification(
      title: 'Test',
      message: 'Vibration test',
    );
    AppLogger.i('Vibration test envoyée à ${side.label}');
  }

  /// Teste le pattern de vibration actuel
  Future<void> testCurrentPattern(AppSettings settings) async {
    AppLogger.i('Test du pattern de vibration');
    await triggerVibration(settings, reason: 'test');
  }

  /// Vérifie si au moins une session est disponible
  bool get hasActiveSession => _leftSession != null || _rightSession != null;

  /// Vérifie si une session spécifique est disponible
  bool hasSessionFor(ArmSide side) {
    return side == ArmSide.left ? _leftSession != null : _rightSession != null;
  }
}
