// ui/home/chart/asymmetry_gauge_chart.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc_app_template/models/arm_side.dart';
import 'package:flutter_bloc_app_template/service/chart_data_adapter.dart';
import 'dart:math' as math;

/// Widget de gauge chart (speedometer) pour afficher l'asymétrie gauche-droite
///
/// Ce widget affiche un demi-cercle avec une aiguille indiquant:
/// - 0% = dominance gauche forte
/// - 50% = équilibré
/// - 100% = dominance droite forte
///
/// Couleurs adaptées au membre atteint (depuis le centre):
/// - Vert (45-55%) = équilibré (optimal)
/// - Jaune = du centre vers le membre NON-atteint (bon, utilisation du bras sain)
/// - Rouge = du centre vers le membre atteint (mauvais, surcharge du bras malade)
class AsymmetryGaugeChart extends StatefulWidget {
  final String title;
  final IconData icon;

  /// Fonction qui récupère les données d'asymétrie Magnitude
  final Future<List<AsymmetryDataPoint>> Function(String period, DateTime? selectedDate, {ArmSide affectedSide}) magnitudeDataProvider;

  /// Fonction qui récupère les données d'asymétrie Axis
  final Future<List<AsymmetryDataPoint>> Function(String period, DateTime? selectedDate, {ArmSide affectedSide}) axisDataProvider;

  /// Unité de mesure (ex: 'min', 'pas')
  final String unit;

  /// Membre atteint: "left" pour bras gauche, "right" pour bras droit
  final ArmSide affectedSide;

  /// Périodes disponibles
  final List<String> availablePeriods;

  /// Valeur de l'objectif à afficher (ratio en %)
  final double? goalValue;

  const AsymmetryGaugeChart({
    super.key,
    required this.title,
    required this.icon,
    required this.magnitudeDataProvider,
    required this.axisDataProvider,
    required this.unit,
    required this.affectedSide,
    this.availablePeriods = const ['Jour', 'Semaine', 'Mois'],
    this.goalValue,
  });

  @override
  State<AsymmetryGaugeChart> createState() => _AsymmetryGaugeChartState();
}

enum AsymmetryType { magnitude, axis }

class _AsymmetryGaugeChartState extends State<AsymmetryGaugeChart> {
  String _selectedPeriod = 'Semaine';
  DateTime? _selectedDate;
  AsymmetryType _selectedType = AsymmetryType.magnitude;

  @override
  void initState() {
    super.initState();
    if (!widget.availablePeriods.contains(_selectedPeriod)) {
      _selectedPeriod = widget.availablePeriods.first;
    }
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(context),
          const SizedBox(height: 30),
          FutureBuilder<List<AsymmetryDataPoint>>(
            key: ValueKey('$_selectedPeriod-${_selectedDate?.toIso8601String()}-$_selectedType'),
            future: _selectedType == AsymmetryType.magnitude
                ? widget.magnitudeDataProvider(_selectedPeriod, _selectedDate, affectedSide: widget.affectedSide)
                : widget.axisDataProvider(_selectedPeriod, _selectedDate, affectedSide: widget.affectedSide),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  height: 220,
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const SizedBox(
                  height: 220,
                  child: Center(child: Text('Aucune donnée disponible')),
                );
              }

              // Calculer la moyenne d'asymétrie sur la période
              final avgAsymmetry = _calculateAverageAsymmetry(snapshot.data!);
              final latestPoint = snapshot.data!.last;

              return Column(
                children: [
                  SizedBox(
                    height: 220,
                    child: _GaugeWidget(
                      value: avgAsymmetry,
                      leftValue: latestPoint.leftValue,
                      rightValue: latestPoint.rightValue,
                      unit: widget.unit,
                      affectedSide: widget.affectedSide,
                      goalValue: widget.goalValue,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildStats(latestPoint, avgAsymmetry),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(widget.icon, size: 15, color: Colors.white),
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
                      fontSize: 8,
                    ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              Text(
                'Période: $_selectedPeriod',
                style: const TextStyle(fontSize: 8),
              ),
            ],
          ),
        ),
        _buildTypeToggle(context),
        const SizedBox(width: 8),
        _buildPeriodSelector(context),
      ],
    );
  }

  Widget _buildTypeToggle(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleButton(
            context,
            'Magnitude',
            AsymmetryType.magnitude,
            Icons.timeline,
          ),
          const SizedBox(width: 2),
          _buildToggleButton(
            context,
            'Axis',
            AsymmetryType.axis,
            Icons.multiline_chart,
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton(
    BuildContext context,
    String label,
    AsymmetryType type,
    IconData icon,
  ) {
    final isSelected = _selectedType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedType = type;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.6)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected
                  ? Colors.white
                  : Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: isSelected
                    ? Colors.white
                    : Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodSelector(BuildContext context) {
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
            if (newValue != null) {
              setState(() {
                _selectedPeriod = newValue;
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

  Widget _buildStats(AsymmetryDataPoint point, double avgAsymmetry) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(
            label: 'Gauche',
            value: '${point.leftValue.toStringAsFixed(1)} ${widget.unit}',
            color: Colors.blueAccent,
          ),
          _StatItem(
            label: 'Droite',
            value: '${point.rightValue.toStringAsFixed(1)} ${widget.unit}',
            color: Colors.green,
          ),
          _StatItem(
            label: 'Équilibre',
            value: point.asymmetryCategory.label,
            color: point.asymmetryCategory.color,
          ),
        ],
      ),
    );
  }

  double _calculateAverageAsymmetry(List<AsymmetryDataPoint> data) {
    if (data.isEmpty) return 50.0;
    final sum = data.fold<double>(0.0, (sum, point) => sum + point.asymmetryRatio);
    return sum / data.length;
  }
}

/// Widget de statistique individuel
class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: color,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

/// Widget personnalisé pour dessiner le gauge
/// Widget personnalisé pour dessiner le gauge
class _GaugeWidget extends StatelessWidget {
  final double value; // 0-100
  final double leftValue;
  final double rightValue;
  final String unit;
  final ArmSide? affectedSide; // "left" ou "right"
  final double? goalValue; // Objectif en %

  const _GaugeWidget({
    required this.value,
    required this.leftValue,
    required this.rightValue,
    required this.unit,
    this.affectedSide,
    this.goalValue,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              // CustomPaint avec taille explicite
              Positioned.fill(
                child: CustomPaint(
                  painter: _GaugePainter(
                    value: value,
                    affectedSide: affectedSide,
                    goalValue: goalValue,
                  ),
                ),
              ),

            ],
          ),
        ),
        const SizedBox(height: 8),
        // Afficher le pourcentage et le label en dessous du gauge
        Text(
          '${value.toStringAsFixed(1)}%',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _getAsymmetryLabel(value),
          style: TextStyle(
            fontSize: 11,
            color: _getAsymmetryColor(value),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _getAsymmetryLabel(double ratio) {
    if (ratio >= 45 && ratio <= 55) return 'Équilibré';
    if (ratio > 55) return 'Dominance droite';
    if (ratio < 45) return 'Dominance gauche';
    return '';
  }

  Color _getAsymmetryColor(double ratio) {
    // Zone verte au centre (45-55%)
    if (ratio >= 45 && ratio <= 55) {
      return Colors.green;
    }
    // Zone jaune côté bras NON-atteint (bon)
    else if (affectedSide == 'left' && ratio > 55) {
      // Membre gauche atteint : jaune à droite (bras NON-atteint = bon)
      return Colors.orange;
    } else if (affectedSide == 'right' && ratio < 45) {
      // Membre droit atteint : jaune à gauche (bras NON-atteint = bon)
      return Colors.orange;
    }
    // Zone rouge côté bras atteint (mauvais, surcharge)
    else {
      return Colors.red;
    }
  }
}

/// Painter personnalisé pour dessiner le gauge
class _GaugePainter extends CustomPainter {
  final double value;
  final ArmSide? affectedSide; // "left" ou "right"
  final double? goalValue; // Objectif en %

  _GaugePainter({
    required this.value,
    this.affectedSide,
    this.goalValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height); // centre en bas
    final radius = size.width / 2 * 0.9; // rayon légèrement inférieur à la moitié de la largeur

    // Debug: log de la configuration
    debugPrint('AsymmetryGauge: affectedSide=$affectedSide, value=$value');

    _drawBackgroundArc(canvas, center, radius);
    _drawMarkers(canvas, center, radius);
    if (goalValue != null) {
      _drawGoalMarker(canvas, center, radius);
    }
    _drawNeedle(canvas, center, radius);
    _drawCenter(canvas, center);
  }

  void _drawBackgroundArc(Canvas canvas, Offset center, double radius) {
    const startAngle = math.pi;
    const sweepAngle = math.pi;

    Paint getPaint(double startPercent, double endPercent) {
      Color color;
      final midPercent = (startPercent + endPercent) / 2;

      // Calculer les zones selon l'objectif (ou 50% par défaut)
      final targetPercent = (goalValue ?? 50.0) / 100.0;
      const tolerance = 0.05; // ±5%

      final greenMin = (targetPercent - tolerance).clamp(0.0, 1.0);
      final greenMax = (targetPercent + tolerance).clamp(0.0, 1.0);

      // Zone verte (optimal) : autour de l'objectif (±5%)
      if (midPercent >= greenMin && midPercent <= greenMax) {
        color = Colors.green;
      }
      // Zone jaune (acceptable) : entre l'objectif et l'équilibre parfait (50%)
      else if ((targetPercent < 0.5 && midPercent > greenMax && midPercent <= 0.5) ||
               (targetPercent > 0.5 && midPercent >= 0.5 && midPercent < greenMin)) {
        color = Colors.yellow;
      }
      // Zone orange (à surveiller) : s'éloigne de l'objectif mais pas encore critique
      else if (affectedSide == ArmSide.left && midPercent > 0.5 && midPercent < 0.65) {
        // Membre gauche atteint : orange à droite (utilise trop le bras sain)
        color = Colors.orange;
      } else if (affectedSide == ArmSide.right && midPercent < 0.5 && midPercent > 0.35) {
        // Membre droit atteint : orange à gauche (utilise trop le bras sain)
        color = Colors.orange;
      }
      // Zone rouge (critique) : très loin de l'objectif
      else {
        color = Colors.red;
      }

      return Paint()
        ..color = color.withOpacity(0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 20
        ..strokeCap = StrokeCap.round;
    }

    // Dessiner plusieurs segments pour une transition fluide
    final numSegments = 20;
    final segmentSize = 1.0 / numSegments;

    for (int i = 0; i < numSegments; i++) {
      final startPercent = i * segmentSize;
      final endPercent = (i + 1) * segmentSize;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle + sweepAngle * startPercent,
        sweepAngle * segmentSize,
        false,
        getPaint(startPercent, endPercent),
      );
    }
  }

  void _drawMarkers(Canvas canvas, Offset center, double radius) {
    const startAngle = math.pi;
    const sweepAngle = math.pi;

    final markerPaint = Paint()
      ..color = Colors.grey.shade600
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    final markers = [0.0, 0.25, 0.5, 0.75, 1.0];
    final labels = ['G', '25', '50', '75', 'D'];

    for (int i = 0; i < markers.length; i++) {
      final angle = startAngle + sweepAngle * markers[i];
      final markerStart = Offset(
        center.dx + (radius - 10) * math.cos(angle),
        center.dy + (radius - 10) * math.sin(angle),
      );
      final markerEnd = Offset(
        center.dx + (radius + 10) * math.cos(angle),
        center.dy + (radius + 10) * math.sin(angle),
      );
      canvas.drawLine(markerStart, markerEnd, markerPaint);

      textPainter.text = TextSpan(
        text: labels[i],
        style: TextStyle(
          color: Colors.grey.shade700,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      );
      textPainter.layout();
      final labelOffset = Offset(
        center.dx + (radius + 25) * math.cos(angle) - textPainter.width / 2,
        center.dy + (radius + 25) * math.sin(angle) - textPainter.height / 2,
      );
      textPainter.paint(canvas, labelOffset);
    }
  }

  void _drawNeedle(Canvas canvas, Offset center, double radius) {
    const startAngle = math.pi;
    const sweepAngle = math.pi;
    final needleAngle = startAngle + sweepAngle * (value / 100);

    // Peinture principale de l'aiguille (rouge vif)
    final needlePaint = Paint()
      ..color = Colors.red.shade700
      ..style = PaintingStyle.fill
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    // Peinture pour le contour de l'aiguille (noir)
    final needleOutlinePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final needleLength = radius * 0.9;
    final needleTip = Offset(
      center.dx + needleLength * math.cos(needleAngle),
      center.dy + needleLength * math.sin(needleAngle),
    );

    final needleBase1 = Offset(
      center.dx + 10 * math.cos(needleAngle + math.pi / 2),
      center.dy + 10 * math.sin(needleAngle + math.pi / 2),
    );
    final needleBase2 = Offset(
      center.dx + 10 * math.cos(needleAngle - math.pi / 2),
      center.dy + 10 * math.sin(needleAngle - math.pi / 2),
    );

    final path = Path()
      ..moveTo(needleTip.dx, needleTip.dy)
      ..lineTo(needleBase1.dx, needleBase1.dy)
      ..lineTo(needleBase2.dx, needleBase2.dy)
      ..close();

    // Dessiner l'aiguille avec remplissage et contour
    canvas.drawPath(path, needlePaint);
    canvas.drawPath(path, needleOutlinePaint);
  }

  void _drawCenter(Canvas canvas, Offset center) {
    final centerPaint = Paint()..color = Colors.white..style = PaintingStyle.fill;
    final centerBorderPaint = Paint()
      ..color = Colors.grey.shade700
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(center, 10, centerPaint);
    canvas.drawCircle(center, 10, centerBorderPaint);
  }

  /// Dessine un marqueur vert pour l'objectif
  void _drawGoalMarker(Canvas canvas, Offset center, double radius) {
    const startAngle = math.pi;
    const sweepAngle = math.pi;

    // Convertir la valeur d'objectif (0-100) en angle
    final goalPercent = goalValue! / 100.0;
    final goalAngle = startAngle + sweepAngle * goalPercent;

    // Calculer la position du marqueur
    final markerX = center.dx + radius * math.cos(goalAngle);
    final markerY = center.dy + radius * math.sin(goalAngle);

    // Dessiner un cercle vert pour le marqueur d'objectif
    final markerPaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(markerX, markerY),
      8,
      markerPaint,
    );

    // Bordure blanche pour le contraste
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(
      Offset(markerX, markerY),
      8,
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(_GaugePainter oldDelegate) {
    return oldDelegate.value != value ||
           oldDelegate.affectedSide != affectedSide ||
           oldDelegate.goalValue != goalValue;
  }
}


