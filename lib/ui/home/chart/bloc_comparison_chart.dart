import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../bloc/chart/chart.dart';
import '../../../generated/l10n.dart';
import '../../../models/arm_side.dart';
import 'reusable_comparison_chart.dart';

/// Widget de graphique de comparaison utilisant ChartBloc
/// Remplace ReusableComparisonChart avec gestion d'état centralisée
class BlocComparisonChart extends StatefulWidget {
  final String title;
  final IconData icon;
  final ChartDataType dataType;
  final Color leftColor;
  final Color rightColor;
  final String unit;
  final ChartMode defaultMode;
  final bool showModeToggle;
  final bool showTrendLine;
  final List<String> availablePeriods;
  final double? fixedMaxY;
  final double? fixedMinY;
  final ArmSide? affectedSide;
  final bool showGoalLine;
  final bool showRightData;

  const BlocComparisonChart({
    super.key,
    required this.title,
    required this.icon,
    required this.dataType,
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
    this.showGoalLine = false,
    this.showRightData = true,
  });

  @override
  State<BlocComparisonChart> createState() => _BlocComparisonChartState();
}

class _BlocComparisonChartState extends State<BlocComparisonChart> {
  late ChartMode _currentMode;
  String _selectedPeriod = 'Semaine';

  @override
  void initState() {
    super.initState();
    _currentMode = widget.defaultMode;
    if (!widget.availablePeriods.contains(_selectedPeriod)) {
      _selectedPeriod = widget.availablePeriods.first;
    }

    // Charger les données initiales
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    context.read<ChartBloc>().add(LoadChartData(
          dataType: widget.dataType,
          period: _selectedPeriod,
          affectedSide: widget.affectedSide,
        ));
  }

  void _changePeriod(String newPeriod) {
    setState(() {
      _selectedPeriod = newPeriod;
    });
    context.read<ChartBloc>().add(ChangePeriod(
          dataType: widget.dataType,
          newPeriod: newPeriod,
        ));
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
            BlocBuilder<ChartBloc, ChartState>(
              buildWhen: (previous, current) {
                final prevState = previous.getChartState(widget.dataType);
                final currState = current.getChartState(widget.dataType);
                return prevState != currState;
              },
              builder: (context, state) {
                final chartState = state.getChartState(widget.dataType);

                if (chartState.isLoading) {
                  return const SizedBox(
                    height: 270,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (chartState.hasError) {
                  return SizedBox(
                    height: 270,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline,
                              color: Theme.of(context).colorScheme.error),
                          const SizedBox(height: 8),
                          Text(S.of(context).errorLoadingData),
                          TextButton(
                            onPressed: _loadData,
                            child: Text(S.of(context).retry),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (!chartState.hasData) {
                  return SizedBox(
                    height: 270,
                    child: Center(
                      child: Text(S.of(context).noDataAvailable),
                    ),
                  );
                }

                return LayoutBuilder(
                  builder: (context, constraints) {
                    return SizedBox(
                      height: 270,
                      child: RepaintBoundary(
                        child: _currentMode == ChartMode.bar
                            ? _buildBarChart(chartState.data, constraints.maxWidth)
                            : _buildLineChart(chartState.data, constraints.maxWidth),
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
                S.of(context).periodLabel(_getPeriodLabel(context)),
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
          _currentMode = _currentMode == ChartMode.bar
              ? ChartMode.line
              : ChartMode.bar;
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
              _changePeriod(newValue);
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
      return Center(child: Text(S.of(context).noDataAvailable));
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
              final side = rodIndex == 0 ? S.of(context).left : S.of(context).right;
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
      return Center(child: Text(S.of(context).noDataAvailable));
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

    final denominator = n * sumX2 - sumX * sumX;
    if (denominator == 0) return spots;

    final slope = (n * sumXY - sumX * sumY) / denominator;
    final intercept = (sumY - slope * sumX) / n;

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
        return DateFormat('MMM', 'fr').format(date).substring(0, 3);
      default:
        return DateFormat('dd/MM').format(date);
    }
  }

  double _getBottomTitlesInterval(int dataLength) {
    switch (_selectedPeriod) {
      case 'Jour':
        return 4;
      case 'Semaine':
        return 1;
      case 'Mois':
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
              _buildLegendItem(S.of(context).left, widget.leftColor),
              if (widget.showRightData)
                _buildLegendItem(S.of(context).right, widget.rightColor),
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

  String _getPeriodLabel(BuildContext context) {
    switch (_selectedPeriod) {
      case 'Jour':
        return S.of(context).periodDay;
      case 'Semaine':
        return S.of(context).periodWeek;
      case 'Mois':
        return S.of(context).periodMonth;
      default:
        return _selectedPeriod;
    }
  }
}
