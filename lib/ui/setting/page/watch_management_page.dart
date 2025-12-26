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
    lastSync = "";
  }

  String _getLastSyncText() {
    if (widget.watch.lastSyncTime != null) {
      return S.of(context).syncedAgo(DateTime.now().difference(widget.watch.lastSyncTime!).inMinutes);
    }
    return S.of(context).neverSynced;
  }

  void _renameWatch() {
    final controller = TextEditingController(text: watchName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(S.of(context).renameWatch),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(labelText: S.of(context).newName),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(S.of(context).cancel)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
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
      SnackBar(content: Text(S.of(context).vibrationTestedSuccessfully)),
    );
  }

  void _syncWatch() {
    //context.read<BluetoothBloc>().add(WriteToWatch(widget.watch.armSide, '{"action":"sync"}'),);
    setState(() => lastSync = S.of(context).syncedJustNow);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(S.of(context).watchSynced)),
    );
  }

  void _checkBattery() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Batterie actuelle : $batteryLevel%")),
    );
  }

  void _updateFirmware() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(S.of(context).checkingFirmware)),
    );
    Future.delayed(const Duration(seconds: 2), () {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context).firmwareUpToDate)),
      );
    });
  }

  void _forgetWatch() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(S.of(context).deleteWatchQuestion),
        content: Text(S.of(context).thisActionIsPermanent),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(S.of(context).cancel)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              context.read<WatchBloc>().add(DeleteWatchDevice(widget.watch.id));
             // context.read<BluetoothBloc>().add(DisconnectDevice(widget.watch.armSide));
              Navigator.pop(ctx);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(S.of(context).watchDeleted)),
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
        title: Text(S.of(context).watchSide(side == ArmSide.left ? S.of(context).left : S.of(context).right)),
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
            subtitle: Text(isConnected ? S.of(context).watchConnected : S.of(context).watchNotConnected),
            trailing: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _renameWatch,
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.battery_std),
            title: Text(S.of(context).batteryLevel),
            subtitle: Text("$batteryLevel%"),
            trailing: const Icon(Icons.refresh),
            onTap: _checkBattery,
          ),
          ListTile(
            leading: const Icon(Icons.sync),
            title: Text(S.of(context).synchronization),
            subtitle: Text(lastSync.isEmpty ? _getLastSyncText() : lastSync),
            onTap: _syncWatch,
          ),
          ListTile(
            leading: const Icon(Icons.vibration),
            title: Text(S.of(context).testVibration),
            onTap: _testVibration,
          ),
          ListTile(
            leading: const Icon(Icons.system_update),
            title: Text(S.of(context).firmwareUpdate),
            onTap: _updateFirmware,
          ),
          ListTile(
            leading: Icon(Icons.delete_forever, color: Theme.of(context).colorScheme.error),
            title: Text(S.of(context).deleteWatch,
                style: TextStyle(color: Theme.of(context).colorScheme.error)),
            onTap: _forgetWatch,
          ),
        ],
      ),
    );
  }
}
