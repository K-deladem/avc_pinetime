import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app_template/bloc/infinitime/dual_infinitime_bloc.dart';
import 'package:flutter_bloc_app_template/bloc/infinitime/dual_infinitime_event.dart';
import 'package:flutter_bloc_app_template/bloc/infinitime/dual_infinitime_state.dart';
import 'package:flutter_bloc_app_template/models/arm_side.dart';
import 'package:flutter_bloc_app_template/models/device_history_entry.dart';
import 'package:flutter_bloc_app_template/models/pinetime_device.dart';
import 'package:flutter_bloc_app_template/ui/home/page/new/device_history_manager.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:infinitime_dfu_library/infinitime_dfu_library.dart';
import 'package:permission_handler/permission_handler.dart';

class ImprovedBluetoothScanPage extends StatefulWidget {
  final ArmSide position;

  const ImprovedBluetoothScanPage({super.key, required this.position});

  @override
  State<ImprovedBluetoothScanPage> createState() => _ImprovedBluetoothScanPageState();
}

class _ImprovedBluetoothScanPageState extends State<ImprovedBluetoothScanPage>
    with TickerProviderStateMixin {
  PineTimeDevice? _connectingDevice;
  bool _hasPopped = false;
  DualInfiniTimeBloc? _dualBloc;

  // Protection contre clics multiples
  bool _isConnecting = false;
  DateTime? _lastConnectionAttempt;

  late AnimationController _scanAnimationController;
  late AnimationController _connectionAnimationController;
  Timer? _autoConnectTimer;
  Timer? _connectTimeout;

  // UI state
  bool _showHistory = true;
  bool _filterEnabled = false;
  bool _showServices = true;
  RangeValues _rssiFilter = const RangeValues(-90, -30);
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // Cache pour éviter les rebuilds
  List<PineTimeDevice> _cachedDevices = [];
  String _lastScanHash = '';

  String get _positionText => widget.position == ArmSide.left ? "gauche" : "droite";

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _dualBloc = context.read<DualInfiniTimeBloc>();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkPermissionsAndStart());
  }

  void _initializeAnimations() {
    _scanAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _connectionAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  void _startConnectTimeout() {
    _connectTimeout?.cancel();

    _connectTimeout = Timer(Duration(seconds: _dualBloc?.connectionTimeoutSeconds ?? 30), () {
      if (!mounted) return;

      _resetConnectionState();

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.warning, color: Colors.white),
              const SizedBox(width: 8),
              const Expanded(child: Text("Connexion expirée. Vérifiez que la montre est à proximité.")),
            ],
          ),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: "Réessayer",
            onPressed: () {
              if (_connectingDevice != null) {
                final device = _connectingDevice!;
                _resetConnectionState();
                // Petit délai avant de réessayer
                Future.delayed(const Duration(milliseconds: 500), () {
                  if (mounted) _connectToDevice(device);
                });
              }
            },
          ),
        ),
      );

      _startScan();
    });
  }


  void _resetConnectionState() {
    setState(() {
      _connectingDevice = null;
      _isConnecting = false;
    });
    _connectionAnimationController.reverse();
  }


  Future<void> _checkPermissionsAndStart() async {
    try {
      final ok = await _requestAllPermissions();
      if (!mounted) return;

      if (ok) {
        // Charger les bindings existants
        _dualBloc?.add(DualLoadBindingsRequested());
        await _checkAutoConnect();
        _startScan();
      } else {
        _showPermissionDeniedDialog();
      }
    } catch (e) {
      print("Erreur lors de l'initialisation: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erreur d'initialisation: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<bool> _requestAllPermissions() async {
    try {
      final permissions = <Permission>[
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.bluetoothAdvertise,
        Permission.locationWhenInUse,
      ];

      final statuses = await permissions.request();

      // Vérifier les permissions critiques
      final critical = [
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.locationWhenInUse
      ];

      return critical.every((p) => statuses[p] == PermissionStatus.granted);
    } catch (e) {
      print("Erreur permissions: $e");
      return false;
    }
  }

  void _showPermissionDeniedDialog() {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("Permissions requises"),
        content: const Text(
          "Cette application nécessite les permissions Bluetooth et de localisation "
              "pour scanner et se connecter aux montres PineTime.\n\n"
              "Veuillez les activer dans les paramètres de l'appareil.",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text("Retour"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await openAppSettings();
            },
            child: const Text("Paramètres"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _connectTimeout?.cancel();
    _autoConnectTimer?.cancel();
    _scanAnimationController.dispose();
    _connectionAnimationController.dispose();
    _searchController.dispose();
    _dualBloc?.add(DualScanStopRequested());

    // NOUVEAU : Nettoyer les nouveaux états
    _isConnecting = false;
    _lastConnectionAttempt = null;

    super.dispose();
  }

  Future<void> _checkAutoConnect() async {
    try {
      final last = await DeviceHistoryManager.getLastDeviceForPosition(widget.position);
      if (last == null || !mounted) return;

      // Vérifier si le device est en favoris
      final isFavorite = await DeviceHistoryManager.isFavoriteDevice(last.id);
      if (!isFavorite) {
        print("Device ${last.name} non-favori, pas d'auto-connexion");
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text("Connexion automatique à ${last.name}...")),
            ],
          ),
          // Utiliser la durée max de reconnexion du Bloc
          duration: Duration(seconds: _dualBloc?.maxReconnectDelaySeconds ?? 30),
          action: SnackBarAction(
            label: "Annuler",
            onPressed: () => _autoConnectTimer?.cancel(),
          ),
        ),
      );

      // Utiliser l'intervalle de throttle du Bloc
      _autoConnectTimer = Timer.periodic(
          Duration(milliseconds: _dualBloc?.scanThrottleMs ?? 500),
              (timer) {
            if (!mounted) {
              timer.cancel();
              return;
            }

            final scan = _dualBloc?.state.lastScan ?? <String, DiscoveredDevice>{};
            final match = scan[last.id];

            if (match != null) {
              timer.cancel();
              if (mounted) {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                _connectToDevice(_toPineTimeDevice(match));
              }
            }
          }
      );

      // Utiliser la durée max de reconnexion du Bloc pour arrêter l'auto-connexion
      Timer(Duration(seconds: _dualBloc?.maxReconnectDelaySeconds ?? 30), () {
        _autoConnectTimer?.cancel();
        if (mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        }
      });
    } catch (e) {
      print("Erreur auto-connect: $e");
    }
  }

  void _startScan() {
    if (!mounted) return;
    _dualBloc?.add(DualScanRequested());
    _scanAnimationController.repeat();
  }

  void _stopScan() {
    if (!mounted) return;
    _dualBloc?.add(DualScanStopRequested());
    if (_scanAnimationController.isAnimating) {
      _scanAnimationController.stop();
    }
  }

  void _connectToDevice(PineTimeDevice device) {
    if (!mounted || _connectingDevice != null || _isConnecting) {
      print("Connexion déjà en cours ou widget non monté");
      return;
    }

    // NOUVEAU : Protection contre clics multiples rapides
    final now = DateTime.now();
    if (_lastConnectionAttempt != null) {
      final timeSinceLastAttempt = now.difference(_lastConnectionAttempt!);
      if (timeSinceLastAttempt.inSeconds < 2) {
        print("Tentative de connexion trop rapide, ignorée");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Veuillez patienter entre les tentatives de connexion"),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }
    }
    _lastConnectionAttempt = now;

    setState(() {
      _connectingDevice = device;
      _isConnecting = true;
    });

    HapticFeedback.lightImpact();
    _stopScan();
    _connectionAnimationController.forward();

    // Sauvegarder dans l'historique
    try {
      final entry = DiscoveredDevice(
        id: device.id,
        name: device.name,
        serviceUuids: device.advertisedServices
            .map((s) => _tryParseUuid(s) ?? Uuid.parse("00000000-0000-0000-0000-000000000000"))
            .toList(),
        rssi: device.rssi,
        connectable: device.isConnectable ? Connectable.available : Connectable.unavailable,
        serviceData: const {},
        manufacturerData: device.manufacturerData,
      );
      DeviceHistoryManager.saveConnection(entry, widget.position);
    } catch (e) {
      print("Erreur sauvegarde historique: $e");
    }

    // NOUVEAU : Feedback utilisateur amélioré
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
            Expanded(
              child: Text("Connexion à ${device.name.isNotEmpty ? device.name : 'PineTime'}..."),
            ),
          ],
        ),
        duration: Duration(seconds: (_dualBloc?.connectionTimeoutSeconds ?? 30) - 5),
        backgroundColor: Colors.blue,
      ),
    );

    // Un seul appel qui combine bind + connect atomiquement
    final bloc = _dualBloc;
    if (bloc != null) {
      bloc.add(DualBindAndConnectArmRequested(
          widget.position,
          device.id,
          name: device.name
      ));
      _startConnectTimeout();
    } else {
      _resetConnectionState();
    }
  }


  // Helper methods
  bool _isPineTimeName(String name) {
    final n = name.toLowerCase();
    return n.contains("pinetime") ||
        n.contains("infinitime") ||
        n.contains("pine time");
  }

  Uuid? _tryParseUuid(String s) {
    try {
      return Uuid.parse(s);
    } catch (_) {
      return null;
    }
  }

  PineTimeDevice _toPineTimeDevice(DiscoveredDevice d) {
    return PineTimeDevice(
      id: d.id,
      name: d.name.isNotEmpty ? d.name : "PineTime",
      rssi: d.rssi,
      advertisedServices: d.serviceUuids.map((u) => u.toString()).toList(),
      manufacturerData: d.manufacturerData is Uint8List
          ? d.manufacturerData as Uint8List
          : Uint8List.fromList(d.manufacturerData),
      isConnectable: d.connectable == Connectable.available,
    );
  }

  List<PineTimeDevice> _getFilteredDevices(DualInfiniTimeState state) {
    // Créer un hash du scan pour éviter les recalculs inutiles
    final scanHash = state.lastScan.keys.join(',');
    if (scanHash == _lastScanHash && _cachedDevices.isNotEmpty) {
      return _cachedDevices;
    }

    var devices = state.lastScan.values
        .where((d) => _isPineTimeName(d.name))
        .map(_toPineTimeDevice)
        .toList();

    // Appliquer les filtres
    if (_filterEnabled) {
      devices = devices
          .where((d) => d.rssi >= _rssiFilter.start && d.rssi <= _rssiFilter.end)
          .toList();
    }

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      devices = devices
          .where((d) =>
      d.name.toLowerCase().contains(q) ||
          d.id.toLowerCase().contains(q))
          .toList();
    }

    // Trier par RSSI
    devices.sort((a, b) => b.rssi.compareTo(a.rssi));

    _cachedDevices = devices;
    _lastScanHash = scanHash;
    return devices;
  }

  String _serviceLabel(String uuid) {
    final s = uuid.toLowerCase();

    if (s == InfiniTimeUuids.blefsService.toString().toLowerCase()) return "BLEFS";
    if (s == InfiniTimeUuids.weatherService.toString().toLowerCase()) return "Weather";
    if (s == InfiniTimeUuids.musicService.toString().toLowerCase()) return "Music";
    if (s == InfiniTimeUuids.navService.toString().toLowerCase()) return "Nav";
    if (s == InfiniTimeUuids.batteryService.toString().toLowerCase()) return "Battery";

    return s.length >= 8 ? s.substring(0, 8) : s;
  }

  Widget build(BuildContext context) {
    return BlocListener<DualInfiniTimeBloc, DualInfiniTimeState>(
      bloc: _dualBloc,
      listenWhen: (prev, curr) {
        final p = widget.position == ArmSide.left ? prev.left : prev.right;
        final c = widget.position == ArmSide.left ? curr.left : curr.right;
        return p.connected != c.connected || p.deviceId != c.deviceId;
      },
      listener: (context, state) {
        final arm = widget.position == ArmSide.left ? state.left : state.right;
        final boundId = arm.deviceId?.toLowerCase();
        final targetId = _connectingDevice?.id.toLowerCase();

        if (arm.connected &&
            boundId != null &&
            targetId != null &&
            boundId == targetId &&
            !_hasPopped) {

          _connectTimeout?.cancel();
          _hasPopped = true;
          _resetConnectionState();
          _scanAnimationController.stop();
          HapticFeedback.heavyImpact();

          // NOUVEAU : Masquer l'ancien snackbar et montrer le succès
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text("Connexion réussie !"),
                ],
              ),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );

          Future.delayed(Duration(milliseconds: _dualBloc?.stableConnectionDelayMs ?? 3000), () {
            if (mounted) {
              Navigator.pop(context, {
                "position": widget.position,
                "device": _connectingDevice,
                "verified": true,
              });
            }
          });
        }
      },  child: Scaffold(
        appBar: AppBar(
          title: Text("PineTime ($_positionText)"),
          backgroundColor: Theme.of(context).colorScheme.surface,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: _showSearchDialog,
            ),
            PopupMenuButton(
              itemBuilder: (context) => [
                PopupMenuItem(
                  child: Row(
                    children: [
                      Icon(_showHistory ? Icons.history : Icons.history_outlined),
                      const SizedBox(width: 8),
                      Text(_showHistory ? "Masquer l'historique" : "Afficher l'historique"),
                    ],
                  ),
                  onTap: () => setState(() => _showHistory = !_showHistory),
                ),
                PopupMenuItem(
                  child: Row(
                    children: [
                      Icon(_showServices ? Icons.developer_mode : Icons.developer_mode_outlined),
                      const SizedBox(width: 8),
                      Text(_showServices ? "Masquer les services" : "Afficher les services"),
                    ],
                  ),
                  onTap: () => setState(() => _showServices = !_showServices),
                ),
                PopupMenuItem(
                  child: Row(
                    children: [
                      Icon(_filterEnabled ? Icons.filter_alt : Icons.filter_alt_outlined),
                      const SizedBox(width: 8),
                      Text(_filterEnabled ? "Désactiver le filtre" : "Activer le filtre"),
                    ],
                  ),
                  onTap: () => setState(() => _filterEnabled = !_filterEnabled),
                ),
              ],
            ),
            BlocBuilder<DualInfiniTimeBloc, DualInfiniTimeState>(
              builder: (context, state) {
                final isScanning = state.scanning;
                return IconButton(
                  icon: Icon(isScanning ? Icons.stop : Icons.refresh),
                  tooltip: isScanning ? "Arrêter le scan" : "Relancer le scan",
                  onPressed: isScanning ? _stopScan : _startScan,
                );
              },
            ),
          ],
        ),
        body: BlocBuilder<DualInfiniTimeBloc, DualInfiniTimeState>(
          builder: (context, state) => _buildBody(state),
        ),
      ),
    );
  }

  // [Le reste des méthodes _buildBody, _buildMainContent, etc. restent identiques...]
  // Je les omets ici pour la lisibilité, mais elles ne changent pas

  Widget _buildBody(DualInfiniTimeState state) {
    final devices = _getFilteredDevices(state);

    return Column(
      children: [
        _buildArmPositionIndicator(),
        if (_searchQuery.isNotEmpty) _buildSearchBar(),
        if (_filterEnabled) _buildRssiFilter(),
        if (_showHistory) _buildHistorySection(),
        if (_showHistory && devices.isNotEmpty) const Divider(),
        Expanded(child: _buildMainContent(state, devices)),
      ],
    );
  }

  Widget _buildMainContent(DualInfiniTimeState state, List<PineTimeDevice> devices) {
    if (state.scanning) {
      return _buildScanningIndicator();
    }

    if (devices.isNotEmpty) {
      return _buildDevicesList(devices, state);
    }

    if (!state.scanning && state.lastScan.isEmpty) {
      return _buildInitialState();
    }

    return _buildEmptyState();
  }

  Widget _buildArmPositionIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildArmIndicator(ArmSide.left, "Gauche"),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(0),
            ),
            child: const Icon(Icons.person, size: 32),
          ),
          _buildArmIndicator(ArmSide.right, "Droite"),
        ],
      ),
    );
  }

  Widget _buildArmIndicator(ArmSide side, String label) {
    final isSelected = widget.position == side;
    final borderRadius = side == ArmSide.left
        ? const BorderRadius.horizontal(left: Radius.circular(20))
        : const BorderRadius.horizontal(right: Radius.circular(20));

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected
            ? Theme.of(context).colorScheme.primary
            : Colors.grey.shade200,
        borderRadius: borderRadius,
      ),
      child: Row(
        children: [
          if (side == ArmSide.left) ...[
            Icon(
              Icons.watch,
              color: isSelected ? Colors.white : Colors.grey.shade600,
              size: 20,
            ),
            const SizedBox(width: 8),
          ],
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (side == ArmSide.right) ...[
            const SizedBox(width: 8),
            Icon(
              Icons.watch,
              color: isSelected ? Colors.white : Colors.grey.shade600,
              size: 20,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: "Rechercher par nom ou ID...",
          prefixIcon: const Icon(Icons.search),
          suffixIcon: IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              _searchController.clear();
              setState(() {
                _searchQuery = '';
                _lastScanHash = ''; // Force refresh
              });
            },
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
        ),
        onChanged: (v) => setState(() {
          _searchQuery = v;
          _lastScanHash = ''; // Force refresh
        }),
      ),
    );
  }

  Widget _buildRssiFilter() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha:0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.signal_cellular_alt,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                "Filtre de proximité",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                "${_rssiFilter.start.round()} dBm",
                style: const TextStyle(fontSize: 12),
              ),
              Expanded(
                child: RangeSlider(
                  values: _rssiFilter,
                  min: -100,
                  max: -20,
                  divisions: 80,
                  labels: RangeLabels(
                    "${_rssiFilter.start.round()} dBm",
                    "${_rssiFilter.end.round()} dBm",
                  ),
                  onChanged: (v) => setState(() {
                    _rssiFilter = v;
                    _lastScanHash = ''; // Force refresh
                  }),
                ),
              ),
              Text(
                "${_rssiFilter.end.round()} dBm",
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistorySection() {
    return FutureBuilder<DeviceHistoryEntry?>(
      future: DeviceHistoryManager.getLastDeviceForPosition(widget.position),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          return const SizedBox.shrink();
        }

        final lastDevice = snapshot.data!;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Theme.of(context).colorScheme.primary.withValues(alpha:0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.history,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Dernière connexion",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildHistoryItem(lastDevice),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHistoryItem(DeviceHistoryEntry entry) {
    return InkWell(
      onTap: () => _connectFromHistory(entry),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withValues(alpha:0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary.withValues(alpha:0.2),
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.watch, size: 20, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          entry.name.isNotEmpty ? entry.name : "PineTime",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      // NOUVEAU : Indicateur favori dans l'historique
                      FutureBuilder<bool>(
                        future: DeviceHistoryManager.isFavoriteDevice(entry.id),
                        builder: (context, snapshot) {
                          final isFavorite = snapshot.data ?? false;
                          if (!isFavorite) return const SizedBox.shrink();

                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star,
                                size: 14,
                                color: Colors.amber,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "Favori",
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.amber.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "ID: ${entry.id}",
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (entry.lastRssi != null)
                  Text(
                    "${entry.lastRssi}dBm",
                    style: TextStyle(
                      fontSize: 12,
                      color: _getRssiColor(entry.lastRssi!),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                const SizedBox(height: 2),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.replay, size: 14, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 4),
                    Text(
                      "Reconnecter",
                      style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _connectFromHistory(DeviceHistoryEntry entry) {
    final dev = PineTimeDevice(
      id: entry.id,
      name: entry.name,
      rssi: entry.lastRssi ?? -70,
      advertisedServices: entry.serviceUuids.map((u) => u.toString()).toList(),
      manufacturerData: Uint8List(0),
      isConnectable: true,
    );
    _connectToDevice(dev);
  }

  Widget _buildScanningIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _scanAnimationController,
            builder: (_, __) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  // Cercles d'animation
                  ...List.generate(3, (i) {
                    return Container(
                      width: 80 + (i * 40).toDouble(),
                      height: 80 + (i * 40).toDouble(),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withValues(alpha:0.2 - (i * 0.05)),
                          width: 1,
                        ),
                      ),
                    );
                  }),
                  // Ligne de scan rotative
                  Transform.rotate(
                    angle: _scanAnimationController.value * 2 * 3.14159,
                    child: Container(
                      width: 2,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Theme.of(context).colorScheme.primary,
                            Theme.of(context).colorScheme.primary.withValues(alpha:0),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Icône centrale
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).colorScheme.primary.withValues(alpha:0.1),
                    ),
                    child: Icon(
                      Icons.bluetooth_searching,
                      color: Theme.of(context).colorScheme.primary,
                      size: 30,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          Text(
            "Recherche de votre PineTime ($_positionText)...",
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: Colors.grey.shade700),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            "Assurez-vous que votre montre est allumée et visible",
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Colors.grey.shade500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDevicesList(List<PineTimeDevice> devices, DualInfiniTimeState state) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: devices.length + 1, // +1 pour le header
      itemBuilder: (context, index) {
        if (index == 0) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 8),
            color: Theme.of(context).colorScheme.primary.withValues(alpha:0.1),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "${devices.length} montre(s) trouvée(s) pour le bras $_positionText",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _startScan,
                  child: const Text("Actualiser"),
                ),
              ],
            ),
          );
        }

        final deviceIndex = index - 1;
        if (deviceIndex >= devices.length) {
          return const SizedBox.shrink();
        }

        final device = devices[deviceIndex];
        return  KeyedSubtree(
          key: ValueKey(device.id),
          child: _buildDeviceCard(device, state),
        );
      },
    );
  }

  Widget _buildDeviceCard(PineTimeDevice device, DualInfiniTimeState state) {
    final name = device.name.isNotEmpty ? device.name : "Appareil Bluetooth";
    final isConnecting = _connectingDevice?.id == device.id;
    final isPineTime = _isPineTimeName(name);

    // RSSI en temps réel depuis l'état du BLoC
    int liveRssi = device.rssi;
    if (state.left.deviceId == device.id && state.left.rssi != null) {
      liveRssi = state.left.rssi!;
    } else if (state.right.deviceId == device.id && state.right.rssi != null) {
      liveRssi = state.right.rssi!;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: isConnecting
            ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
            : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPineTime
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.primary.withValues(alpha:0.3),
          width: isPineTime ? 2 : 1.2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha:0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.watch,
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          //NOUVEAU : Bouton favori
                          FutureBuilder<bool>(
                            future: DeviceHistoryManager.isFavoriteDevice(device.id),
                            builder: (context, snapshot) {
                              final isFavorite = snapshot.data ?? false;
                              return IconButton(
                                icon: Icon(
                                  isFavorite ? Icons.favorite : Icons.favorite_border,
                                  color: isFavorite
                                      ? Colors.red
                                      : Colors.grey.shade400,
                                  size: 20,
                                ),
                                onPressed: () => _toggleFavorite(device),
                                tooltip: isFavorite
                                    ? "Retirer des favoris"
                                    : "Ajouter aux favoris",
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(
                                  minWidth: 32,
                                  minHeight: 32,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _getDeviceTypeText(device),
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                _buildRssiIndicator(liveRssi),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "ID: ${device.id}",
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                          fontFamily: 'monospace',
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (device.advertisedServices.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          "Services: ${device.advertisedServices.length}",
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                      // NOUVEAU : Indicateur favori
                      FutureBuilder<bool>(
                        future: DeviceHistoryManager.isFavoriteDevice(device.id),
                        builder: (context, snapshot) {
                          final isFavorite = snapshot.data ?? false;
                          if (!isFavorite) return const SizedBox.shrink();

                          return Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  size: 12,
                                  color: Colors.amber,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "Favori (connexion auto)",
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.amber.shade700,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                _buildConnectButton(device, isConnecting),
              ],
            ),
            if (_showServices && device.advertisedServices.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildServiceChips(device.advertisedServices),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _toggleFavorite(PineTimeDevice device) async {
    try {
      final isFavorite = await DeviceHistoryManager.isFavoriteDevice(device.id);

      if (isFavorite) {
        await DeviceHistoryManager.removeFavoriteDevice(device.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.favorite_border, color: Colors.white, size: 16),
                  const SizedBox(width: 8),
                  Text("${device.name} retiré des favoris"),
                ],
              ),
              backgroundColor: Colors.grey.shade600,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        await DeviceHistoryManager.addFavoriteDevice(device.id, device.name);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.favorite, color: Colors.white, size: 16),
                  const SizedBox(width: 8),
                  Text("${device.name} ajouté aux favoris"),
                ],
              ),
              backgroundColor: Colors.red.shade600,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }

      // Forcer le rebuild pour mettre à jour l'icône
      setState(() {});

    } catch (e) {
      print("Erreur toggle favori: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erreur: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildConnectButton(PineTimeDevice device, bool isConnecting) {
    final primary = Theme.of(context).colorScheme.primary;

    // Vrai seulement si CE device est celui en cours de connexion
    final isThisConnecting = _isConnecting && _connectingDevice?.id == device.id;

    // Les autres devices sont désactivés (pas de spinner)
    final isOtherDisabled = _isConnecting && _connectingDevice?.id != device.id;

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 36, minWidth: 120),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: isThisConnecting
            ? Container(
          key: const ValueKey('connecting-this'),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: primary, width: 1),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 8),
              Text(
                "Connexion...",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
              ),
            ],
          ),
        )
            : ElevatedButton.icon(
          key: const ValueKey('idle-this'),
          onPressed: isOtherDisabled ? null : () => _connectToDevice(device),
          icon: const Icon(Icons.link, size: 16),
          label: const Text("Connecter"),
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.grey.shade400,
            disabledForegroundColor: Colors.grey.shade600,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 0,
            minimumSize: const Size(120, 36),
          ),
        ),
      ),
    );
  }


  Widget _buildRssiIndicator(int rssi) {
    final color = _getRssiColor(rssi);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.signal_cellular_alt, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          "${rssi}dBm",
          style: TextStyle(fontSize: 11, color: color),
        ),
      ],
    );
  }

  Color _getRssiColor(int rssi) {
    if (rssi >= -50) return Colors.green;
    if (rssi >= -70) return Colors.orange;
    return Colors.red;
  }

  String _getDeviceTypeText(PineTimeDevice device) {
    final n = device.name.toLowerCase();
    if (n.contains("pinetime")) return "PineTime";
    if (n.contains("infinitime")) return "InfiniTime";
    if (n.contains("dfu")) return "Mode DFU";
    return "Montre connectée";
  }

  Widget _buildServiceChips(List<String> services) {
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: services.take(5).map((s) {
        final label = _serviceLabel(s);
        final isImportant = ["BLEFS", "Weather", "Music", "Nav", "Battery"].contains(label);

        return Chip(
          label: Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isImportant ? FontWeight.w600 : FontWeight.normal,
              color: isImportant
                  ? Colors.white
                  : Theme.of(context).colorScheme.primary,
            ),
          ),
          backgroundColor: isImportant
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.primary.withValues(alpha:0.1),
          visualDensity: VisualDensity.compact,
        );
      }).toList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.watch_off, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              "Aucune montre détectée",
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: Colors.grey.shade700),
            ),
            const SizedBox(height: 8),
            Text(
              "Vérifiez que votre PineTime est allumée et en mode découvrable",
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.grey.shade500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text("Relancer le scan"),
              onPressed: _startScan,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInitialState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bluetooth, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            "Prêt à scanner",
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(color: Colors.grey.shade700),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.bluetooth_searching),
            label: const Text("Commencer le scan"),
            onPressed: _startScan,
          ),
        ],
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Rechercher un dispositif"),
        content: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: "Nom ou ID du dispositif...",
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (v) => setState(() {
            _searchQuery = v;
            _lastScanHash = ''; // Force refresh
          }),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () {
              _searchController.clear();
              setState(() {
                _searchQuery = '';
                _lastScanHash = ''; // Force refresh
              });
              Navigator.pop(context);
            },
            child: const Text("Effacer"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Fermer"),
          ),
        ],
      ),
    );
  }
}