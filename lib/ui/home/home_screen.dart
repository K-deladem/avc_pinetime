// ui/home/home_screen.dart
// VERSION OPTIMISÉE: Performances améliorées avec SensorData

import 'dart:async';
import 'package:flutter_bloc_app_template/generated/l10n.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app_template/bloc/device/device.dart';
import 'package:flutter_bloc_app_template/bloc/settings/settings_bloc.dart';
import 'package:flutter_bloc_app_template/bloc/settings/settings_states.dart';
import 'package:flutter_bloc_app_template/bloc/watch/watch_bloc.dart';
import 'package:flutter_bloc_app_template/bloc/watch/watch_event.dart';
import 'package:flutter_bloc_app_template/bloc/watch/watch_state.dart';
import 'package:flutter_bloc_app_template/models/app_settings.dart';
import 'package:flutter_bloc_app_template/models/arm_side.dart';
import 'package:flutter_bloc_app_template/models/chart_preferences.dart';
import 'package:flutter_bloc_app_template/models/watch_device.dart';
import 'package:flutter_bloc_app_template/service/chart_data_adapter.dart';
import 'package:flutter_bloc_app_template/service/goal_calculator_service.dart';
import 'package:flutter_bloc_app_template/ui/home/chart/asymmetry_gauge_chart.dart';
import 'package:flutter_bloc_app_template/ui/home/page/new/bluetooth_scan_page_improved.dart';
import 'package:flutter_bloc_app_template/ui/home/widget/info_card.dart';
import 'package:flutter_bloc_app_template/ui/home/widget/carousel_with_chart.dart';
import 'package:flutter_bloc_app_template/ui/home/widget/firmware_selection_dialog.dart';
import 'package:flutter_bloc_app_template/ui/home/widget/profil_header_bar.dart';
import 'package:flutter_bloc_app_template/ui/home/widget/watch_button_card.dart';

import 'chart/asymmetry_heatmap_card.dart';
import 'chart/asymmetry_ratio_chart.dart';
import 'chart/reusable_comparison_chart.dart' as reusable;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Timer? _batteryRefreshTimer;
  Timer? _timeRefreshTimer;

  // Tracking des états de connexion précédents
  bool _previousLeftConnected = false;
  bool _previousRightConnected = false;

  // Keys pour la capture des graphiques pour PDF
  final List<GlobalKey> _chartKeys = [];
  final List<String> _chartTitles = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }

  /// Enveloppe un graphique avec RepaintBoundary pour permettre la capture
  Widget _wrapChartForPdf(Widget chart, String title) {
    final key = GlobalKey();
    _chartKeys.add(key);
    _chartTitles.add(title);

    return RepaintBoundary(
      key: key,
      child: chart,
    );
  }

  /// Réinitialise les keys de graphiques (utile si la config change)
  void _resetChartKeys() {
    _chartKeys.clear();
    _chartTitles.clear();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  @override
  void dispose() {
    _batteryRefreshTimer?.cancel();
    _timeRefreshTimer?.cancel();
    super.dispose();
  }

  // =================== INITIALISATION ===================

  void _initializeApp() {
    _startBatteryRefreshTimer();
    _startTimeRefreshTimer();

    // Initialiser les états précédents
    final currentState = context.read<DeviceBloc>().state;
    _previousLeftConnected = currentState.left.connected;
    _previousRightConnected = currentState.right.connected;
  }

  void _loadInitialData() {
    // Charger les liaisons sauvegardées
    context.read<DeviceBloc>().add(const LoadBindings());
    context.read<DeviceBloc>().loadAvailableFirmwares();
  }

  // =================== TIMERS ===================

  void _startBatteryRefreshTimer() {
    _batteryRefreshTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => _refreshBatteryLevels(),
    );
  }

  void _startTimeRefreshTimer() {
    _timeRefreshTimer = Timer.periodic(
      const Duration(hours: 1),
      (_) => _syncWatchTime(),
    );
  }

  void _refreshBatteryLevels() {
    final bloc = context.read<DeviceBloc>();
    final state = bloc.state;

    if (state.left.connected) {
      bloc.add(const ReadBattery(ArmSide.left));
    }
    if (state.right.connected) {
      bloc.add(const ReadBattery(ArmSide.right));
    }
  }

  void _syncWatchTime() {
    final bloc = context.read<DeviceBloc>();
    final state = bloc.state;

    if (state.left.connected) {
      bloc.add(const SyncTime(ArmSide.left));
    }
    if (state.right.connected) {
      bloc.add(const SyncTime(ArmSide.right));
    }
  }

  // =================== BUILD ===================

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        _buildConnectionListener(),
        _buildUnbindListener(),
        _buildDataSyncListener(),
      ],
      child: BlocBuilder<SettingsBloc, SettingsState>(
        // Optimisation: ne rebuild que si les settings changent vraiment
        buildWhen: (previous, current) {
          if (previous is! SettingsLoaded || current is! SettingsLoaded) {
            return true;
          }
          // Ne rebuild que si affectedSide, userName ou profileImagePath changent
          return previous.settings.affectedSide !=
                  current.settings.affectedSide ||
              previous.settings.userName != current.settings.userName ||
              previous.settings.profileImagePath !=
                  current.settings.profileImagePath ||
              previous.settings.leftWatchName !=
                  current.settings.leftWatchName ||
              previous.settings.rightWatchName !=
                  current.settings.rightWatchName;
        },
        builder: (context, settingsState) {
          if (settingsState is! SettingsLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          final settings = settingsState.settings;
          final body = _buildScrollView(context, settings);

          if (Theme.of(context).platform == TargetPlatform.iOS) {
            return CupertinoPageScaffold(child: body);
          }

          return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.surface,
            body: body,
          );
        },
      ),
    );
  }

  // =================== LISTENERS ===================

  BlocListener<DeviceBloc, DeviceState>
      _buildConnectionListener() {
    return BlocListener<DeviceBloc, DeviceState>(
      listenWhen: (previous, current) =>
          previous.left.connected != current.left.connected ||
          previous.right.connected != current.right.connected,
      listener: (context, state) {
        _handleConnectionChanges(state);
      },
    );
  }

  BlocListener<DeviceBloc, DeviceState> _buildUnbindListener() {
    return BlocListener<DeviceBloc, DeviceState>(
      listenWhen: (previous, current) =>
          (previous.left.deviceId != null && current.left.deviceId == null) ||
          (previous.right.deviceId != null && current.right.deviceId == null),
      listener: (context, state) {
        if (kDebugMode) {
          print(
              'UNBIND détecté - Left: ${state.left.deviceId}, Right: ${state.right.deviceId}');
        }

        // Note: Pas besoin de setState ici car les BlocBuilder vont se mettre à jour automatiquement
        // setState retiré pour éviter les rafraîchissements brusques
      },
    );
  }

  BlocListener<DeviceBloc, DeviceState>
      _buildDataSyncListener() {
    return BlocListener<DeviceBloc, DeviceState>(
      listenWhen: (previous, current) =>
          previous.left.battery != current.left.battery ||
          previous.left.steps != current.left.steps ||
          previous.right.battery != current.right.battery ||
          previous.right.steps != current.right.steps,
      listener: (context, state) {
        // Les données sont automatiquement enregistrées en BD par le bloc
      },
    );
  }

  void _handleConnectionChanges(DeviceState state) {
    final l10n = S.of(context);

    // Bras gauche
    if (state.left.connected && !_previousLeftConnected) {
      _showSuccessMessage(l10n.leftWatchConnected);
    } else if (!state.left.connected && _previousLeftConnected) {
      _showErrorMessage(l10n.leftWatchDisconnected);
    }

    // Bras droit
    if (state.right.connected && !_previousRightConnected) {
      _showSuccessMessage(l10n.rightWatchConnected);
    } else if (!state.right.connected && _previousRightConnected) {
      _showErrorMessage(l10n.rightWatchDisconnected);
    }

    _previousLeftConnected = state.left.connected;
    _previousRightConnected = state.right.connected;
  }

  // =================== UI BUILDERS ===================

  Widget _buildScrollView(BuildContext context, AppSettings settings) {
    return BlocBuilder<WatchBloc, WatchState>(
      builder: (context, watchState) {
        WatchDevice? leftWatch;
        WatchDevice? rightWatch;

        if (watchState is WatchLoaded) {
          for (final device in watchState.devices) {
            if (device.armSide == ArmSide.left) leftWatch = device;
            if (device.armSide == ArmSide.right) rightWatch = device;
          }
        }

        return CustomScrollView(
          slivers: [
            ProfileHeader(),
            SliverList(
              delegate: SliverChildListDelegate([
                _buildInfoCard(context),
                _buildWatchButtonsRow(context, settings, leftWatch, rightWatch),
              ]),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    return BlocBuilder<DeviceBloc, DeviceState>(
      // Optimisation: ne rebuild les graphiques que lors de changements significatifs
      buildWhen: (previous, current) {
        // Ne pas rebuild pour chaque petit changement
        // Les graphiques chargeront leurs propres données de la BD
        return false; // Les graphiques gèrent leurs propres mises à jour via FutureBuilder
      },
      builder: (context, deviceState) {
        return _buildChartsFromCombinedData(context, deviceState);
      },
    );
  }

  /// Construire les graphiques à partir des données combinées de tous les capteurs
  Widget _buildChartsFromCombinedData(
    BuildContext context,
    DeviceState deviceState,
  ) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      // Optimisation: rebuild si affectedSide, chartPreferences ou goalConfig changent
      buildWhen: (previous, current) {
        if (previous is! SettingsLoaded || current is! SettingsLoaded) {
          return true;
        }
        return previous.settings.affectedSide !=
                current.settings.affectedSide ||
            previous.settings.chartPreferences !=
                current.settings.chartPreferences ||
            previous.settings.goalConfig !=
                current.settings.goalConfig;
      },
      builder: (context, settingsState) {
        // Récupérer le membre atteint depuis les settings
        final affectedSide = settingsState is SettingsLoaded
            ? settingsState.settings.affectedSide
            : ArmSide.left;

        final chartPrefs = settingsState is SettingsLoaded
            ? settingsState.settings.chartPreferences
            : const ChartPreferences();

        final settings = settingsState is SettingsLoaded
            ? settingsState.settings
            : null;

        final adapter = ChartDataAdapter();

        // Calculer l'objectif de manière asynchrone
        // Key pour éviter les recalculs inutiles (optimisation batterie)
        return FutureBuilder<int>(
          key: ValueKey(settings?.goalConfig),
          future: settings != null
              ? GoalCalculatorService().calculateGoalFromSettings(settings)
              : Future.value(80),
          builder: (context, goalSnapshot) {
            final goalValue = goalSnapshot.data?.toDouble();

            // Réinitialiser les keys avant de reconstruire
            _resetChartKeys();

            final l10n = S.of(context);

            return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
          child: InfoCard(
            title: l10n.historicalData,
            subtitle: l10n.infiniTimeSensors,
            description: l10n.sensorTrackingDescription,
            buttonText: l10n.learnMore,
            icon: Icons.assessment_outlined,
            onButtonPressed: () => debugPrint("En savoir plus cliqué"),
            onClosePressed: () => debugPrint("Carte fermée"),
            alternativeWidget: CarouselWithChart(
              carouselItems: [
                // ========== GRAPHIQUE 1 & 2: ASYMÉTRIE MAGNITUDE & AXIS (GAUGE FUSIONNÉ) ==========
                if (chartPrefs.showAsymmetryGauge)
                  _wrapChartForPdf(
                    AsymmetryGaugeChart(
                      title: l10n.asymmetry,
                      icon: Icons.assessment_outlined,
                      magnitudeDataProvider: adapter.getMagnitudeAsymmetryForGauge,
                      axisDataProvider: adapter.getAxisAsymmetryForGauge,
                      unit: 'min',
                      affectedSide: affectedSide,
                      goalValue: goalValue, // Passe l'objectif au graphique
                    ),
                    l10n.asymmetryMagnitudeAndAxis,
                  ),

                // ========== GRAPHIQUE 4: COMPARAISON BATTERIE ==========
                if (chartPrefs.showBatteryComparison)
                  _wrapChartForPdf(
                    reusable.ReusableComparisonChart(
                      title: l10n.batteryLevel,
                      icon: Icons.battery_charging_full_outlined,
                      dataProvider: adapter.getBatteryData,
                      unit: '%',
                      leftColor: Colors.blue,
                      rightColor: Colors.green,
                      defaultMode: reusable.ChartMode.line,
                      showTrendLine: true,
                      fixedMinY: 0,
                      fixedMaxY: 100,
                      affectedSide:
                          affectedSide, // Membre atteint depuis settings
                    ),
                    l10n.batteryLevel,
                  ),

                // ========== GRAPHIQUE 5: ASYMÉTRIE DE MOUVEMENT (RATIO) ==========
                if (chartPrefs.showAsymmetryRatioChart)
                  _wrapChartForPdf(
                    AsymmetryRatioChart(
                      title: l10n.movementAsymmetry,
                      icon: Icons.balance_outlined,
                      affectedSide: affectedSide,
                      goalConfig: settings?.goalConfig,
                    ),
                    l10n.asymmetryMovementRatio,
                  ),

                // ========== GRAPHIQUE 6: HEATMAP MAGNITUDE/AXIS ==========
                if (chartPrefs.showAsymmetryHeatmap)
                  _wrapChartForPdf(
                    SizedBox(
                      height: 400,
                      child: AsymmetryHeatMapCard(
                        title: l10n.balanceGoal,
                        icon: Icons.calendar_month_outlined,
                        targetRatio: goalValue ?? 50.0,
                        goalConfig: settings?.goalConfig, // Passe la config pour objectif quotidien
                        tolerance: 5.0,
                        affectedSide:
                            affectedSide, // Membre atteint depuis settings
                      ),
                    ),
                    l10n.balanceGoalHeatmap,
                  ),

                // ========== GRAPHIQUES BONUS: COMPARAISON PAS ==========
                if (chartPrefs.showStepsComparison)
                  _wrapChartForPdf(
                    reusable.ReusableComparisonChart(
                      title: l10n.stepCount,
                      icon: Icons.directions_walk_outlined,
                      dataProvider: adapter.getStepsData,
                      unit: l10n.steps,
                      leftColor: Colors.blueAccent,
                      rightColor: Colors.greenAccent,
                      defaultMode: reusable.ChartMode.bar,
                      affectedSide:
                          affectedSide, // Membre atteint depuis settings
                    ),
                    l10n.stepCount,
                  ),
              ],
              infoIcon: Icons.assessment_outlined,
              autoPlay: false,
              enableInfiniteScroll: false,
              viewportFraction: 1.0,
              chartKeys: _chartKeys,
              chartTitles: _chartTitles,
            ),
          ),
        );
          },
        );
      },
    );
  }

  // =================== WATCH BUTTONS ===================

  Widget _buildWatchButtonsRow(
    BuildContext context,
    AppSettings settings,
    WatchDevice? leftWatch,
    WatchDevice? rightWatch,
  ) {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 10, top: 10),
            child: BlocBuilder<DeviceBloc, DeviceState>(
              buildWhen: (previous, current) => _shouldRebuildWatchButton(
                previous.left,
                current.left,
              ),
              builder: (context, deviceState) {
                return _buildWatchButton(
                  context,
                  settings.leftWatchName,
                  ArmSide.left,
                  leftWatch,
                  deviceState,
                );
              },
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 10, top: 10),
            child: BlocBuilder<DeviceBloc, DeviceState>(
              buildWhen: (previous, current) => _shouldRebuildWatchButton(
                previous.right,
                current.right,
              ),
              builder: (context, deviceState) {
                return _buildWatchButton(
                  context,
                  settings.rightWatchName,
                  ArmSide.right,
                  rightWatch,
                  deviceState,
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  bool _shouldRebuildWatchButton(
    ArmState previous,
    ArmState current,
  ) {
    return previous.deviceId != current.deviceId ||
        previous.connected != current.connected ||
        previous.battery != current.battery ||
        previous.steps != current.steps ||
        previous.rssi != current.rssi ||
        previous.lastSync != current.lastSync ||
        previous.log != current.log ||
        previous.deviceInfo != current.deviceInfo ||
        previous.dfuPercent != current.dfuPercent ||
        previous.dfuPhase != current.dfuPhase ||
        previous.dfuRunning != current.dfuRunning ||
        !listEquals(previous.motion, current.motion);
  }

  Widget _buildWatchButton(
    BuildContext context,
    String label,
    ArmSide side,
    WatchDevice? watch,
    DeviceState deviceState,
  ) {
    final arm = side == ArmSide.left ? deviceState.left : deviceState.right;

    return WatchButtonCardPlus(
      icon: Icons.watch,
      label: label,
      subStatus: _formatSyncTime(arm.lastSync),
      batteryLevel: arm.battery ?? 0,
      connectionState: _resolveConnectionStateFromDual(arm),
      steps: arm.steps,
      motionData: arm.motion,
      rssi: arm.rssi,
      side: side,
      deviceInfo: _extractDeviceInfo(arm),
      onTapConnect: () => _connectToWatch(side),
      onDisconnect: () => _disconnectWatch(side, watch),
      onReconnect: () => _reconnectWatch(side, watch),
      onForget: () => _forgetWatch(side, watch),
      onUpdateWatchface: () => _showWatchfaceUpdateDialog(side),
      onRequestDeviceInfo: () => _requestDeviceInfo(side),
      onUpdateFirmware: () => _showFirmwareOptions(side),
    );
  }

  // =================== ACTIONS DE MONTRES ===================

  Future<void> _connectToWatch(ArmSide position) async {
    try {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ImprovedBluetoothScanPage(position: position),
        ),
      );

      if (!mounted) return;

      if (result != null && result['verified'] == true) {
        if (kDebugMode) print('Connection successful for $position');
        _showSuccessMessage(S.of(context).connectionSuccessFor(position.name));
      }
    } catch (e) {
      if (kDebugMode) print('Error in connecting to watch: $e');
      if (!mounted) return;
      _showErrorMessage(S.of(context).connectionError(e.toString()));
    }
  }

  void _disconnectWatch(ArmSide position, WatchDevice? _) {
    context
        .read<DeviceBloc>()
        .add(DisconnectDevice(position));
    _showSuccessMessage(S.of(context).disconnectionOf(position.name));
  }

  void _reconnectWatch(ArmSide position, WatchDevice? _) {
    context.read<DeviceBloc>().add(ConnectDevice(position));
    _showSuccessMessage(S.of(context).reconnectionInProgressFor(position.name));
  }

  void _forgetWatch(ArmSide position, WatchDevice? watch) {
    final l10n = S.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.forgetWatchQuestion(position.name)),
        content: Text(l10n.forgetWatchDescription),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _performForgetWatch(position, watch);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.forget),
          ),
        ],
      ),
    );
  }

  Future<void> _performForgetWatch(ArmSide position, WatchDevice? watch) async {
    final l10n = S.of(context);
    try {
      // Feedback immédiat
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              ),
              const SizedBox(width: 12),
              Text(l10n.deletingWatch(position.name)),
            ],
          ),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.orange,
        ),
      );

      // Debug
      final currentState = context.read<DeviceBloc>().state;
      final currentArm =
          position == ArmSide.left ? currentState.left : currentState.right;

      if (kDebugMode) {
        print("=== DEBUG FORGET WATCH ===");
        print("Position: ${position.name}");
        print("Device ID avant: ${currentArm.deviceId}");
        print("Connected avant: ${currentArm.connected}");
      }

      // Supprimer du WatchBloc
      if (watch != null) {
        context.read<WatchBloc>().add(DeleteWatchDevice(watch.id));
      }

      // Unbind du DeviceBloc
      context.read<DeviceBloc>().add(UnbindDevice(position));

      // Attendre la propagation
      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;

      // Vérifier le résultat
      final newState = context.read<DeviceBloc>().state;
      final newArm = position == ArmSide.left ? newState.left : newState.right;

      if (kDebugMode) {
        print("Device ID après: ${newArm.deviceId}");
        print("=========================");
      }

      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      if (newArm.deviceId == null) {
        _showSuccessMessage(l10n.watchForgottenSuccessfully(position.name));

        // Forcer un rebuild
        if (mounted) {
          setState(() {});
        }
      } else {
        _showErrorMessage(l10n.errorForgettingWatch(position.name));
      }
    } catch (e) {
      if (kDebugMode) print("Erreur lors de l'oubli de la montre: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      _showErrorMessage(S.of(context).errorLabel(e.toString()));
    }
  }

  void _showFirmwareOptions(ArmSide side) {
    final bloc = context.read<DeviceBloc>();

    if (bloc.availableFirmwares.isEmpty && !bloc.isLoadingFirmwares) {
      bloc.loadAvailableFirmwares();
    }

    showFirmwareUpdateDialog(context, side);
  }

  void showFirmwareUpdateDialog(BuildContext context, ArmSide side) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => FirmwareSelectionDialogScreen(side: side),
    );
  }

  void _showWatchfaceUpdateDialog(ArmSide side) {
    final l10n = S.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.updateWatch(side.name)),
        content: Text(l10n.whatToUpdate),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _updateSystemFirmware(side);
            },
            child: Text(l10n.firmware),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );
  }

  void _updateSystemFirmware(ArmSide side) {
    const String firmware = "assets/watchfaces/infinitime-1.14.0.zip";
    context.read<DeviceBloc>().updateSystemFirmware(side, firmware);
    _showSuccessMessage(S.of(context).firmwareUpdateInProgress);
  }

  void _requestDeviceInfo(ArmSide side) {
    context.read<DeviceBloc>().add(ReadDeviceInfo(side));
    _showSuccessMessage(S.of(context).deviceInfoRequest(side.name));
  }

  // =================== MESSAGES ===================

  void _showErrorMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccessMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green.shade400),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // =================== UTILITAIRES ===================

  WatchConnectionState _resolveConnectionStateFromDual(ArmState arm) {
    if (arm.deviceId == null) {
      return WatchConnectionState.neverConnected;
    }
    return arm.connected
        ? WatchConnectionState.connected
        : WatchConnectionState.disconnected;
  }

  Map<String, String>? _extractDeviceInfo(ArmState arm) {
    // Utiliser directement deviceInfo de l'état (lu depuis la montre)
    if (arm.deviceInfo != null && arm.deviceInfo!.isNotEmpty) {
      return arm.deviceInfo;
    }

    // Fallback: parser le log (ancien comportement)
    if (arm.log.isEmpty) return null;

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

  String _formatSyncTime(DateTime? time) {
    final l10n = S.of(context);
    if (time == null) return l10n.neverSynchronized;

    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inSeconds < 60) return l10n.agoSeconds(diff.inSeconds);
    if (diff.inMinutes < 60) return l10n.agoMinutes(diff.inMinutes);
    if (diff.inHours < 24) return l10n.agoHours(diff.inHours);
    return l10n.agoDays(diff.inDays);
  }
}
