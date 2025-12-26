
import 'package:csv/csv.dart';
import 'package:flutter_bloc_app_template/app/app_database.dart';
import 'package:flutter_bloc_app_template/bloc/device/device.dart';
import 'package:flutter_bloc_app_template/extension/arm_side_extensions.dart';
import 'package:flutter_bloc_app_template/models/arm_side.dart';
import 'package:flutter_bloc_app_template/models/battery_data.dart';
import 'package:flutter_bloc_app_template/models/step_data.dart';
import 'package:flutter_bloc_app_template/models/motion_data.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class DataExporter {
  /// Export par streaming (évite OOM sur gros volumes)
  ///
  /// Charge les données par chunks de 1000 pour éviter de tout charger en RAM.
  /// Peut gérer des millions d'enregistrements sans crash.
  static Future<String> exportSensorDataToCSV(
      ArmSide side,
      String sensorType,
      DeviceBloc bloc, {
      Duration period = const Duration(days: 30),
      int chunkSize = 1000,
      void Function(int processed, int total)? onProgress,
      }) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/sensor_${sensorType}_${DateTime.now().millisecondsSinceEpoch}.csv');
    final sink = file.openWrite();

    try {
      // Écrire l'en-tête
      sink.writeln('Timestamp,Sensor Type,Value,RSSI');

      // Obtenir le nombre total approximatif (optionnel, pour la progress bar)
      int offset = 0;
      int totalProcessed = 0;

      // Charger et écrire par chunks
      while (true) {
        final chunk = await _getSensorDataChunk(
          side,
          sensorType,
          offset: offset,
          limit: chunkSize,
          period: period,
        );

        if (chunk.isEmpty) break;

        // Écrire le chunk directement sans accumuler en mémoire
        for (final data in chunk) {
          String timestamp;
          String value;
          String? rssi;

          // Extraire les valeurs selon le type de donnée
          if (data is BatteryData) {
            timestamp = data.timestamp.toIso8601String();
            value = data.level.toString();
            rssi = data.rssi?.toString();
          }  else if (data is StepData) {
            timestamp = data.timestamp.toIso8601String();
            value = data.stepCount.toString();
            rssi = data.rssi?.toString();
          }  else if (data is MotionData) {
            timestamp = data.timestamp.toIso8601String();
            value = '${data.x},${data.y},${data.z}';
            rssi = data.rssi?.toString();
          } else {
            // Données inconnues, on les ignore
            continue;
          }

          final line = [
            timestamp,
            sensorType,
            value,
            rssi ?? 'N/A',
          ].join(',');
          sink.writeln(line);
        }

        totalProcessed += chunk.length;
        offset += chunkSize;

        // Callback de progression
        onProgress?.call(totalProcessed, totalProcessed);

        // Si le chunk est plus petit que la limite, on a tout lu
        if (chunk.length < chunkSize) break;
      }

      return file.path;
    } finally {
      await sink.flush();
      await sink.close();
    }
  }

  /// Charge un chunk de données directement depuis la DB
  static Future<List<dynamic>> _getSensorDataChunk(
      ArmSide side,
      String sensorType, {
      required int offset,
      required int limit,
      required Duration period,
      }) async {
    final db = AppDatabase.instance;
    final endDate = DateTime.now();
    final startDate = endDate.subtract(period);
    final armSideName = side.displayName.toLowerCase();

    // Utiliser les nouvelles méthodes selon le type de capteur
    switch (sensorType) {
      case 'battery':
        return await db.getDeviceInfo(armSideName,'battery', startDate: startDate, endDate: endDate, limit: limit, offset: offset);
      case 'steps':
        return await db.getDeviceInfo(armSideName,'steps', startDate: startDate, endDate: endDate, limit: limit, offset: offset);
      case 'movement':
        return await db.getMovementData(armSideName, startDate: startDate, endDate: endDate, limit: limit);
      default:
        // Pour types inconnus, retourner liste vide
        return [];
    }
  }

  static Future<String> exportConnectionEventsToCSV(
      ArmSide side,
      DeviceBloc bloc,
      ) async {
    final events = await bloc.getConnectionHistory(
      side,
      period: const Duration(days: 30),
    );

    final rows = [
      ['Timestamp', 'Type', 'Reason', 'Duration (s)', 'Battery', 'RSSI'],
      ...events.map((e) => [
        e.timestamp.toIso8601String(),
        e.typeLabel,
        e.reason ?? 'N/A',
        e.durationSeconds?.toString() ?? 'N/A',
        e.batteryAtConnection?.toString() ?? 'N/A',
        e.rssiAtConnection?.toString() ?? 'N/A',
      ]),
    ];

    final csv = const ListToCsvConverter().convert(rows);
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/connection_${DateTime.now().millisecondsSinceEpoch}.csv');
    await file.writeAsString(csv);

    return file.path;
  }
}

// Usage:
// final path = await DataExporter.exportSensorDataToCSV(
//   ArmSide.left,
//   'battery',
//   bloc,
// );
// print('Exported to: $path');