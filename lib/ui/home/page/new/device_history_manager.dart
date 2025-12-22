
// device_history_manager.dart
import 'dart:convert';

import 'package:flutter_bloc_app_template/models/arm_side.dart';
import 'package:flutter_bloc_app_template/models/device_history_entry.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeviceHistoryManager {
  static const String _historyKey = 'bluetooth_device_history';
  static const String _favoritesKey = 'bluetooth_device_favorites';

  // =================== MÉTHODES FAVORIS ===================

  /// Vérifier si un device est en favoris
  static Future<bool> isFavoriteDevice(String deviceId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favorites = prefs.getStringList(_favoritesKey) ?? [];
      return favorites.contains(deviceId);
    } catch (e) {
      print("Erreur isFavoriteDevice: $e");
      return false;
    }
  }

  /// Ajouter un device aux favoris
  static Future<void> addFavoriteDevice(String deviceId, String deviceName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favorites = prefs.getStringList(_favoritesKey) ?? [];

      if (!favorites.contains(deviceId)) {
        favorites.add(deviceId);
        await prefs.setStringList(_favoritesKey, favorites);
        print("Device $deviceName ajouté aux favoris");
      }
    } catch (e) {
      print("Erreur addFavoriteDevice: $e");
    }
  }

  /// Retirer un device des favoris
  static Future<void> removeFavoriteDevice(String deviceId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favorites = prefs.getStringList(_favoritesKey) ?? [];

      if (favorites.remove(deviceId)) {
        await prefs.setStringList(_favoritesKey, favorites);
        print("Device retiré des favoris");
      }
    } catch (e) {
      print("Erreur removeFavoriteDevice: $e");
    }
  }

  /// Obtenir la liste des favoris
  static Future<List<String>> getFavoriteDevices() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList(_favoritesKey) ?? [];
    } catch (e) {
      print("Erreur getFavoriteDevices: $e");
      return [];
    }
  }

  // =================== MÉTHODES HISTORIQUE ===================

  /// Charger l'historique complet
  static Future<List<DeviceHistoryEntry>> loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getStringList(_historyKey) ?? [];

      return historyJson
          .map((json) => DeviceHistoryEntry.fromJson(jsonDecode(json)))
          .toList()
        ..sort((a, b) => b.lastConnected.compareTo(a.lastConnected));
    } catch (e) {
      print("Erreur loadHistory: $e");
      return [];
    }
  }

  /// Obtenir l'historique pour une position spécifique
  static Future<List<DeviceHistoryEntry>> getHistoryForPosition(ArmSide position) async {
    try {
      final allHistory = await loadHistory();
      return allHistory
          .where((entry) => entry.lastPosition == position)
          .toList()
        ..sort((a, b) => b.lastConnected.compareTo(a.lastConnected));
    } catch (e) {
      print("Erreur getHistoryForPosition: $e");
      return [];
    }
  }

  /// Obtenir le dernier dispositif pour une position
  static Future<DeviceHistoryEntry?> getLastDeviceForPosition(ArmSide position) async {
    try {
      final history = await loadHistory();
      return history.firstWhere(
            (entry) => entry.lastPosition == position,
      );
    } catch (_) {
      return null;
    }
  }

  /// Sauvegarder une connexion
  static Future<void> saveConnection(
      DiscoveredDevice device,
      ArmSide position,
      ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      var history = await loadHistory();

      // Vérifier si c'est un favori (depuis la nouvelle liste de favoris)
      final isFavorite = await isFavoriteDevice(device.id);

      // Chercher si le dispositif existe déjà
      final existingIndex = history.indexWhere((entry) => entry.id == device.id);

      if (existingIndex != -1) {
        // Mettre à jour l'entrée existante
        final existing = history[existingIndex];
        history[existingIndex] = DeviceHistoryEntry(
          id: existing.id,
          name: device.name.isNotEmpty ? device.name : existing.name,
          lastConnected: DateTime.now(),
          lastPosition: position,
          serviceUuids: device.serviceUuids.map((e) => e.toString()).toList(),
          lastRssi: device.rssi,
          isFavorite: isFavorite, // Synchroniser avec la liste de favoris
          connectionCount: existing.connectionCount + 1,
        );
      } else {
        // Ajouter une nouvelle entrée
        history.add(DeviceHistoryEntry(
          id: device.id,
          name: device.name.isNotEmpty ? device.name : "PineTime",
          lastConnected: DateTime.now(),
          lastPosition: position,
          serviceUuids: device.serviceUuids.map((e) => e.toString()).toList(),
          lastRssi: device.rssi,
          isFavorite: isFavorite,
          connectionCount: 1,
        ));
      }

      // Limiter l'historique à 50 dispositifs
      if (history.length > 50) {
        // Garder les favoris et les 50 plus récents
        final favorites = history.where((e) => e.isFavorite).toList();
        final nonFavorites = history.where((e) => !e.isFavorite).toList()
          ..sort((a, b) => b.lastConnected.compareTo(a.lastConnected));

        history = [...favorites, ...nonFavorites.take(50 - favorites.length)];
      }

      // Sauvegarder
      await prefs.setStringList(
        _historyKey,
        history.map((e) => jsonEncode(e.toJson())).toList(),
      );
    } catch (e) {
      print("Erreur saveConnection: $e");
    }
  }

  /// Basculer favori (méthode legacy pour compatibilité)
  static Future<void> toggleFavorite(String deviceId) async {
    try {
      final isFavorite = await isFavoriteDevice(deviceId);

      if (isFavorite) {
        await removeFavoriteDevice(deviceId);
      } else {
        // Récupérer le nom depuis l'historique
        final history = await loadHistory();
        final entry = history.firstWhere(
              (e) => e.id == deviceId,
          orElse: () => DeviceHistoryEntry(
            id: deviceId,
            name: "PineTime",
            lastConnected: DateTime.now(),
            lastPosition: ArmSide.left,
            serviceUuids: [],
            lastRssi: null,
          ),
        );
        await addFavoriteDevice(deviceId, entry.name);
      }

      // Synchroniser l'historique
      await _syncHistoryWithFavorites();
    } catch (e) {
      print("Erreur toggleFavorite: $e");
    }
  }

  /// Synchroniser l'historique avec la liste de favoris
  static Future<void> _syncHistoryWithFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final history = await loadHistory();
      final favorites = await getFavoriteDevices();

      // Mettre à jour le flag isFavorite dans l'historique
      final updatedHistory = history.map((entry) {
        return DeviceHistoryEntry(
          id: entry.id,
          name: entry.name,
          lastConnected: entry.lastConnected,
          lastPosition: entry.lastPosition,
          serviceUuids: entry.serviceUuids,
          lastRssi: entry.lastRssi,
          isFavorite: favorites.contains(entry.id),
          connectionCount: entry.connectionCount,
        );
      }).toList();

      await prefs.setStringList(
        _historyKey,
        updatedHistory.map((e) => jsonEncode(e.toJson())).toList(),
      );
    } catch (e) {
      print("Erreur _syncHistoryWithFavorites: $e");
    }
  }

  /// Nettoyer l'historique
  static Future<void> clearHistory({bool keepFavorites = true}) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (keepFavorites) {
        final history = await loadHistory();
        final favorites = history.where((e) => e.isFavorite).toList();

        await prefs.setStringList(
          _historyKey,
          favorites.map((e) => jsonEncode(e.toJson())).toList(),
        );
      } else {
        await prefs.remove(_historyKey);
        await prefs.remove(_favoritesKey); // Aussi nettoyer les favoris
      }
    } catch (e) {
      print("Erreur clearHistory: $e");
    }
  }

  /// Supprimer un device spécifique de l'historique
  static Future<void> removeDeviceFromHistory(String deviceId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final history = await loadHistory();

      final updatedHistory = history.where((e) => e.id != deviceId).toList();

      await prefs.setStringList(
        _historyKey,
        updatedHistory.map((e) => jsonEncode(e.toJson())).toList(),
      );

      // Aussi le retirer des favoris
      await removeFavoriteDevice(deviceId);
    } catch (e) {
      print("Erreur removeDeviceFromHistory: $e");
    }
  }

  /// Obtenir les statistiques de l'historique
  static Future<Map<String, dynamic>> getHistoryStats() async {
    try {
      final history = await loadHistory();
      final favorites = history.where((e) => e.isFavorite).toList();

      return {
        'totalDevices': history.length,
        'favoriteDevices': favorites.length,
        'totalConnections': history.fold<int>(0, (sum, e) => sum + e.connectionCount),
        'leftArmDevices': history.where((e) => e.lastPosition == ArmSide.left).length,
        'rightArmDevices': history.where((e) => e.lastPosition == ArmSide.right).length,
      };
    } catch (e) {
      print("Erreur getHistoryStats: $e");
      return {};
    }
  }
}
