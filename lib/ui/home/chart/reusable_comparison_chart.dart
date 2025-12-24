// ui/home/chart/reusable_comparison_chart.dart

import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app_template/models/arm_side.dart';
import 'package:flutter_bloc_app_template/service/chart_refresh_notifier.dart';
import 'package:intl/intl.dart';

/// Widget de comparaison RÉUTILISABLE pour tous les types de graphiques
/// Supporte les modes: bar, line, avec ou sans tendances
///
/// Ce composant unifié remplace:
/// - ComparisonChartCard
/// - TrendChartWidget
/// - MovementGroupedBarChart
/// - Parties de UnifiedComparisonChart
class ReusableComparisonChart extends StatefulWidget {
  final String title;
  final IconData icon;
  final Color leftColor;
  final Color rightColor;

  /// Les données à afficher (déjà agrégées)
  final Future<List<ChartDataPoint>> Function(String period, DateTime? selectedDate) dataProvider;

  /// Unité de mesure (ex: '%', 'pas', 'magnitude')
  final String unit;

  /// Mode d'affichage par défaut
  final ChartMode defaultMode;

  /// Afficher ou non le bouton de bascule ligne/barre
  final bool showModeToggle;

  /// Afficher ou non les tendances
  final bool showTrendLine;

  /// Périodes disponibles
  final List<String> availablePeriods;

  /// Valeur maximale fixe pour l'axe Y (optionnel)
  final double? fixedMaxY;

  /// Valeur minimale fixe pour l'axe Y (optionnel)
  final double? fixedMinY;

  /// Membre atteint: "left" pour bras gauche, "right" pour bras droit, null si non applicable
  final ArmSide? affectedSide;

  /// Valeur de l'objectif à afficher (optionnel)
  final double? goalValue;

  /// Afficher ou non la ligne d'objectif
  final bool showGoalLine;

  /// Afficher ou non les données de droite (par défaut true)
  final bool showRightData;

  const ReusableComparisonChart({
    super.key,
    required this.title,
    required this.icon,
    required this.dataProvider,
    required this.unit,
    this.leftColor = Colors.blueAccent,
    this.rightColor = Colors.green,
    this.defaultMode = ChartMode.bar,
    this.showModeToggle = true,
    this.showTrendLine = false,
    this.availablePeriods = const ['Jour', 'Semaine', 'Mois'],
    this.fixedMaxY,
    this.fixedMinY,
    this.affectedSide,
    this.goalValue,
    this.showGoalLine = false,
    this.showRightData = true,
  });

  @override
  State<ReusableComparisonChart> createState() => _ReusableComparisonChartState();
}

enum ChartMode { bar, line }

class _ReusableComparisonChartState extends State<ReusableComparisonChart> {
  String _selectedPeriod = 'Semaine';
  DateTime? _selectedDate;
  late ChartMode _currentMode;

  // Cache pour les données du graphique - évite les rebuilds inutiles
  Future<List<ChartDataPoint>>? _cachedFuture;
  String? _lastCacheKey;
  StreamSubscription<ChartRefreshEvent>? _refreshSubscription;

  @override
  void initState() {
    super.initState();
    _currentMode = widget.defaultMode;
    if (!widget.availablePeriods.contains(_selectedPeriod)) {
      _selectedPeriod = widget.availablePeriods.first;
    }

    // S'abonner aux notifications de rafraîchissement avec debounce
    _refreshSubscription = ChartRefreshNotifier().stream.listen((event) {
      if (mounted) {
        // Invalider le cache et reconstruire
        _invalidateCache();
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
  Future<List<ChartDataPoint>> _getDataFuture() {
    final currentKey = '$_selectedPeriod-${_selectedDate?.toIso8601String()}';

    // Réutiliser le cache si la clé n'a pas changé
    if (_cachedFuture != null && _lastCacheKey == currentKey) {
      return _cachedFuture!;
    }

    // Créer un nouveau Future et le mettre en cache
    _lastCacheKey = currentKey;
    _cachedFuture = widget.dataProvider(_selectedPeriod, _selectedDate);
    return _cachedFuture!;
  }

  @override
  void dispose() {
    _refreshSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
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
            FutureBuilder<List<ChartDataPoint>>(
              future: _getDataFuture(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 270,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const SizedBox(
                    height: 270,
                    child: Center(child: Text('Aucune donnée disponible')),
                  );
                }

                return LayoutBuilder(
                  builder: (context, constraints) {
                    return SizedBox(
                      height: 270,
                      child: RepaintBoundary(
                        child: _currentMode == ChartMode.bar
                            ? _buildBarChart(snapshot.data!, constraints.maxWidth)
                            : _buildLineChart(snapshot.data!, constraints.maxWidth),
                      ),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 8),
            _buildLegend(),
          ],
        ),
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
                'Période: $_selectedPeriod',
                style: const TextStyle(fontSize: 11),
              ),
            ],
          ),
        ),
        if (widget.showModeToggle) ...[
          _buildModeToggle(),
          const SizedBox(width: 4),
        ],
        _buildPeriodSelector(),
      ],
    );
  }

  Widget _buildModeToggle() {
    return InkWell(
      onTap: () {
        setState(() {
          _currentMode = _currentMode == ChartMode.bar ? ChartMode.line : ChartMode.bar;
        });
      },
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
          shape: BoxShape.circle,
        ),
        child: Icon(
          _currentMode == ChartMode.bar ? Icons.show_chart : Icons.bar_chart,
          size: 18,
          color: Colors.white,
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
          items: widget.availablePeriods.map((period) {
            return DropdownMenuItem(
              value: period,
              child: Text(period, style: const TextStyle(fontSize: 11)),
            );
          }).toList(),
        ),
      ),
    );
  }

  /// Calcule la moyenne des valeurs pour la ligne d'objectif
  double _calculateAverage(List<ChartDataPoint> data) {
    if (data.isEmpty) return 0.0;

    double sum = 0.0;
    int count = 0;

    for (final point in data) {
      if (point.leftValue != null && point.leftValue! > 0) {
        sum += point.leftValue!;
        count++;
      }
      if (widget.showRightData && point.rightValue != null && point.rightValue! > 0) {
        sum += point.rightValue!;
        count++;
      }
    }

    return count > 0 ? sum / count : 0.0;
  }

  Widget _buildBarChart(List<ChartDataPoint> data, double chartWidth) {
    if (data.isEmpty) {
      return const Center(child: Text('Aucune donnée disponible'));
    }

    final barGroups = <BarChartGroupData>[];
    double maxValue = 0.0;

    for (int i = 0; i < data.length; i++) {
      final point = data[i];
      final leftValue = point.leftValue ?? 0.0;
      final rightValue = point.rightValue ?? 0.0;

      maxValue = [maxValue, leftValue, rightValue].reduce((a, b) => a > b ? a : b);

      barGroups.add(
        BarChartGroupData(
          x: i,
          barsSpace: 1,
          barRods: [
            BarChartRodData(
              toY: leftValue,
              color: widget.leftColor,
              width: 4,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
            if (widget.showRightData)
              BarChartRodData(
                toY: rightValue,
                color: widget.rightColor,
                width: 4,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
          ],
        ),
      );
    }

    // Calculer la moyenne pour la ligne d'objectif
    final averageGoal = widget.showGoalLine ? _calculateAverage(data) : null;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: widget.fixedMaxY ?? (maxValue * 1.2),
        minY: widget.fixedMinY ?? 0,
        barGroups: barGroups,
        extraLinesData: widget.showGoalLine && averageGoal != null && averageGoal > 0
            ? ExtraLinesData(
                horizontalLines: [
                  HorizontalLine(
                    y: averageGoal,
                    color: Colors.red,
                    strokeWidth: 2,
                    dashArray: [5, 5],
                    label: HorizontalLineLabel(
                      show: true,
                      labelResolver: (line) => 'Moy: ${averageGoal.toStringAsFixed(1)} ${widget.unit}',
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      alignment: Alignment.topRight,
                    ),
                  ),
                ],
              )
            : null,
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            axisNameWidget: Text(
              widget.unit,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
            ),
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 22,
              getTitlesWidget: (value, meta) {
                return Padding(
                  padding: const EdgeInsets.only(right: 4.0),
                  child: Text(
                    value.toInt().toString(),
                    style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w500),
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 22,
              interval: _getBottomTitlesInterval(data.length),
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < data.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      _formatDateLabel(data[index].timestamp),
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
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.grey.withOpacity(0.3)),
        ),
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (group) => Colors.black87,
            tooltipBorderRadius: BorderRadius.circular(8),
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final side = rodIndex == 0 ? 'Gauche' : 'Droite';
              return BarTooltipItem(
                '$side\n${rod.toY.toStringAsFixed(1)} ${widget.unit}',
                TextStyle(
                  color: rod.color,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLineChart(List<ChartDataPoint> data, double chartWidth) {
    if (data.isEmpty) {
      return const Center(child: Text('Aucune donnée disponible'));
    }

    final leftSpots = <FlSpot>[];
    final rightSpots = <FlSpot>[];
    double maxValue = 0.0;

    for (int i = 0; i < data.length; i++) {
      final point = data[i];
      final leftValue = point.leftValue ?? 0.0;
      final rightValue = point.rightValue ?? 0.0;

      leftSpots.add(FlSpot(i.toDouble(), leftValue));
      rightSpots.add(FlSpot(i.toDouble(), rightValue));

      maxValue = [maxValue, leftValue, rightValue].reduce((a, b) => a > b ? a : b);
    }

    // Calculer la moyenne pour la ligne d'objectif
    final averageGoal = widget.showGoalLine ? _calculateAverage(data) : null;

    final lineBars = <LineChartBarData>[
      LineChartBarData(
        spots: leftSpots,
        isCurved: true,
        color: widget.leftColor,
        barWidth: 3,
        isStrokeCapRound: true,
        dotData: FlDotData(
          show: true,
          getDotPainter: (spot, percent, barData, index) {
            return FlDotCirclePainter(
              radius: 3,
              color: widget.leftColor,
              strokeWidth: 2,
              strokeColor: Colors.white,
            );
          },
        ),
        belowBarData: BarAreaData(
          show: true,
          color: widget.leftColor.withOpacity(0.1),
        ),
      ),
      if (widget.showRightData)
        LineChartBarData(
          spots: rightSpots,
          isCurved: true,
          color: widget.rightColor,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 3,
                color: widget.rightColor,
                strokeWidth: 2,
                strokeColor: Colors.white,
            );
          },
        ),
        belowBarData: BarAreaData(
          show: true,
          color: widget.rightColor.withOpacity(0.1),
        ),
      ),
    ];

    // Ajouter les lignes de tendance si activé
    if (widget.showTrendLine) {
      lineBars.addAll(_buildTrendLines(leftSpots, rightSpots));
    }

    return LineChart(
      LineChartData(
        extraLinesData: widget.showGoalLine && averageGoal != null && averageGoal > 0
            ? ExtraLinesData(
                horizontalLines: [
                  HorizontalLine(
                    y: averageGoal,
                    color: Colors.red,
                    strokeWidth: 2,
                    dashArray: [5, 5],
                    label: HorizontalLineLabel(
                      show: true,
                      labelResolver: (line) => 'Moy: ${averageGoal.toStringAsFixed(1)} ${widget.unit}',
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      alignment: Alignment.topRight,
                    ),
                  ),
                ],
              )
            : null,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.grey.withOpacity(0.3),
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            axisNameWidget: Text(
              widget.unit,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
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
              interval: _getBottomTitlesInterval(data.length),
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < data.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      _formatDateLabel(data[index].timestamp),
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
          border: Border.all(color: Colors.grey.withOpacity(0.3)),
        ),
        minY: widget.fixedMinY ?? 0,
        maxY: widget.fixedMaxY ?? (maxValue * 1.2),
        lineBarsData: lineBars,
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (touchedSpot) => Colors.black87,
            tooltipBorderRadius: BorderRadius.circular(8),
            getTooltipItems: (List<LineBarSpot> touchedSpots) {
              return touchedSpots.map((LineBarSpot touchedSpot) {
                final textStyle = TextStyle(
                  color: touchedSpot.bar.color,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                );
                return LineTooltipItem(
                  '${touchedSpot.y.toStringAsFixed(1)} ${widget.unit}',
                  textStyle,
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  /// Calcule et retourne les lignes de tendance (régression linéaire)
  List<LineChartBarData> _buildTrendLines(List<FlSpot> leftSpots, List<FlSpot> rightSpots) {
    final leftTrend = _calculateLinearRegression(leftSpots);
    final rightTrend = _calculateLinearRegression(rightSpots);

    return [
      LineChartBarData(
        spots: leftTrend,
        isCurved: false,
        color: widget.leftColor.withOpacity(0.4),
        barWidth: 2,
        isStrokeCapRound: true,
        dotData: const FlDotData(show: false),
        dashArray: [5, 5],
      ),
      LineChartBarData(
        spots: rightTrend,
        isCurved: false,
        color: widget.rightColor.withOpacity(0.4),
        barWidth: 2,
        isStrokeCapRound: true,
        dotData: const FlDotData(show: false),
        dashArray: [5, 5],
      ),
    ];
  }

  /// Calcule la régression linéaire pour une série de points
  List<FlSpot> _calculateLinearRegression(List<FlSpot> spots) {
    if (spots.length < 2) return spots;

    double sumX = 0, sumY = 0, sumXY = 0, sumX2 = 0;
    final n = spots.length;

    for (final spot in spots) {
      sumX += spot.x;
      sumY += spot.y;
      sumXY += spot.x * spot.y;
      sumX2 += spot.x * spot.x;
    }

    final slope = (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX);
    final intercept = (sumY - slope * sumX) / n;

    // Créer la ligne de tendance avec seulement les points de début et fin
    final firstX = spots.first.x;
    final lastX = spots.last.x;

    return [
      FlSpot(firstX, slope * firstX + intercept),
      FlSpot(lastX, slope * lastX + intercept),
    ];
  }

  String _formatDateLabel(DateTime date) {
    switch (_selectedPeriod) {
      case 'Jour':
        return '${date.hour}h';
      case 'Semaine':
        return DateFormat('E', 'fr').format(date).substring(0, 3);
      case 'Mois':
        // Afficher le mois (Jan, Fév, Mar, etc.)
        return DateFormat('MMM', 'fr').format(date).substring(0, 3);
      default:
        return DateFormat('dd/MM').format(date);
    }
  }

  /// Calcule l'intervalle pour les labels de l'axe X
  double _getBottomTitlesInterval(int dataLength) {
    switch (_selectedPeriod) {
      case 'Jour':
        // Pour 24h, afficher toutes les 4h
        return 4;
      case 'Semaine':
        // Pour 7 jours, afficher tous les jours
        return 1;
      case 'Mois':
        // Pour 12 mois, afficher tous les 2 mois (Jan, Mar, Mai, Jul, Sep, Nov)
        return 2;
      default:
        return (dataLength / 6).ceilToDouble().clamp(1, double.infinity);
    }
  }

  Widget _buildLegend() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Center(
          child: Wrap(
            spacing: constraints.maxWidth > 300 ? 25 : 15,
            runSpacing: 5,
            alignment: WrapAlignment.center,
            children: [
              _buildLegendItem('Gauche', widget.leftColor),
              _buildLegendItem('Droite', widget.rightColor),
            ],
          ),
        );
      },
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

/// Classe pour représenter un point de données du graphique
class ChartDataPoint {
  final DateTime timestamp;
  final double? leftValue;
  final double? rightValue;

  ChartDataPoint({
    required this.timestamp,
    this.leftValue,
    this.rightValue,
  });
}
