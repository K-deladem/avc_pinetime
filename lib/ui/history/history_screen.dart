import 'dart:async';
import 'package:flutter_bloc_app_template/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app_template/app/app_database.dart';
import 'package:flutter_bloc_app_template/bloc/infinitime/dual_infinitime_bloc.dart';
import 'package:flutter_bloc_app_template/models/arm_side.dart';
import 'package:flutter_bloc_app_template/models/device_info_data.dart';
import 'package:flutter_bloc_app_template/models/connection_event.dart';
import 'package:flutter_bloc_app_template/extension/arm_side_extensions.dart';
import 'package:intl/intl.dart';

enum TimePeriod { today, week, month, all, custom }

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  TimePeriod _selectedPeriod = TimePeriod.week;
  ArmSide? _selectedArm; // null = tous les bras
  DateTime? _customStartDate;
  DateTime? _customEndDate;
  late Future<Map<String, List<dynamic>>> _dataFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _dataFuture = _fetchAllData();
    });
  }

  Future<Map<String, List<dynamic>>> _fetchAllData() async {
    final db = AppDatabase.instance;
    final (startDate, endDate) = _getPeriodDates(_selectedPeriod);

    List<DeviceInfoData> batteryData = [];
    List<DeviceInfoData> stepsData = [];
    List<ConnectionEvent> connectionData = [];
    List<Map<String, dynamic>> movementData = [];

    if (_selectedArm == null) {
      // Charger les données de tous les bras
      final leftBattery = await db.getDeviceInfo(
        'left',
        'battery',
        startDate: startDate,
        endDate: endDate,
        limit: 1000,
      );
      final rightBattery = await db.getDeviceInfo(
        'right',
        'battery',
        startDate: startDate,
        endDate: endDate,
        limit: 1000,
      );
      batteryData = [...leftBattery, ...rightBattery];

      final leftSteps = await db.getDeviceInfo(
        'left',
        'steps',
        startDate: startDate,
        endDate: endDate,
        limit: 1000,
      );
      final rightSteps = await db.getDeviceInfo(
        'right',
        'steps',
        startDate: startDate,
        endDate: endDate,
        limit: 1000,
      );
      stepsData = [...leftSteps, ...rightSteps];

      final bloc = context.read<DualInfiniTimeBloc>();
      final leftConn = await bloc.getConnectionHistory(
        ArmSide.left,
        period: _getPeriodDuration(_selectedPeriod),
      );
      final rightConn = await bloc.getConnectionHistory(
        ArmSide.right,
        period: _getPeriodDuration(_selectedPeriod),
      );
      connectionData = [...leftConn, ...rightConn];

      // Charger les données de mouvement
      final leftMovement = await db.getMovementData(
        'left',
        startDate: startDate,
        endDate: endDate,
        limit: 1000,
      );
      final rightMovement = await db.getMovementData(
        'right',
        startDate: startDate,
        endDate: endDate,
        limit: 1000,
      );
      movementData = [...leftMovement, ...rightMovement];
    } else {
      // Charger les données d'un bras spécifique
      final armSideName = _selectedArm!.technicalName;

      batteryData = await db.getDeviceInfo(
        armSideName,
        'battery',
        startDate: startDate,
        endDate: endDate,
        limit: 1000,
      );

      stepsData = await db.getDeviceInfo(
        armSideName,
        'steps',
        startDate: startDate,
        endDate: endDate,
        limit: 1000,
      );

      final bloc = context.read<DualInfiniTimeBloc>();
      connectionData = await bloc.getConnectionHistory(
        _selectedArm!,
        period: _getPeriodDuration(_selectedPeriod),
      );

      // Charger les données de mouvement
      movementData = await db.getMovementData(
        armSideName,
        startDate: startDate,
        endDate: endDate,
        limit: 1000,
      );
    }

    return {
      'battery': batteryData,
      'steps': stepsData,
      'connections': connectionData,
      'movement': movementData,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique'),
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: _exportData,
            tooltip: 'Exporter les données',
          ),
        ],
      ),
      body: Column(
        children: [
          // En-tête avec filtres
          Container(
            color: Theme.of(context).colorScheme.surface,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Sélecteur de bras
                Row(
                  children: [
                    Expanded(
                      child: SegmentedButton<ArmSide?>(
                        segments: const [
                          ButtonSegment(
                            value: null,
                            label: Text('Tous'),
                            icon: Icon(Icons.watch),
                          ),
                          ButtonSegment(
                            value: ArmSide.left,
                            label: Text('Gauche'),
                            icon: Icon(Icons.watch),
                          ),
                          ButtonSegment(
                            value: ArmSide.right,
                            label: Text('Droite'),
                            icon: Icon(Icons.watch),
                          ),
                        ],
                        selected: {_selectedArm},
                        onSelectionChanged: (Set<ArmSide?> selected) {
                          setState(() {
                            _selectedArm = selected.first;
                            _loadData();
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Sélecteur de période
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildPeriodChip('Aujourd\'hui', TimePeriod.today),
                      _buildPeriodChip('7 jours', TimePeriod.week),
                      _buildPeriodChip('30 jours', TimePeriod.month),
                      _buildPeriodChip('Tout', TimePeriod.all),
                      _buildPeriodChip('Personnalisé', TimePeriod.custom),
                    ],
                  ),
                ),

                // Afficher la plage de dates personnalisée si sélectionnée
                if (_selectedPeriod == TimePeriod.custom) ...[
                  const SizedBox(height: 12),
                  _buildCustomDateRange(),
                ],
              ],
            ),
          ),


          // Contenu principal
          Expanded(
            child: FutureBuilder<Map<String, List<dynamic>>>(
              future: _dataFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        Text('Erreur: ${snapshot.error}'),
                      ],
                    ),
                  );
                }

                final data = snapshot.data ?? {};
                final batteryData = data['battery'] as List<DeviceInfoData>? ?? [];
                final stepsData = data['steps'] as List<DeviceInfoData>? ?? [];
                final connectionData = data['connections'] as List<ConnectionEvent>? ?? [];
                final movementData = data['movement'] as List<Map<String, dynamic>>? ?? [];

                if (batteryData.isEmpty && stepsData.isEmpty && connectionData.isEmpty && movementData.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        const Text('Aucune donnée disponible'),
                        const SizedBox(height: 8),
                        Text(
                          _getPeriodLabel(_selectedPeriod),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async => _loadData(),
                  child: _buildTimelineView(
                    context,
                    batteryData,
                    stepsData,
                    connectionData,
                    movementData,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodChip(String label, TimePeriod period) {
    final isSelected = _selectedPeriod == period;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) {
            setState(() {
              _selectedPeriod = period;
              _loadData();
            });
          }
        },
      ),
    );
  }

  Widget _buildTimelineView(
    BuildContext context,
    List<DeviceInfoData> batteryData,
    List<DeviceInfoData> stepsData,
    List<ConnectionEvent> connectionData,
    List<Map<String, dynamic>> movementData,
  ) {
    // Organiser les données par jour
    final Map<String, List<Map<String, dynamic>>> dataByDay = {};

    // Ajouter les données de batterie
    for (final item in batteryData) {
      final dateKey = DateFormat('yyyy-MM-dd').format(item.timestamp);
      dataByDay.putIfAbsent(dateKey, () => []);
      dataByDay[dateKey]!.add({'type': 'battery', 'data': item});
    }

    // Ajouter les données de pas
    for (final item in stepsData) {
      final dateKey = DateFormat('yyyy-MM-dd').format(item.timestamp);
      dataByDay.putIfAbsent(dateKey, () => []);
      dataByDay[dateKey]!.add({'type': 'steps', 'data': item});
    }

    // Ajouter les événements de connexion
    for (final item in connectionData) {
      final dateKey = DateFormat('yyyy-MM-dd').format(item.timestamp);
      dataByDay.putIfAbsent(dateKey, () => []);
      dataByDay[dateKey]!.add({'type': 'connection', 'data': item});
    }

    // Ajouter les données de mouvement
    for (final item in movementData) {
      final timestamp = DateTime.parse(item['timestamp'] as String);
      final dateKey = DateFormat('yyyy-MM-dd').format(timestamp);
      dataByDay.putIfAbsent(dateKey, () => []);
      dataByDay[dateKey]!.add({'type': 'movement', 'data': item});
    }

    // Trier les jours par ordre décroissant
    final sortedDays = dataByDay.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    if (sortedDays.isEmpty) {
      return const Center(child: Text('Aucune donnée disponible'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedDays.length,
      itemBuilder: (context, index) {
        final dateKey = sortedDays[index];
        final dayData = dataByDay[dateKey]!;

        // Trier les données du jour par heure
        dayData.sort((a, b) {
          DateTime aTime;
          DateTime bTime;

          if (a['data'] is DeviceInfoData) {
            aTime = (a['data'] as DeviceInfoData).timestamp;
          } else if (a['data'] is ConnectionEvent) {
            aTime = (a['data'] as ConnectionEvent).timestamp;
          } else {
            aTime = DateTime.parse((a['data'] as Map<String, dynamic>)['timestamp'] as String);
          }

          if (b['data'] is DeviceInfoData) {
            bTime = (b['data'] as DeviceInfoData).timestamp;
          } else if (b['data'] is ConnectionEvent) {
            bTime = (b['data'] as ConnectionEvent).timestamp;
          } else {
            bTime = DateTime.parse((b['data'] as Map<String, dynamic>)['timestamp'] as String);
          }

          return bTime.compareTo(aTime);
        });

        return _buildDaySection(context, dateKey, dayData);
      },
    );
  }

  Widget _buildDaySection(
    BuildContext context,
    String dateKey,
    List<Map<String, dynamic>> dayData,
  ) {
    final date = DateTime.parse(dateKey);
    final isToday = DateFormat('yyyy-MM-dd').format(DateTime.now()) == dateKey;
    final isYesterday = DateFormat('yyyy-MM-dd')
            .format(DateTime.now().subtract(const Duration(days: 1))) ==
        dateKey;

    String dateLabel;
    if (isToday) {
      dateLabel = 'Aujourd\'hui';
    } else if (isYesterday) {
      dateLabel = 'Hier';
    } else {
      dateLabel = DateFormat('EEEE d MMMM yyyy', 'fr_FR').format(date);
    }

    // Calculer les statistiques du jour
    final batteryItems =
        dayData.where((d) => d['type'] == 'battery').map((d) => d['data'] as DeviceInfoData).toList();
    final stepsItems =
        dayData.where((d) => d['type'] == 'steps').map((d) => d['data'] as DeviceInfoData).toList();
    final connectionItems =
        dayData.where((d) => d['type'] == 'connection').map((d) => d['data'] as ConnectionEvent).toList();
    final movementItems =
        dayData.where((d) => d['type'] == 'movement').map((d) => d['data'] as Map<String, dynamic>).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // En-tête du jour avec statistiques
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primaryContainer,
                Theme.of(context).colorScheme.primaryContainer.withOpacity(0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 20,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    dateLabel,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${dayData.length} événements',
                      style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Résumé du jour - Disposition en grille
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (batteryItems.isNotEmpty)
                    _buildDaySummaryCard(
                      context,
                      Icons.battery_charging_full,
                      '${batteryItems.last.value.round()}%',
                      'Batterie',
                      _getBatteryColor(batteryItems.last.value.round()),
                    ),
                  if (stepsItems.isNotEmpty)
                    _buildDaySummaryCard(
                      context,
                      Icons.directions_walk,
                      '${stepsItems.fold<int>(0, (sum, item) => sum + item.value.round())}',
                      'Pas',
                      Theme.of(context).colorScheme.primary,
                    ),
                  if (connectionItems.isNotEmpty)
                    _buildDaySummaryCard(
                      context,
                      Icons.bluetooth_connected,
                      '${connectionItems.where((e) => e.type == ConnectionEventType.connected).length}',
                      'Connexions',
                      Colors.blue,
                    ),
                  if (movementItems.isNotEmpty)
                    _buildDaySummaryCard(
                      context,
                      Icons.vibration,
                      '${movementItems.length}',
                      'Mouvements',
                      Colors.deepOrange,
                    ),
                  _buildDaySummaryCard(
                    context,
                    Icons.event,
                    '${dayData.length}',
                    'Événements',
                    Colors.grey,
                  ),
                ],
              ),
            ],
          ),
        ),

        // Liste des événements du jour
        ...dayData.map((item) {
          final type = item['type'] as String;
          final data = item['data'];

          switch (type) {
            case 'battery':
              return _buildBatteryEventCard(context, data as DeviceInfoData);
            case 'steps':
              return _buildStepsEventCard(context, data as DeviceInfoData);
            case 'connection':
              return _buildConnectionEventCard(context, data as ConnectionEvent);
            case 'movement':
              return _buildMovementEventCard(context, data as Map<String, dynamic>);
            default:
              return const SizedBox.shrink();
          }
        }).toList(),

        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildDaySummaryCard(
      BuildContext context,
      IconData icon,
      String value,
      String label,
      Color color,
      ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: color.withOpacity(0.25),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
              height: 1.0,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              color: color.withOpacity(0.7),
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBatteryEventCard(BuildContext context, DeviceInfoData item) {
    final level = item.value.round();
    final color = _getBatteryColor(level);
    final time = DateFormat('HH:mm').format(item.timestamp);
    final armSide = ArmSideExtension.fromTechnicalName(item.armSide);
    final armSideLabel = armSide.shortLabel;
    final armColor = armSide == ArmSide.left ? Colors.blue : Colors.purple;

    return Container(
      margin: const EdgeInsets.only(bottom: 8, left: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(_getBatteryIcon(level), size: 16, color: color),
              ),
              Container(
                width: 2,
                height: 40,
                color: Colors.grey[300],
              ),
            ],
          ),
          const SizedBox(width: 12),

          // Card content
          Expanded(
            child: Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Text(
                                '$level%',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: color,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _getBatteryStatusText(level),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: color,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: armColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: armColor.withOpacity(0.5)),
                          ),
                          child: Text(
                            armSideLabel,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: armColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          time,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Niveau de batterie',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepsEventCard(BuildContext context, DeviceInfoData item) {
    final steps = item.value.round();
    final time = DateFormat('HH:mm').format(item.timestamp);
    final primaryColor = Theme.of(context).colorScheme.primary;
    final armSide = ArmSideExtension.fromTechnicalName(item.armSide);
    final armSideLabel = armSide.shortLabel;
    final armColor = armSide == ArmSide.left ? Colors.blue : Colors.purple;

    return Container(
      margin: const EdgeInsets.only(bottom: 8, left: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.directions_walk, size: 16, color: primaryColor),
              ),
              Container(
                width: 2,
                height: 40,
                color: Colors.grey[300],
              ),
            ],
          ),
          const SizedBox(width: 12),

          // Card content
          Expanded(
            child: Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '$steps pas',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: armColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: armColor.withOpacity(0.5)),
                          ),
                          child: Text(
                            armSideLabel,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: armColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          time,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Activité détectée',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionEventCard(BuildContext context, ConnectionEvent item) {
    final time = DateFormat('HH:mm').format(item.timestamp);
    final isConnected = item.type == ConnectionEventType.connected;
    final color = isConnected ? Colors.green : Colors.orange;
    final icon = isConnected ? Icons.bluetooth_connected : Icons.bluetooth_disabled;
    final label = isConnected ? 'Connecté' : 'Déconnecté';
    final armSide = ArmSideExtension.fromTechnicalName(item.armSide);
    final armSideLabel = armSide.shortLabel;
    final armColor = armSide == ArmSide.left ? Colors.blue : Colors.purple;

    return Container(
      margin: const EdgeInsets.only(bottom: 8, left: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 16, color: color),
              ),
              Container(
                width: 2,
                height: 40,
                color: Colors.grey[300],
              ),
            ],
          ),
          const SizedBox(width: 12),

          // Card content
          Expanded(
            child: Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            label,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: armColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: armColor.withOpacity(0.5)),
                          ),
                          child: Text(
                            armSideLabel,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: armColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          time,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    if (item.durationSeconds != null && item.durationSeconds! > 0) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Durée: ${_formatDuration(item.durationSeconds!)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                    if (item.batteryAtConnection != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Batterie: ${item.batteryAtConnection}%',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMovementEventCard(BuildContext context, Map<String, dynamic> item) {
    final timestamp = DateTime.parse(item['timestamp'] as String);
    final time = DateFormat('HH:mm').format(timestamp);
    final armSideStr = item['armSide'] as String;
    final armSide = ArmSideExtension.fromTechnicalName(armSideStr);
    final armSideLabel = armSide.shortLabel;
    final armColor = armSide == ArmSide.left ? Colors.blue : Colors.purple;

    // Extraire les données de mouvement
    final magnitudeActiveTime = item['magnitudeActiveTime'] as int?;
    final axisActiveTime = item['axisActiveTime'] as int?;
    final activityLevel = item['activityLevel'] as int? ?? 0;
    final activityCategory = item['activityCategory'] as String? ?? 'unknown';
    final magnitude = (item['magnitude'] as num?)?.toDouble() ?? 0.0;

    // Déterminer la couleur basée sur le niveau d'activité
    Color activityColor;
    IconData activityIcon;
    String activityLabel;

    if (activityLevel >= 3) {
      activityColor = Colors.red;
      activityIcon = Icons.trending_up;
      activityLabel = 'Intense';
    } else if (activityLevel >= 2) {
      activityColor = Colors.orange;
      activityIcon = Icons.show_chart;
      activityLabel = 'Modéré';
    } else if (activityLevel >= 1) {
      activityColor = Colors.green;
      activityIcon = Icons.trending_flat;
      activityLabel = 'Léger';
    } else {
      activityColor = Colors.grey;
      activityIcon = Icons.trending_down;
      activityLabel = 'Repos';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8, left: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: activityColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(activityIcon, size: 16, color: activityColor),
              ),
              Container(
                width: 2,
                height: 40,
                color: Colors.grey[300],
              ),
            ],
          ),
          const SizedBox(width: 12),

          // Card content
          Expanded(
            child: Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Text(
                                'Mouvement',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: activityColor,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: activityColor.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  activityLabel,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: activityColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: armColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: armColor.withOpacity(0.5)),
                          ),
                          child: Text(
                            armSideLabel,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: armColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          time,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Détails du mouvement
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (magnitudeActiveTime != null && magnitudeActiveTime > 0) ...[
                                Row(
                                  children: [
                                    Icon(Icons.timer, size: 12, color: Colors.grey[600]),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Actif: ${_formatTimeMs(magnitudeActiveTime)}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                              ],
                              Row(
                                children: [
                                  Icon(Icons.waves, size: 12, color: Colors.grey[600]),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Magnitude: ${magnitude.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
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
        ],
      ),
    );
  }

  String _formatTimeMs(int milliseconds) {
    final seconds = (milliseconds / 1000).round();
    if (seconds < 60) return '${seconds}s';
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    if (minutes < 60) return '${minutes}m ${secs}s';
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return '${hours}h ${mins}m';
  }

  String _formatDuration(int seconds) {
    if (seconds < 60) return '${seconds}s';
    if (seconds < 3600) return '${(seconds / 60).toStringAsFixed(1)}min';
    return '${(seconds / 3600).toStringAsFixed(1)}h';
  }

  Color _getBatteryColor(int level) {
    if (level > 50) return Colors.green;
    if (level > 20) return Colors.orange;
    return Colors.red;
  }

  IconData _getBatteryIcon(int level) {
    if (level > 90) return Icons.battery_full;
    if (level > 60) return Icons.battery_6_bar;
    if (level > 30) return Icons.battery_3_bar;
    if (level > 10) return Icons.battery_1_bar;
    return Icons.battery_0_bar;
  }

  String _getBatteryStatusText(int level) {
    if (level > 80) return 'Excellent';
    if (level > 50) return 'Bon';
    if (level > 20) return 'Faible';
    return 'Critique';
  }

  (DateTime, DateTime) _getPeriodDates(TimePeriod period) {
    final now = DateTime.now();
    switch (period) {
      case TimePeriod.today:
        final today = DateTime(now.year, now.month, now.day);
        return (today, now);
      case TimePeriod.week:
        return (now.subtract(const Duration(days: 7)), now);
      case TimePeriod.month:
        return (now.subtract(const Duration(days: 30)), now);
      case TimePeriod.all:
        return (DateTime(2020), now);
      case TimePeriod.custom:
        if (_customStartDate != null && _customEndDate != null) {
          return (_customStartDate!, _customEndDate!);
        }
        return (now.subtract(const Duration(days: 7)), now);
    }
  }

  Duration _getPeriodDuration(TimePeriod period) {
    switch (period) {
      case TimePeriod.today:
        return const Duration(days: 1);
      case TimePeriod.week:
        return const Duration(days: 7);
      case TimePeriod.month:
        return const Duration(days: 30);
      case TimePeriod.all:
        return const Duration(days: 365 * 10);
      case TimePeriod.custom:
        if (_customStartDate != null && _customEndDate != null) {
          return _customEndDate!.difference(_customStartDate!);
        }
        return const Duration(days: 7);
    }
  }

  String _getPeriodLabel(TimePeriod period) {
    switch (period) {
      case TimePeriod.today:
        return 'Aujourd\'hui';
      case TimePeriod.week:
        return '7 derniers jours';
      case TimePeriod.month:
        return '30 derniers jours';
      case TimePeriod.all:
        return 'Toutes les données';
      case TimePeriod.custom:
        if (_customStartDate != null && _customEndDate != null) {
          final start = DateFormat('dd/MM/yyyy').format(_customStartDate!);
          final end = DateFormat('dd/MM/yyyy').format(_customEndDate!);
          return 'Du $start au $end';
        }
        return 'Période personnalisée';
    }
  }

  Widget _buildCustomDateRange() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sélectionner une plage de dates',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _selectDate(true),
                  icon: const Icon(Icons.calendar_today, size: 16),
                  label: Text(
                    _customStartDate != null
                        ? DateFormat('dd/MM/yyyy').format(_customStartDate!)
                        : 'Date début',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Icon(Icons.arrow_forward, size: 16),
              ),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _selectDate(false),
                  icon: const Icon(Icons.calendar_today, size: 16),
                  label: Text(
                    _customEndDate != null
                        ? DateFormat('dd/MM/yyyy').format(_customEndDate!)
                        : 'Date fin',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
          if (_customStartDate != null && _customEndDate != null) ...[
            const SizedBox(height: 8),
            Center(
              child: FilledButton.icon(
                onPressed: _loadData,
                icon: const Icon(Icons.check, size: 16),
                label: const Text('Appliquer'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _selectDate(bool isStartDate) async {
    final now = DateTime.now();
    final initialDate = isStartDate
        ? (_customStartDate ?? now.subtract(const Duration(days: 7)))
        : (_customEndDate ?? now);

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: now,
      locale: const Locale('fr', 'FR'),
      helpText: isStartDate ? 'Sélectionner la date de début' : 'Sélectionner la date de fin',
      cancelText: S.of(context).cancel,
      confirmText: 'OK',
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _customStartDate = picked;
          // Si la date de fin est avant la date de début, on la réinitialise
          if (_customEndDate != null && _customEndDate!.isBefore(picked)) {
            _customEndDate = null;
          }
        } else {
          // Si la date de début n'est pas définie ou si la date de fin est avant
          if (_customStartDate == null || picked.isBefore(_customStartDate!)) {
            _customEndDate = null;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('La date de fin doit être après la date de début'),
                duration: Duration(seconds: 2),
              ),
            );
          } else {
            _customEndDate = picked;
          }
        }
      });
    }
  }

  void _exportData() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Export en cours de développement...')),
    );
  }
}
