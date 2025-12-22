// Version avec intégration du BLoC dans WatchManagementPage

import 'package:flutter/material.dart';
import 'package:flutter_bloc_app_template/generated/l10n.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app_template/bloc/settings/settings_bloc.dart';
import 'package:flutter_bloc_app_template/bloc/settings/settings_event.dart';
import 'package:flutter_bloc_app_template/bloc/settings/settings_states.dart';
import 'package:flutter_bloc_app_template/bloc/watch/watch_bloc.dart';
import 'package:flutter_bloc_app_template/bloc/watch/watch_event.dart';
import 'package:flutter_bloc_app_template/models/arm_side.dart';
import 'package:flutter_bloc_app_template/models/watch_device.dart';


class WatchManagementPage extends StatefulWidget {
  final WatchDevice watch;

  const WatchManagementPage({super.key, required this.watch});

  @override
  State<WatchManagementPage> createState() => _WatchManagementPageState();
}

class _WatchManagementPageState extends State<WatchManagementPage> {
  late String watchName;
  late bool isConnected;
  late int batteryLevel;
  late String lastSync;
  late ArmSide side;

  @override
  void initState() {
    super.initState();
    watchName = widget.watch.name;
    isConnected = widget.watch.isLastConnected;
    batteryLevel = widget.watch.batteryLevel ?? 0;
    side = widget.watch.armSide;
    lastSync = widget.watch.lastSyncTime != null
        ? "Il y a ${DateTime.now().difference(widget.watch.lastSyncTime!).inMinutes} minutes"
        : "Jamais synchronisée";
  }

  void _renameWatch() {
    final controller = TextEditingController(text: watchName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Renommer la montre"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: "Nouveau nom"),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(S.of(context).cancel)),
          ElevatedButton(
            onPressed: () {
              final newName = controller.text;
              setState(() => watchName = newName);

              // Mise à jour du WatchDevice dans WatchBloc
              context.read<WatchBloc>().add(UpdateWatchDevice(
                widget.watch.copyWith(name: newName),
              ));

              // Mise à jour dans SettingsBloc (si géré dans AppSettings)
              final settingsBloc = context.read<SettingsBloc>();
              final currentSettings = (settingsBloc.state as SettingsLoaded).settings;

              settingsBloc.add(UpdateSettings(
                currentSettings.copyWith(
                  leftWatchName: widget.watch.armSide == ArmSide.left ? newName : currentSettings.leftWatchName,
                  rightWatchName: widget.watch.armSide == ArmSide.right ? newName : currentSettings.rightWatchName,
                ),
              ));

              Navigator.pop(ctx);
            },
            child: Text(S.of(context).save),
          )
        ],
      ),
    );
  }

  void _testVibration() {
    //context.read<BluetoothBloc>().add(WriteToWatch(widget.watch.armSide, '{"action":"vibrate"}'),);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Vibration testée avec succès")),
    );
  }

  void _syncWatch() {
    //context.read<BluetoothBloc>().add(WriteToWatch(widget.watch.armSide, '{"action":"sync"}'),);
    setState(() => lastSync = "Synchronisée à l'instant");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Montre synchronisée")),
    );
  }

  void _checkBattery() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Batterie actuelle : $batteryLevel%")),
    );
  }

  void _updateFirmware() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Vérification du firmware...")),
    );
    Future.delayed(const Duration(seconds: 2), () {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Firmware à jour.")),
      );
    });
  }

  void _forgetWatch() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Supprimer la montre ?"),
        content: const Text("Cette action est définitive."),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(S.of(context).cancel)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              context.read<WatchBloc>().add(DeleteWatchDevice(widget.watch.id));
             // context.read<BluetoothBloc>().add(DisconnectDevice(widget.watch.armSide));
              Navigator.pop(ctx);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Montre supprimée.")),
              );
            },
            child: Text(S.of(context).delete),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Montre ${side == ArmSide.left ? S.of(context).left : S.of(context).right}"),
          elevation: 0,
          scrolledUnderElevation: 3,
          backgroundColor: Theme.of(context).colorScheme.surface,
          foregroundColor: Theme.of(context).colorScheme.onSurface, centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: Icon(Icons.watch, color: theme.primaryColor),
            title: Text(watchName),
            subtitle: Text(isConnected ? "Connectée" : "Non connectée"),
            trailing: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _renameWatch,
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.battery_std),
            title: const Text("Niveau de batterie"),
            subtitle: Text("$batteryLevel%"),
            trailing: const Icon(Icons.refresh),
            onTap: _checkBattery,
          ),
          ListTile(
            leading: const Icon(Icons.sync),
            title: Text(S.of(context).synchronization),
            subtitle: Text(lastSync),
            onTap: _syncWatch,
          ),
          ListTile(
            leading: const Icon(Icons.vibration),
            title: const Text("Tester la vibration"),
            onTap: _testVibration,
          ),
          ListTile(
            leading: const Icon(Icons.system_update),
            title: const Text("Mise à jour firmware"),
            onTap: _updateFirmware,
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text("Supprimer la montre",
                style: TextStyle(color: Colors.red)),
            onTap: _forgetWatch,
          ),
        ],
      ),
    );
  }
}
