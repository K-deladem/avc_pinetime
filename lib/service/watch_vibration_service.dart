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

  // Sessions actives des montres (injectées depuis le DeviceBloc)
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
  /// [reason] peut être: 'objectif_atteint', 'rappel_objectif', 'test_manuel'
  /// [currentRatio] et [goalRatio] sont optionnels pour personnaliser le message
  Future<void> triggerVibration(
    AppSettings settings, {
    String? reason,
    double? currentRatio,
    int? goalRatio,
  }) async {
    try {
      AppLogger.i('=== VIBRATION TRIGGER START ===');
      AppLogger.i('Raison: ${reason ?? "notification"}');
      AppLogger.i('Target arm: ${settings.vibrationTargetArm.label}');
      AppLogger.i('Mode: ${settings.vibrationMode}');
      AppLogger.i('Left session: ${_leftSession != null ? "OK" : "NULL"}');
      AppLogger.i('Right session: ${_rightSession != null ? "OK" : "NULL"}');

      // Déterminer le message selon la raison
      String title;
      String message;
      switch (reason) {
        case 'objectif_atteint':
          title = 'Objectif atteint!';
          message = currentRatio != null
              ? 'Bravo! ${currentRatio.toStringAsFixed(0)}%'
              : 'Bravo!';
          break;
        case 'rappel_objectif':
          title = 'Objectif en cours';
          if (currentRatio != null && goalRatio != null) {
            final gap = goalRatio - currentRatio;
            message = '${currentRatio.toStringAsFixed(0)}% - ${gap.toStringAsFixed(0)}% restant';
          } else {
            message = 'Continuez vos efforts!';
          }
          break;
        case 'test_manuel':
          title = 'Test';
          message = 'Vibration OK';
          break;
        default:
          title = 'Rappel';
          message = 'Vérifiez votre progression';
      }

      // Déterminer quelle(s) montre(s) faire vibrer
      final targetArm = settings.vibrationTargetArm;
      final mode = settings.vibrationMode;

      List<InfiniTimeSession?> sessionsToVibrate = [];

      if (targetArm == VibrationArm.left || targetArm == VibrationArm.both) {
        AppLogger.i('Adding left session to vibrate list');
        sessionsToVibrate.add(_leftSession);
      }
      if (targetArm == VibrationArm.right || targetArm == VibrationArm.both) {
        AppLogger.i('Adding right session to vibrate list');
        sessionsToVibrate.add(_rightSession);
      }

      AppLogger.i('Sessions to vibrate: ${sessionsToVibrate.length} (non-null: ${sessionsToVibrate.where((s) => s != null).length})');

      // Appliquer la vibration selon le mode
      int vibratedCount = 0;
      for (final session in sessionsToVibrate) {
        if (session != null) {
          AppLogger.i('Applying vibration to session...');
          await _applyVibrationMode(session, mode, settings, title: title, message: message);
          vibratedCount++;
        } else {
          AppLogger.w('Session is null, skipping vibration');
        }
      }

      if (vibratedCount > 0) {
        AppLogger.i('Vibration déclenchée avec succès sur $vibratedCount montre(s)');
      } else {
        AppLogger.w('AUCUNE VIBRATION: aucune session disponible');
      }
      AppLogger.i('=== VIBRATION TRIGGER END ===');
    } catch (e) {
      AppLogger.e('Erreur lors du déclenchement de la vibration', error: e);
    }
  }

  /// Applique le pattern de vibration selon le mode
  /// Modes simplifiés: simple (1x), double (2x), custom (Nx)
  Future<void> _applyVibrationMode(
    InfiniTimeSession session,
    VibrationMode mode,
    AppSettings settings, {
    required String title,
    required String message,
  }) async {
    switch (mode) {
      case VibrationMode.short:
        // Vibration simple: 1 notification
        await _vibratePattern(session, onMs: 200, offMs: 0, repeat: 1, title: title, message: message);
        break;

      case VibrationMode.doubleShort:
        // Double vibration: 2 notifications
        await _vibratePattern(session, onMs: 200, offMs: 300, repeat: 2, title: title, message: message);
        break;

      case VibrationMode.custom:
        // Pattern personnalisé: N répétitions définies par l'utilisateur
        final repeat = settings.vibrationRepeat;
        await _vibratePattern(session, onMs: 200, offMs: 300, repeat: repeat, title: title, message: message);
        break;

      // Modes obsolètes - traités comme simple
      case VibrationMode.long:
      case VibrationMode.continuous:
      default:
        await _vibratePattern(session, onMs: 200, offMs: 0, repeat: 1, title: title, message: message);
    }
  }

  /// Exécute un pattern de vibration avec message personnalisé
  Future<void> _vibratePattern(
    InfiniTimeSession session, {
    required int onMs,
    required int offMs,
    required int repeat,
    String title = 'Objectif',
    String message = 'Vérifiez votre progression',
  }) async {
    for (int i = 0; i < repeat; i++) {
      // Activer la vibration via sendNotification
      await session.sendNotification(
        title: title,
        message: message,
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
