import 'package:shared_preferences/shared_preferences.dart';

import '../../../models/arm_side.dart';
import '../../../utils/app_logger.dart';

/// Handler pour la gestion des bindings (association bras <-> device)
class BindingHandler {
  static const String _leftDeviceIdKey = 'bound_left_device_id';
  static const String _rightDeviceIdKey = 'bound_right_device_id';
  static const String _leftDeviceNameKey = 'bound_left_device_name';
  static const String _rightDeviceNameKey = 'bound_right_device_name';

  /// Charge les bindings sauvegardés
  static Future<Map<ArmSide, BindingInfo?>> loadBindings() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final leftId = prefs.getString(_leftDeviceIdKey);
      final leftName = prefs.getString(_leftDeviceNameKey);
      final rightId = prefs.getString(_rightDeviceIdKey);
      final rightName = prefs.getString(_rightDeviceNameKey);

      return {
        ArmSide.left: leftId != null
            ? BindingInfo(deviceId: leftId, name: leftName)
            : null,
        ArmSide.right: rightId != null
            ? BindingInfo(deviceId: rightId, name: rightName)
            : null,
      };
    } catch (e, stackTrace) {
      AppLogger.error('Error loading bindings', e, stackTrace);
      return {ArmSide.left: null, ArmSide.right: null};
    }
  }

  /// Sauvegarde un binding
  static Future<bool> saveBinding(
    ArmSide side,
    String deviceId, {
    String? name,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (side == ArmSide.left) {
        await prefs.setString(_leftDeviceIdKey, deviceId);
        if (name != null) {
          await prefs.setString(_leftDeviceNameKey, name);
        }
      } else {
        await prefs.setString(_rightDeviceIdKey, deviceId);
        if (name != null) {
          await prefs.setString(_rightDeviceNameKey, name);
        }
      }

      AppLogger.info('Binding saved for ${side.name}: $deviceId');
      return true;
    } catch (e, stackTrace) {
      AppLogger.error('Error saving binding', e, stackTrace);
      return false;
    }
  }

  /// Supprime un binding
  static Future<bool> removeBinding(ArmSide side) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (side == ArmSide.left) {
        await prefs.remove(_leftDeviceIdKey);
        await prefs.remove(_leftDeviceNameKey);
      } else {
        await prefs.remove(_rightDeviceIdKey);
        await prefs.remove(_rightDeviceNameKey);
      }

      AppLogger.info('Binding removed for ${side.name}');
      return true;
    } catch (e, stackTrace) {
      AppLogger.error('Error removing binding', e, stackTrace);
      return false;
    }
  }

  /// Vérifie si un bras est lié
  static Future<bool> isBound(ArmSide side) async {
    final bindings = await loadBindings();
    return bindings[side] != null;
  }

  /// Obtient l'ID du device lié à un bras
  static Future<String?> getBoundDeviceId(ArmSide side) async {
    final bindings = await loadBindings();
    return bindings[side]?.deviceId;
  }
}

/// Information de binding
class BindingInfo {
  final String deviceId;
  final String? name;

  BindingInfo({required this.deviceId, this.name});
}
