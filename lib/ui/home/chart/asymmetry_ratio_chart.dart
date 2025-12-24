// ui/home/chart/asymmetry_ratio_chart.dart

import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app_template/models/arm_side.dart';
import 'package:flutter_bloc_app_template/models/goal_config.dart';
import 'package:flutter_bloc_app_template/service/chart_data_adapter.dart';
import 'package:flutter_bloc_app_template/service/chart_refresh_notifier.dart';
import 'package:flutter_bloc_app_template/service/goal_calculator_service.dart';
import 'package:intl/intl.dart';

/// Graphique spécialisé pour visualiser le ratio d'asymétrie avec objectif
/// - Axe X : Temps (Jour/Semaine/Mois)
/// - Axe Y : Ratio d'asymétrie en %
/// - Filtre : Axe ou Magnitude
/// - Légende : "Ratio réel" et "Objectif"
class AsymmetryRatioChart extends StatefulWidget {
  final String title;
  final IconData icon;
  final ArmSide affectedSide;
  final GoalConfig? goalConfig;

  const AsymmetryRatioChart({
    super.key,
    required this.title,
    required this.icon,
    required this.affectedSide,
    this.goalConfig,
  });

  @override
  State<AsymmetryRatioChart> createState() => _AsymmetryRatioChartState();
}

class _AsymmetryRatioChartState extends State<AsymmetryRatioChart> {
  String _selectedPeriod = 'Semaine';
  String _selectedType = 'Axe'; // Axe par défaut car axisActiveTime contient les données valides
  DateTime? _selectedDate;

  final _adapter = ChartDataAdapter();
  final _goalCalculator = GoalCalculatorService();

  // Cache pour les données du graphique - évite les rebuilds inutiles
  Future<_ChartData>? _cachedFuture;
  String? _lastCacheKey;
  StreamSubscription<ChartRefreshEvent>? _refreshSubscription;

  @override
  void initState() {
    super.initState();
    // S'abonner aux notifications de rafraîchissement
    _refreshSubscription = ChartRefreshNotifier().stream.listen((event) {
      // Rafraîchir si c'est un événement de mouvement ou "all"
      if (event.type == ChartRefreshType.movement ||
          event.type == ChartRefreshType.all) {
        if (mounted) {
          _invalidateCache();
        }
      }
    });
  }

  void _invalidateCache() {
    setState(() {
      _cachedFuture = null;
      _lastCacheKey = null;
    });
  }

  /// Obtenir ou créer le Future avec mise en cache intelligente
  Future<_ChartData> _getDataFuture() {
    final currentKey = '$_selectedPeriod-$_selectedType-${_selectedDate?.toIso8601String()}';

    // Réutiliser le cache si la clé n'a pas changé
    if (_cachedFuture != null && _lastCacheKey == currentKey) {
      return _cachedFuture!;
    }

    // Créer un nouveau Future et le mettre en cache
    _lastCacheKey = currentKey;
    _cachedFuture = _loadChartData();
    return _cachedFuture!;
  }

  @override
  void dispose() {
    _refreshSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
          width: 1.2,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 24),
          _buildChart(),
          const SizedBox(height: 8),
          Flexible(child: _buildLegend()),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(widget.icon, size: 20, color: Colors.white),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 10,
                    ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              Text(
                'Période: $_selectedPeriod • Type: $_selectedType',
                style: const TextStyle(fontSize: 11),
              ),
            ],
          ),
        ),
        _buildTypeSelector(),
        const SizedBox(width: 4),
        _buildPeriodSelector(),
      ],
    );
  }

  Widget _buildTypeSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
          width: 1,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isDense: true,
          value: _selectedType,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 16,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
          ),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
          ),
          onChanged: (String? newValue) {
            if (newValue != null && newValue != _selectedType) {
              setState(() {
                _selectedType = newValue;
                _cachedFuture = null; // Invalider le cache
              });
            }
          },
          items: ['Magnitude', 'Axe'].map((type) {
            return DropdownMenuItem(
              value: type,
              child: Text(type, style: const TextStyle(fontSize: 11)),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
          width: 1,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isDense: true,
          value: _selectedPeriod,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 16,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
          ),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
          ),
          onChanged: (String? newValue) {
            if (newValue != null && newValue != _selectedPeriod) {
              setState(() {
                _selectedPeriod = newValue;
                _cachedFuture = null; // Invalider le cache
              });
            }
          },
          items: ['Jour', 'Semaine', 'Mois'].map((period) {
            return DropdownMenuItem(
              value: period,
              child: Text(period, style: const TextStyle(fontSize: 11)),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildChart() {
    return FutureBuilder<_ChartData>(
      future: _getDataFuture(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 270,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || snapshot.data!.ratios.isEmpty) {
          return const SizedBox(
            height: 270,
            child: Center(child: Text('Aucune donnée disponible')),
          );
        }

        return SizedBox(
          height: 270,
          child: _buildLineChart(snapshot.data!),
        );
      },
    );
  }

  Future<_ChartData> _loadChartData() async {
    // Charger les données d'asymétrie NORMALISÉES (abscisses fixes)
    // selon le type sélectionné
    final asymmetryData = _selectedType == 'Magnitude'
        ? await _adapter.getMagnitudeAsymmetry(
            _selectedPeriod,
            _selectedDate,
            affectedSide: widget.affectedSide,
          )
        : await _adapter.getAxisAsymmetry(
            _selectedPeriod,
            _selectedDate,
            affectedSide: widget.affectedSide,
          );

    // IMPORTANT : Les données sont maintenant normalisées par chart_data_adapter
    // Les méthodes getMagnitudeAsymmetry() et getAxisAsymmetry() retournent
    // des données avec abscisses fixes :
    // - Jour : 24 points (0h-23h)
    // - Semaine : 7 points (Lun-Dim)
    // - Mois : 12 points (Jan-Déc)

    // Calculer les objectifs pour chaque point EN PARALLÈLE si goalConfig existe
    final goals = <DateTime, double>{};
    if (widget.goalConfig != null && asymmetryData.isNotEmpty) {
      // Utiliser Future.wait() pour calculer tous les objectifs en parallèle
      final futures = asymmetryData.map((point) async {
        final goal = await _goalCalculator.calculateGoalForDate(
          widget.goalConfig!,
          widget.affectedSide,
          point.timestamp,
        );
        return MapEntry(point.timestamp, goal);
      }).toList();

      final results = await Future.wait(futures);
      for (final entry in results) {
        goals[entry.key] = entry.value;
      }
    }

    return _ChartData(
      ratios: asymmetryData.map((p) => _DataPoint(p.timestamp, p.asymmetryRatio)).toList(),
      goals: goals,
    );
  }

  Widget _buildLineChart(_ChartData data) {
    // Créer les spots pour le ratio réel
    final ratioSpots = <FlSpot>[];
    final goalSpots = <FlSpot>[];

    for (int i = 0; i < data.ratios.length; i++) {
      final point = data.ratios[i];
      ratioSpots.add(FlSpot(i.toDouble(), point.value));

      // Ajouter le spot d'objectif si disponible
      final goal = data.goals[point.timestamp];
      if (goal != null) {
        goalSpots.add(FlSpot(i.toDouble(), goal));
      }
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.grey.withValues(alpha: 0.3),
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            axisNameWidget: const Text(
              '%',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
            ),
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 22,
              getTitlesWidget: (value, meta) {
                return Padding(
                  padding: const EdgeInsets.only(right: 4.0),
                  child: Text(
                    value.toInt().toString(),
                    style: const TextStyle(fontSize: 8),
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 22,
              interval: _getBottomTitlesInterval(data.ratios.length),
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < data.ratios.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      _formatDateLabel(data.ratios[index].timestamp),
                      style: const TextStyle(fontSize: 6),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
        ),
        minY: 0,
        maxY: 100,
        lineBarsData: [
          // Ligne du ratio réel (violet)
          LineChartBarData(
            spots: ratioSpots,
            isCurved: true,
            color: Colors.purple,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 3,
                  color: Colors.purple,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.purple.withValues(alpha: 0.1),
            ),
          ),
          // Ligne de l'objectif (rouge)
          if (goalSpots.isNotEmpty)
            LineChartBarData(
              spots: goalSpots,
              isCurved: false,
              color: Colors.red,
              barWidth: 2,
              isStrokeCapRound: true,
              dashArray: [5, 5],
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 2,
                    color: Colors.red,
                    strokeWidth: 1,
                    strokeColor: Colors.white,
                  );
                },
              ),
            ),
        ],
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (touchedSpot) => Colors.black87,
            tooltipBorderRadius: BorderRadius.circular(8),
            getTooltipItems: (List<LineBarSpot> touchedSpots) {
              return touchedSpots.map((LineBarSpot touchedSpot) {
                final label = touchedSpot.barIndex == 0 ? 'Ratio' : 'Objectif';
                final textStyle = TextStyle(
                  color: touchedSpot.bar.color,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                );
                return LineTooltipItem(
                  '$label: ${touchedSpot.y.toStringAsFixed(1)}%',
                  textStyle,
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  String _formatDateLabel(DateTime date) {
    switch (_selectedPeriod) {
      case 'Jour':
        return '${date.hour}h';
      case 'Semaine':
        return DateFormat('E', 'fr').format(date).substring(0, 3);
      case 'Mois':
        return DateFormat('MMM', 'fr').format(date).substring(0, 3);
      default:
        return DateFormat('dd/MM').format(date);
    }
  }

  double _getBottomTitlesInterval(int dataLength) {
    switch (_selectedPeriod) {
      case 'Jour':
        return 4; // Toutes les 4h
      case 'Semaine':
        return 1; // Tous les jours
      case 'Mois':
        return 2; // Tous les 2 mois
      default:
        return (dataLength / 6).ceilToDouble().clamp(1, double.infinity);
    }
  }

  Widget _buildLegend() {
    return Center(
      child: Wrap(
        spacing: 25,
        runSpacing: 5,
        alignment: WrapAlignment.center,
        children: [
          _buildLegendItem('Ratio réel', Colors.purple),
          _buildLegendItem('Objectif', Colors.red),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    );
  }
}

// Classes helper pour les données
class _ChartData {
  final List<_DataPoint> ratios;
  final Map<DateTime, double> goals;

  _ChartData({required this.ratios, required this.goals});
}

class _DataPoint {
  final DateTime timestamp;
  final double value;

  _DataPoint(this.timestamp, this.value);
}
