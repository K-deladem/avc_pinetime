// example/lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:infinitime_dfu_library/infinitime_dfu_library.dart';

void main() {
  runApp(const MyApp());
}

// ============ FIRMWARE SOURCE IMPLEMENTATION ============

  class MyFirmwareSource extends FirmwareSourceDelegate {
  @override
  Future<List<String>> getAvailableFirmwares() async {
    return [
      'assets/firmware/infinitime-1.14.0.zip',
      'assets/firmware/infinitime-1.15.0.zip',
    ];
  }

  @override
  FirmwareInfo? getFirmwareInfo(String assetPath) {
    return null;
  }

  @override
  void onFirmwareLoaded(FirmwareInfo info) {
    debugPrint('[FIRMWARE] Loaded: ${info.shortDescription}');
  }

  @override
  void onFirmwareError(String assetPath, String error) {
    debugPrint('[FIRMWARE ERROR] $assetPath: $error');
  }
}

// ============ MAIN APP ============

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'InfiniTime DFU Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

// ============ HOME PAGE ============

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // ===== BLE & MANAGERS =====
  final FlutterReactiveBle _ble = FlutterReactiveBle();
  late final FirmwareManager _firmwareManager;
  late final DfuServiceManager _dfuService;
  InfiniTimeSession? _session;

  // ===== UI STATE =====
  List<FirmwareInfo> _availableFirmwares = [];
  FirmwareInfo? _selectedFirmware;
  String _log = '';
  bool _isLoading = false;

  // ===== SENSOR DATA =====
  int? _batteryLevel;
  int? _heartRate;
  int? _stepCount;
  MovementData? _lastMovement;
  int _totalMovementEvents = 0;
  double _averageAcceleration = 0.0;
  List<MovementData> _movementHistory = [];

  // ===== UPDATE PROGRESS =====
  double _updateProgress = 0.0;
  String _updateStatus = '';

  @override
  void initState() {
    super.initState();
    _setupManagers();
    _loadFirmwares();
  }

  // ===== SETUP MANAGERS =====
  void _setupManagers() {
    // Initialize Firmware Manager
    _firmwareManager = FirmwareManager(MyFirmwareSource());

    // Initialize DFU Service Manager
    _dfuService = DfuServiceManager(_ble);

    // Setup DFU callbacks
    _dfuService.onStatusUpdate((status) {
      setState(() {
        _updateStatus = status;
      });
      _addLog('[DFU STATUS] $status');
    });

    _dfuService.onProgressUpdate((progress) {
      setState(() {
        _updateProgress = progress;
      });
      _addLog('[DFU PROGRESS] ${(progress * 100).toStringAsFixed(1)}%');
    });

    _dfuService.onError((error) {
      _addLog('[DFU ERROR] $error');
    });

    _addLog('[INIT] Managers initialized');
  }

  // ===== LOAD AVAILABLE FIRMWARES =====
  Future<void> _loadFirmwares() async {
    setState(() {
      _isLoading = true;
      _log = '';
    });

    try {
      _addLog('[FIRMWARE] Loading available firmwares...');

      final firmwares = await _firmwareManager.loadAvailableFirmwares();

      setState(() {
        _availableFirmwares = firmwares;
      });

      _addLog('[FIRMWARE] Loaded ${firmwares.length} firmware(s)');
      for (var fw in firmwares) {
        _addLog('[FIRMWARE]   • ${fw.shortDescription}');
      }
    } catch (e) {
      _addLog('[ERROR] Loading firmwares: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // ===== PERFORM FIRMWARE UPDATE =====
  Future<void> _performUpdate() async {
    // Validation: firmware selected
    if (_selectedFirmware == null) {
      _addLog('[ERROR] Please select a firmware first');
      return;
    }

    if (!_selectedFirmware!.isValid) {
      _addLog('[ERROR] Selected firmware is not valid');
      return;
    }

    setState(() {
      _isLoading = true;
      _log = '';
      _updateProgress = 0.0;
      _updateStatus = '';
    });

    try {
      _addLog('═══════════════════════════════════════════════════════');
      _addLog('[UPDATE] Starting firmware update process');
      _addLog('═══════════════════════════════════════════════════════');

      // ===== STEP 1: VALIDATION =====
      _addLog('[UPDATE] STEP 1: Validating firmware...');
      final validation = await _firmwareManager.validateFirmwareAsset(
        _selectedFirmware!.assetPath,
      );

      if (!validation.isValid) {
        _addLog('[ERROR] Firmware validation failed:');
        for (var issue in validation.criticalIssues) {
          _addLog('[ERROR]   • $issue');
        }
        return;
      }
      _addLog('[UPDATE] Firmware validation successful');

      // ===== STEP 2: LOADING =====
      _addLog('[UPDATE] STEP 2: Loading DFU files...');
      final dfuFiles = await _firmwareManager.loadFirmwareFiles(
        _selectedFirmware!.assetPath,
      );
      _addLog('[UPDATE] DFU files loaded (${dfuFiles.getDescription()})');

      // ===== STEP 3: CONNECTION =====
      _addLog('[UPDATE] STEP 3: Connecting to device...');

      // TODO: REPLACE WITH YOUR DEVICE ID!
      const String deviceId = 'MY_INFINITETIME';

      _addLog('[UPDATE] Device ID: $deviceId');
      _addLog('[UPDATE] Attempting connection (max 3 retries)...');

      final connected = await _dfuService.connectToDevice(
        deviceId,
        maxRetries: 3,
      );

      if (!connected) {
        _addLog('[ERROR] Failed to connect to device');
        _addLog('[ERROR] Please check:');
        _addLog('[ERROR]   • Device ID is correct');
        _addLog('[ERROR]   • Device is visible in Bluetooth');
        _addLog('[ERROR]   • Device is within range');
        _addLog('[ERROR]   • Bluetooth is enabled');
        return;
      }
      _addLog('[UPDATE] Connected to device successfully');

      // ===== STEP 4: PERFORMING UPDATE =====
      _addLog('[UPDATE] STEP 4: Performing firmware update...');
      _addLog('[UPDATE] DO NOT disconnect or move away from device');
      _addLog('[UPDATE] DO NOT turn off the device');
      _addLog('[UPDATE] Keep device at least 50% battery');

      final success = await _dfuService.performCompleteFirmwareUpdate(dfuFiles);

      if (success) {
        _addLog('═══════════════════════════════════════════════════════');
        _addLog('[UPDATE] FIRMWARE UPDATE SUCCESSFUL!');
        _addLog('[UPDATE] Device will restart automatically');
        _addLog('[UPDATE] Please wait for the device to restart');
        _addLog('═══════════════════════════════════════════════════════');
      } else {
        _addLog('[UPDATE] Firmware update failed');
      }
    } catch (e) {
      _addLog('[ERROR] Exception during update: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
      await _dfuService.dispose();
    }
  }

  // ===== TEST COMMUNICATION =====
  Future<void> _testCommunication() async {
    const String deviceId = 'MY_INFINITETIME'; // TODO: Replace with your device ID

    try {
      _addLog('═══════════════════════════════════════════════════════');
      _addLog('[SESSION] Starting communication test');
      _addLog('═══════════════════════════════════════════════════════');

      _addLog('[SESSION] Creating BLE session...');
      _session = InfiniTimeSession(_ble, deviceId);

      _addLog('[SESSION] Connecting to device...');
      if (await _session!.connectAndSetup()) {
        _addLog('[SESSION] Connected successfully');

        // ===== BATTERY =====
        _addLog('[SESSION] Subscribing to battery stream...');
        _session!.batteryStream.listen(
              (level) {
            setState(() {
              _batteryLevel = level;
            });
            _addLog('[BATTERY] Level: $level%');
          },
          onError: (error) {
            _addLog('[BATTERY ERROR] $error');
          },
        );

        // ===== HEART RATE =====
        _addLog('[SESSION] Subscribing to heart rate stream...');
        _session!.heartRateStream.listen(
              (hr) {
            setState(() {
              _heartRate = hr;
            });
            _addLog('[HEARTRATE] HR: $hr bpm');
          },
          onError: (error) {
            _addLog('[HEARTRATE ERROR] $error');
          },
        );

        // ===== STEPS =====
        _addLog('[SESSION] Subscribing to steps stream...');
        _session!.stepCountStream.listen(
              (steps) {
            setState(() {
              _stepCount = steps;
            });
            _addLog('[STEPS] Count: $steps');
          },
          onError: (error) {
            _addLog('[STEPS ERROR] $error');
          },
        );

        // ===== MOVEMENT =====
        _addLog('[SESSION] Subscribing to movement stream...');
        _session!.movementStream.listen(
              (movement) {
            setState(() {
              _lastMovement = movement;
              _totalMovementEvents++;
              _movementHistory.add(movement);

              // Keep only last 50 movements
              if (_movementHistory.length > 50) {
                _movementHistory.removeAt(0);
              }

              // Calculate average acceleration
              if (_movementHistory.isNotEmpty) {
                final sum = _movementHistory
                    .map((m) => m.getAccelerationMagnitude())
                    .fold<double>(0, (a, b) => a + b);
                _averageAcceleration = sum / _movementHistory.length;
              }
            });

            _addLog('[MOVEMENT] Event received:');
            _addLog('[MOVEMENT]   Active Time: ${movement.getAxisActiveTimeFormatted()}');
            _addLog('[MOVEMENT]   Magnitude: ${movement.getAccelerationMagnitude().toStringAsFixed(2)}g');
            _addLog('[MOVEMENT]   Activity: ${movement.getActivityLevel()}% (${movement.getActivityCategory()})');
            _addLog('[MOVEMENT]   Moving: ${movement.anyMovement ? 'Yes' : 'No'}');
          },
          onError: (error) {
            _addLog('[MOVEMENT ERROR] $error');
          },
        );

        // ===== SEND TIME =====
        _addLog('[SESSION] Sending current time...');
        await _session!.sendTime();
        _addLog('[SESSION] Time sent successfully');

        // ===== COLLECT DATA =====
        _addLog('[SESSION] Collecting data for 5 seconds...');
        await Future.delayed(const Duration(seconds: 5));

        // ===== STATISTICS =====
        _addLog('═══════════════════════════════════════════════════════');
        _addLog('[STATS] COLLECTED STATISTICS:');
        _addLog('───────────────────────────────────────────────────────');
        _addLog('[STATS] Total movement events: $_totalMovementEvents');
        _addLog('[STATS] Average acceleration: ${_averageAcceleration.toStringAsFixed(2)}g');
        _addLog('[STATS] Battery: ${_batteryLevel ?? 'N/A'}%');
        _addLog('[STATS] Heart rate: ${_heartRate ?? 'N/A'} bpm');
        _addLog('[STATS] Steps: ${_stepCount ?? 'N/A'}');

        if (_lastMovement != null) {
          _addLog('───────────────────────────────────────────────────────');
          _addLog('[STATS] Last movement details:');
          _addLog('[STATS]   Category: ${_lastMovement!.getActivityCategory()}');
          _addLog('[STATS]   Timestamp: ${_lastMovement!.timestampMs}');
          _addLog('[STATS]   X: ${_lastMovement!.accelX.toStringAsFixed(2)}g');
          _addLog('[STATS]   Y: ${_lastMovement!.accelY.toStringAsFixed(2)}g');
          _addLog('[STATS]   Z: ${_lastMovement!.accelZ.toStringAsFixed(2)}g');
        }

        _addLog('═══════════════════════════════════════════════════════');

        _addLog('[SESSION] Disconnecting...');
        await _session!.disconnect();
        _addLog('[SESSION] Disconnected successfully');
      } else {
        _addLog('[SESSION ERROR] Failed to connect to device');
      }
    } catch (e) {
      _addLog('[SESSION ERROR] Exception: $e');
    }
  }

  // ===== SHOW MOVEMENT ANALYZER =====
  Future<void> _showMovementAnalyzer() async {
    if (_lastMovement == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No movement data available')),
      );
      return;
    }

    await showDialog(
      context: context,
      builder: (context) => _buildMovementAnalyzerDialog(),
    );
  }

  Widget _buildMovementAnalyzerDialog() {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'MOVEMENT ANALYZER',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (_lastMovement == null)
              const Text('No data available')
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatRow('Activity', '${_lastMovement!.getActivityLevel()}%'),
                  _buildStatRow('Category', _lastMovement!.getActivityCategory()),
                  _buildStatRow(
                    'Acceleration',
                    '${_lastMovement!.getAccelerationMagnitude().toStringAsFixed(2)}g',
                  ),
                  _buildStatRow(
                    'Axes (X, Y, Z)',
                    '${_lastMovement!.accelX.toStringAsFixed(2)}, '
                        '${_lastMovement!.accelY.toStringAsFixed(2)}, '
                        '${_lastMovement!.accelZ.toStringAsFixed(2)}',
                  ),
                  _buildStatRow('Moving', _lastMovement!.anyMovement ? 'Yes' : 'No'),
                  _buildStatRow('Active Time', _lastMovement!.getAxisActiveTimeFormatted()),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'HISTORY:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text('Total events: $_totalMovementEvents'),
                        Text(
                          'Average acceleration: ${_averageAcceleration.toStringAsFixed(2)}g',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  void _addLog(String message) {
    setState(() {
      _log += '$message\n';
    });
  }

  @override
  void dispose() {
    _dfuService.dispose();
    _session?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('InfiniTime DFU Manager'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // ===== FIRMWARE SELECTION =====
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Available Firmware',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                if (_availableFirmwares.isEmpty)
                  const Text('No firmware found')
                else
                  DropdownButton<FirmwareInfo>(
                    isExpanded: true,
                    value: _selectedFirmware,
                    hint: const Text('Select a firmware'),
                    items: _availableFirmwares
                        .map((fw) => DropdownMenuItem(
                      value: fw,
                      child: Text(fw.shortDescription),
                    ))
                        .toList(),
                    onChanged: (fw) {
                      setState(() {
                        _selectedFirmware = fw;
                      });
                    },
                  ),
              ],
            ),
          ),

          // ===== SENSOR INDICATORS =====
          if (_batteryLevel != null ||
              _heartRate != null ||
              _stepCount != null ||
              _lastMovement != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    if (_batteryLevel != null)
                      _buildSensorBadge('BATTERY', 'Battery', '$_batteryLevel%', Colors.green),
                    if (_heartRate != null)
                      _buildSensorBadge('HR', 'Heart Rate', '$_heartRate bpm', Colors.red),
                    if (_stepCount != null)
                      _buildSensorBadge('STEPS', 'Steps', '$_stepCount', Colors.blue),
                    if (_lastMovement != null)
                      _buildSensorBadge(
                        'ACCEL',
                        'Activity',
                        '${_lastMovement!.getActivityLevel()}%',
                        Colors.orange,
                      ),
                  ],
                ),
              ),
            ),

          // ===== UPDATE PROGRESS =====
          if (_updateProgress > 0 && _updateProgress < 1)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  LinearProgressIndicator(
                    value: _updateProgress,
                    minHeight: 8,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${(_updateProgress * 100).toStringAsFixed(1)}% - $_updateStatus',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 8),

          // ===== BUTTONS =====
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _loadFirmwares,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _testCommunication,
                    icon: const Icon(Icons.bluetooth),
                    label: const Text('Test Comm'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _lastMovement == null ? null : _showMovementAnalyzer,
                    icon: const Icon(Icons.analytics),
                    label: const Text('Analyze'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _performUpdate,
                    icon: const Icon(Icons.flash_on),
                    label: const Text('Update'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ===== LOGS =====
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[700]!),
              ),
              child: SingleChildScrollView(
                reverse: true,
                child: Text(
                  _log,
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSensorBadge(
      String label,
      String title,
      String value,
      Color color,
      ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          Text(title, style: const TextStyle(fontSize: 10)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }
}