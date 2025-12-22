import 'package:flutter/material.dart';
import 'package:flutter_bloc_app_template/generated/l10n.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app_template/bloc/infinitime/dual_infinitime_bloc.dart';
import 'package:flutter_bloc_app_template/bloc/infinitime/dual_infinitime_state.dart';
import 'package:flutter_bloc_app_template/models/arm_side.dart';
import 'package:infinitime_dfu_library/infinitime_dfu_library.dart';

enum WatchConnectionState {
  neverConnected,
  connected,
  connecting,
  disconnected,
}

class WatchButtonCardPlus extends StatelessWidget {
  final IconData icon;
  final String label;
  final ArmSide side;
  final String subStatus;
  final int? batteryLevel;
  final Color? backgroundColor;
  final Color? borderColor;
  final WatchConnectionState connectionState;
  final VoidCallback? onTapConnect;
  final VoidCallback? onReconnect;
  final VoidCallback? onDisconnect;
  final VoidCallback? onForget;
  final VoidCallback? onUpdateWatchface;
  final VoidCallback? onRequestDeviceInfo;
  final VoidCallback? onUpdateFirmware;

  // Nouvelles propriétés pour les données en temps réel
  final int? heartRate;
  final int? steps;
  final List<int>? motionData; // [x, y, z]
  final Map<String, String>? deviceInfo; // firmware, model, etc.
  final int? rssi; // Signal strength

  const WatchButtonCardPlus({
    super.key,
    required this.icon,
    required this.label,
    required this.subStatus,
    required this.connectionState,
    this.batteryLevel,
    this.backgroundColor,
    this.borderColor,
    this.onTapConnect,
    this.onReconnect,
    this.onDisconnect,
    this.onForget,
    required this.side,
    this.onUpdateWatchface,
    this.onRequestDeviceInfo,
    this.heartRate,
    this.steps,
    this.motionData,
    this.deviceInfo,
    this.rssi,
    this.onUpdateFirmware,
  });

  // ========= BATTERY HELPERS =========

  Color _batteryVisualColor(int? level) {
    if (level == null) return Colors.grey;
    if (level < 20) return Colors.red.shade600;
    if (level < 50) return Colors.orange.shade600;
    if (level < 80) return Colors.green.shade400;
    return Colors.green;
  }

  String _batteryStatusLabel(int level) {
    if (level >= 80) return "Excellente";
    if (level >= 50) return "Bonne";
    if (level >= 20) return "Faible";
    return "Critique";
  }

  IconData _batteryStatusIcon(int level) {
    if (level >= 80) return Icons.battery_full_outlined;
    if (level >= 50) return Icons.battery_6_bar_outlined;
    if (level >= 20) return Icons.battery_3_bar_outlined;
    return Icons.battery_alert;
  }

  String _batteryLabelWithPercent(int? level) {
    if (level == null) return "--";
    return "$level% (${_batteryStatusLabel(level)})";
  }

  String _buildSubStatusText() {
    if (subStatus.isNotEmpty) return subStatus;
    return connectionState == WatchConnectionState.neverConnected
        ? "Aucune montre appairée"
        : "";
  }

  Color _statusColor() {
    switch (connectionState) {
      case WatchConnectionState.connected:
        return Colors.green;
      case WatchConnectionState.connecting:
        return Colors.orange;
      case WatchConnectionState.disconnected:
        return Colors.red;
      case WatchConnectionState.neverConnected:
      default:
        return Colors.grey;
    }
  }

  Widget _buildConnectionStatusRow() {
    String label;
    Color color;

    switch (connectionState) {
      case WatchConnectionState.connected:
        label = "Connectée";
        color = _statusColor();
        break;
      case WatchConnectionState.connecting:
        label = "Connexion...";
        color = _statusColor();
        break;
      case WatchConnectionState.disconnected:
        label = "Déconnectée";
        color = _statusColor();
        break;
      case WatchConnectionState.neverConnected:
      default:
        label = "Jamais connectée";
        color = _statusColor();
        break;
    }

    return Text(
      label,
      style: TextStyle(
        fontSize: 9,
        fontWeight: FontWeight.w500,
        color: color,
      ),
    );
  }

  String _getSideDisplayName(ArmSide side) {
    switch (side) {
      case ArmSide.left:
        return 'Gauche';
      case ArmSide.right:
        return 'Droite';
      default:
        return 'Inconnu';
    }
  }

  // ========= UI COMPONENTS =========

  Widget _infoRow(IconData icon, String text, {Color? iconColor}) {
    final color = iconColor ?? Colors.grey;
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  // Comparaison correcte des données motion (listes)

  Map<String, String>? _extractDeviceInfo(ArmDeviceState arm) {
    if (arm.log.isNotEmpty) {
      final info = <String, String>{};
      final lines = arm.log.split('\n');
      for (final line in lines) {
        if (line.contains("Firmware:")) {
          info['firmware'] = line.split("Firmware:").last.trim();
        } else if (line.contains("Model:")) {
          info['model'] = line.split("Model:").last.trim();
        } else if (line.contains("Manufacturer:")) {
          info['manufacturer'] = line.split("Manufacturer:").last.trim();
        } else if (line.contains("Hardware:")) {
          info['hardware'] = line.split("Hardware:").last.trim();
        }
      }
      return info.isNotEmpty ? info : null;
    }
    return null;
  }

  Widget _buildConnectedSheet(BuildContext context) {
    return BlocBuilder<DualInfiniTimeBloc, DualInfiniTimeState>(
      buildWhen: (previous, current) {
        try {
          final shouldRebuild = side == ArmSide.left
              ? previous.left != current.left
              : previous.right != current.right;

          // Log pour déboguer
          if (shouldRebuild) {
            final prevMotion = side == ArmSide.left
                ? previous.left.motion
                : previous.right.motion;
            final currMotion = side == ArmSide.left
                ? current.left.motion
                : current.right.motion;
            print(
                '[WatchCard] Rebuild triggered for ${side.name}: prevMotion=$prevMotion, currMotion=$currMotion');
          }

          return shouldRebuild;
        } catch (e) {
          print('[WatchCard] buildWhen error: $e');
          return true;
        }
      },
      builder: (context, dualState) {
        final ArmDeviceState arm =
            side == ArmSide.left ? dualState.left : dualState.right;

        // Données existantes
        final int currentBatteryLevel = arm.battery ?? batteryLevel ?? 0;
        final int? currentSteps = arm.steps ?? steps;
        final List<int>? currentMotionData = arm.motion ?? motionData;
        final Map<String, String>? currentDeviceInfo = _extractDeviceInfo(arm);
        final bool isConnected = arm.connected ??
            (connectionState == WatchConnectionState.connected);

        // Gestion sécurisée des données firmware
        FirmwareInfo? selectedFirmware;
        try {
          // Vérifiez si la méthode existe avant de l'appeler
          if (dualState is DualInfiniTimeState) {
            selectedFirmware = dualState.selectedFirmwares[side];
          }
        } catch (e) {
          print("Erreur récupération firmware sélectionné: $e");
          selectedFirmware = null;
        }

        final bool isDfuRunning = arm.dfuRunning ?? false;
        final int dfuProgress = arm.dfuPercent ?? 0;
        final String dfuPhase = arm.dfuPhase ?? "";

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Header
              Row(
                children: [
                  Icon(Icons.watch_off_outlined,
                      size: 32,
                      color: isConnected
                          ? Colors.green.shade600
                          : Colors.red.shade600),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label.isNotEmpty
                              ? "$label - (${_getSideDisplayName(side)})"
                              : "PineTime",
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: isConnected
                                ? Colors.green.shade100
                                : Colors.red.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            isConnected
                                ? "Connectée ⚡ TEMPS RÉEL"
                                : "Déconnectée",
                            style: TextStyle(
                              fontSize: 11,
                              color: isConnected ? Colors.green : Colors.red,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Section Métriques
              if (isConnected) ...[
                Container(
                  key: ValueKey('metrics_section_$side'),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color:
                          Theme.of(context).primaryColor.withValues(alpha: 0.5),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.data_saver_off_sharp,
                              size: 20,
                              color: Colors.orange.shade600
                                  .withValues(alpha: 0.5)),
                          const SizedBox(width: 8),
                          Text(S.of(context).metrics),
                          const Spacer(),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.green.withOpacity(0.5),
                                  blurRadius: 4,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      GridView.count(
                        key: ValueKey('metrics_grid_$side'),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        childAspectRatio: 2.5,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        children: [
                          _metricCard(
                            _batteryStatusIcon(currentBatteryLevel),
                            "Batterie",
                            _batteryLabelWithPercent(currentBatteryLevel),
                            _batteryVisualColor(currentBatteryLevel),
                            key: ValueKey('battery_card_$side'),
                          ),
                          _metricCard(
                            Icons.directions_walk,
                            "Pas",
                            "${currentSteps ?? '--'}",
                            Colors.blue.shade400,
                            key: ValueKey('steps_card_$side'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Section Progression DFU
                if (isDfuRunning) ...[
                  Container(
                    key: ValueKey('dfu_progress_$dfuProgress'),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.purple.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border:
                          Border.all(color: Colors.purple.shade300, width: 2),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.purple.shade600,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.system_update_outlined,
                                  size: 16, color: Colors.white),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Mise à jour firmware ${_getSideDisplayName(side)}", // CORRECTION 6
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.purple.shade800,
                                    ),
                                  ),
                                  Text(
                                    "Progression: $dfuProgress% - Actif: $isDfuRunning",
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.purple.shade600,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                "$dfuProgress%",
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Barre de progrès
                        Stack(
                          children: [
                            Container(
                              height: 8,
                              decoration: BoxDecoration(
                                color: Colors.purple.shade100,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: MediaQuery.of(context).size.width *
                                  (dfuProgress / 100),
                              height: 8,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.purple.shade400,
                                    Colors.purple.shade600
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Message de phase
                        Row(
                          children: [
                            Icon(Icons.info_outline,
                                size: 14, color: Colors.grey.shade600),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                dfuPhase.isNotEmpty
                                    ? dfuPhase
                                    : "Mise à jour en cours...",
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade700,
                                  fontStyle: FontStyle.italic,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),

                        // Bouton d'annulation
                        if (dfuProgress < 100) ...[
                          Center(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                // CORRECTION 7: Gestion sécurisée de l'annulation
                                try {
                                  context
                                      .read<DualInfiniTimeBloc>()
                                      .abortSystemFirmwareUpdate(side);
                                } catch (e) {
                                  print(
                                      "Méthode abortSystemFirmwareUpdate non trouvée: $e");
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content:
                                            Text("Impossible d'annuler: $e")),
                                  );
                                }
                              },
                              icon: const Icon(Icons.stop, size: 16),
                              label: const Text("Annuler DFU",
                                  style: TextStyle(fontSize: 12)),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red.shade600,
                                side: BorderSide(color: Colors.red.shade300),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Graphique accéléromètre
                if (currentMotionData != null &&
                    currentMotionData.length >= 3) ...[
                  Container(
                    key: ValueKey('accelerometer_section_$side'),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Theme.of(context)
                            .primaryColor
                            .withValues(alpha: 0.5),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.sensors,
                                size: 20, color: Colors.purple.shade600),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                "Accéléromètre",
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        AccelerometerVisualizer(
                          key: ValueKey('accelerometer_visualizer_$side'),
                          motionData: currentMotionData,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Informations système
                if (currentDeviceInfo != null &&
                    currentDeviceInfo.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Theme.of(context).primaryColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline,
                                size: 20, color: Colors.grey.shade600),
                            const SizedBox(width: 8),
                            const Text("Informations système"),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (currentDeviceInfo['firmware'] != null)
                          _buildInfoRow(
                              S.of(context).firmware, currentDeviceInfo['firmware']!),
                        if (currentDeviceInfo['model'] != null)
                          _buildInfoRow("Modèle", currentDeviceInfo['model']!),
                        if (currentDeviceInfo['manufacturer'] != null)
                          _buildInfoRow(
                              "Fabricant", currentDeviceInfo['manufacturer']!),
                        if (currentDeviceInfo['hardware'] != null)
                          _buildInfoRow(
                              "Hardware", currentDeviceInfo['hardware']!),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ] else ...[
                // Montre déconnectée
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_outlined, color: Colors.orange.shade600),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "Cette montre est déconnectée. Reconnectez-la pour voir les données en temps réel.",
                          style: TextStyle(color: Colors.orange.shade700),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Boutons Firmware et Watchface
              Row(
                children: [
                  if (onUpdateFirmware != null) ...[
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: isDfuRunning ? null : onUpdateFirmware,
                        icon: const Icon(Icons.memory_outlined),
                        label: Text(S.of(context).firmware),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(0, 48),
                          backgroundColor: isDfuRunning
                              ? Colors.grey.shade400
                              : Colors.purple.shade600,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                ],
              ),
              const SizedBox(height: 12),

              // Actions principales
              Row(
                children: [
                  if (isConnected) ...[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          onDisconnect?.call();
                        },
                        icon: const Icon(Icons.link_off),
                        label: Text(S.of(context).disconnect),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.orange.shade600,
                          side: BorderSide(color: Colors.orange.shade300),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ] else ...[
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          onReconnect?.call();
                        },
                        icon: const Icon(Icons.refresh_outlined),
                        label: Text(S.of(context).reconnect),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        onForget?.call();
                      },
                      icon: const Icon(Icons.delete_outline),
                      label: const Text("Oublier"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red.shade600,
                        side: BorderSide(color: Colors.red.shade300),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Bouton fermer
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    S.of(context).close,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _metricCard(IconData icon, String label, String value, Color color,
      {Key? key}) {
    return Container(
      key: key,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 30,
            color: color,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                  ),
                ),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value ?? '-'), // Gestion du null
        ],
      ),
    );
  }

  Widget _buildDisconnectedSheet(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Icon(Icons.link_off, size: 32, color: Colors.orange.shade600),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label.isNotEmpty ? label : "PineTime",
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        "Déconnectée",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _infoRow(
            Icons.warning,
            "Connexion perdue",
            iconColor: Colors.orange,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              onReconnect?.call();
            },
            icon: const Icon(Icons.refresh),
            label: Text(S.of(context).reconnect),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
              backgroundColor: Colors.green.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              onForget?.call();
            },
            icon: const Icon(Icons.delete_outline),
            label: const Text("Oublier cette montre"),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
              foregroundColor: Colors.red.shade600,
              side: BorderSide(color: Colors.red.shade300),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNeverConnectedSheet(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary.withOpacity(0.8);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 12),
          Icon(Icons.bluetooth_audio, size: 60, color: primaryColor),
          const SizedBox(height: 20),
          Text(
            "Connectez votre PineTime",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            "Vous pouvez scanner pour trouver et appairer une PineTime disponible à proximité.",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              onTapConnect?.call();
            },
            icon: const Icon(Icons.search),
            label: const Text("Scanner une PineTime"),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  // ========= SHEETS LAUNCHER =========

  void _showSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        switch (connectionState) {
          case WatchConnectionState.connected:
            return _buildConnectedSheet(context);
          case WatchConnectionState.disconnected:
            return _buildDisconnectedSheet(context);
          case WatchConnectionState.neverConnected:
          default:
            return _buildNeverConnectedSheet(context);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return SizedBox(
      width: screenWidth,
      height: 110,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showSheet(context),
          borderRadius: BorderRadius.circular(20),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: backgroundColor ??
                  Theme.of(context).colorScheme.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
                width: 1.5,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.4),
                              width: 1.5,
                            ),
                          ),
                          child: Icon(
                            icon,
                            color: Colors.blueGrey.shade700,
                            size: 26,
                          ),
                        ),
                        Positioned(
                          bottom: -1,
                          right: 4,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: _statusColor(),
                              shape: BoxShape.circle,
                              border:
                                  Border.all(color: Colors.white, width: 1.5),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            label,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          _buildConnectionStatusRow(),
                          Text(
                            _buildSubStatusText(),
                            style: TextStyle(
                              fontSize: 9,
                              color: Colors.grey.shade700,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Widget pour visualiser l'accéléromètre en temps réel - Points qui bougent verticalement
class AccelerometerVisualizer extends StatefulWidget {
  final List<int> motionData;

  const AccelerometerVisualizer({
    super.key,
    required this.motionData,
  });

  @override
  State<AccelerometerVisualizer> createState() =>
      _AccelerometerVisualizerState();
}

class _AccelerometerVisualizerState extends State<AccelerometerVisualizer>
    with TickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void didUpdateWidget(AccelerometerVisualizer oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Animation douce quand les données changent
    bool dataChanged = false;
    if (widget.motionData.length != oldWidget.motionData.length) {
      dataChanged = true;
    } else {
      for (int i = 0; i < widget.motionData.length; i++) {
        if (widget.motionData[i] != oldWidget.motionData[i]) {
          dataChanged = true;
          break;
        }
      }
    }

    if (dataChanged) {
      _animationController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Convertit une valeur d'accéléromètre (-255 à 255) en position verticale (0 à 1)
  double _normalizeValue(int value) {
    return ((value + 255) / 510).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.motionData.length < 3) {
      return const SizedBox(
        height: 180,
        child: Center(
          child: Text(
            "En attente de données...",
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Column(
          children: [
            // Légende
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _legendItem(
                      "X - ${widget.motionData[0]}", Colors.red.shade400),
                  _legendItem(
                      "Y - ${widget.motionData[1]}", Colors.green.shade400),
                  _legendItem(
                      "Z - ${widget.motionData[2]}", Colors.blue.shade400),
                ],
              ),
            ),

            // Zone de visualisation
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                //color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  // Axe X - Rouge
                  Expanded(
                    child: _buildAxisColumn(
                      widget.motionData[0],
                      Colors.red.shade400,
                      "X",
                    ),
                  ),
                  Container(
                    width: 1,
                    color: Colors.grey.shade300,
                  ),
                  // Axe Y - Vert
                  Expanded(
                    child: _buildAxisColumn(
                      widget.motionData[1],
                      Colors.green.shade400,
                      "Y",
                    ),
                  ),
                  Container(
                    width: 1,
                    color: Colors.grey.shade300,
                  ),
                  // Axe Z - Bleu
                  Expanded(
                    child: _buildAxisColumn(
                      widget.motionData[2],
                      Colors.blue.shade400,
                      "Z",
                    ),
                  ),
                ],
              ),
            ),

            // Échelle de référence
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                "Échelle: -255 (bas) à +255 (haut)",
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAxisColumn(int value, Color color, String label) {
    double normalizedPosition = _normalizeValue(value);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Stack(
        children: [
          // Ligne centrale de référence (zéro)
          Positioned(
            left: 0,
            right: 0,
            top: 52, // Milieu de la hauteur (120-16)/2
            child: Container(
              height: 1,
              color: Colors.grey.shade400,
            ),
          ),

          // Point mobile
          AnimatedPositioned(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOutCubic,
            left: 0,
            right: 0,
            top: (1 - normalizedPosition) * (120 - 32) + 8,
            // Inverse car 0 = haut
            child: Center(
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.4),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Marqueurs d'échelle
          Positioned(
            left: 0,
            top: 8,
            child: Text(
              "+255",
              style: TextStyle(
                fontSize: 8,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Positioned(
            left: 0,
            bottom: 8,
            child: Text(
              "-255",
              style: TextStyle(
                fontSize: 8,
                color: Colors.grey.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendItem(String label, Color color) {
    return Flexible(
      // Ajouté pour éviter les débordements
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4), // Réduit l'espacement
          Flexible(
            child: Text(
              label, // Supprime "Axe" pour économiser l'espace
              style: TextStyle(
                fontSize: 10, // Réduit la taille
                fontWeight: FontWeight.w600,
                color: color,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
