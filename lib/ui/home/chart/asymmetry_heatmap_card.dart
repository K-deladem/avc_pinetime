// ui/home/chart/asymmetry_heatmap_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc_app_template/app/app_database.dart';
import 'package:flutter_bloc_app_template/models/arm_side.dart';
import 'package:flutter_bloc_app_template/models/goal_config.dart';
import 'package:flutter_bloc_app_template/service/goal_calculator_service.dart';
import 'package:intl/intl.dart';


/// HeatMap mensuel basé sur l'objectif du ratio d'asymétrie
///
/// Ce widget affiche une carte de chaleur mensuelle montrant
/// si l'objectif d'équilibre gauche-droite est atteint chaque jour
/// L'objectif affiché est spécifique à chaque jour (pour les objectifs dynamiques)
class AsymmetryHeatMapCard extends StatefulWidget {
  /// DÉPRÉCIÉ: Utiliser goalConfig à la place
  /// Objectif de ratio (en pourcentage)
  /// Par défaut 50% = équilibre parfait
  /// Une valeur entre 45-55% est considérée comme équilibrée
  final double targetRatio;

  /// Configuration de l'objectif (fixe ou dynamique)
  /// Si fourni, remplace targetRatio
  final GoalConfig? goalConfig;

  /// Tolérance autour de l'objectif (en pourcentage)
  /// Par défaut ±5%
  final double tolerance;

  final String title;
  final IconData icon;

  /// Membre atteint: "left" pour bras gauche, "right" pour bras droit
  final ArmSide affectedSide;

  const AsymmetryHeatMapCard({
    super.key,
    this.targetRatio = 50.0,
    this.goalConfig,
    this.tolerance = 5.0,
    this.title = "Objectif d'Équilibre Mensuel",
    this.icon = Icons.calendar_month,
    required this.affectedSide,
  });

  @override
  State<AsymmetryHeatMapCard> createState() => _AsymmetryHeatMapCardState();
}

enum HeatMapType { magnitude, axis }

class _AsymmetryHeatMapCardState extends State<AsymmetryHeatMapCard> {
  late int selectedMonth;
  late int selectedYear;
  HeatMapType _selectedType = HeatMapType.magnitude;
  final AppDatabase _db = AppDatabase.instance;
  final GoalCalculatorService _goalCalculator = GoalCalculatorService();

  // Cache pour les données du mois
  Map<DateTime, double> _monthlyAsymmetryData = {};
  // Cache pour les objectifs quotidiens
  Map<DateTime, double> _dailyGoals = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    selectedMonth = now.month;
    selectedYear = now.year;
    _loadMonthData();
  }

  /// Charge les données d'asymétrie pour le mois sélectionné
  Future<void> _loadMonthData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final lastDay = DateTime(selectedYear, selectedMonth + 1, 0);

      final asymmetryData = <DateTime, double>{};
      final detailedData = <DateTime, Map<String, double>>{};

      // Charger les données pour chaque jour du mois
      for (int day = 1; day <= lastDay.day; day++) {
        final date = DateTime(selectedYear, selectedMonth, day);
        final endDate = date.add(const Duration(days: 1));

        // Récupérer les données movement pour les deux bras
        final leftData = await _db.getMovementData(
          'left',
          startDate: date,
          endDate: endDate,
          limit: 10000,
        );

        final rightData = await _db.getMovementData(
          'right',
          startDate: date,
          endDate: endDate,
          limit: 10000,
        );

        if (leftData.isNotEmpty || rightData.isNotEmpty) {
          // Calculer les valeurs moyennes selon le type de métrique
          double leftValue = 0.0;
          double rightValue = 0.0;

          final String fieldName = _selectedType == HeatMapType.magnitude
              ? 'magnitudeActiveTime'
              : 'axisActiveTime';

          // Calculer les valeurs pour gauche (moyenne en minutes)
          if (leftData.isNotEmpty) {
            final values = leftData
                .where((d) => d[fieldName] != null)
                .map((d) {
                  final val = d[fieldName];
                  final doubleVal = (val is int) ? val.toDouble() : (val as double);
                  return doubleVal / 60.0; // Convertir secondes en minutes
                })
                .toList();

            if (values.isNotEmpty) {
              leftValue = values.reduce((a, b) => a + b) / values.length;
            }
          }

          // Calculer les valeurs pour droite (moyenne en minutes)
          if (rightData.isNotEmpty) {
            final values = rightData
                .where((d) => d[fieldName] != null)
                .map((d) {
                  final val = d[fieldName];
                  final doubleVal = (val is int) ? val.toDouble() : (val as double);
                  return doubleVal / 60.0; // Convertir secondes en minutes
                })
                .toList();

            if (values.isNotEmpty) {
              rightValue = values.reduce((a, b) => a + b) / values.length;
            }
          }

          // Calculer le ratio d'asymétrie (membre atteint / total)
          final total = leftValue + rightValue;
          if (total > 0) {
            final affectedValue = widget.affectedSide == 'left' ? leftValue : rightValue;
            final ratio = (affectedValue / total) * 100;
            final dateKey = DateTime(selectedYear, selectedMonth, day);
            asymmetryData[dateKey] = ratio;
            detailedData[dateKey] = {
              'left': leftValue,
              'right': rightValue,
              'ratio': ratio,
            };
          }
        }
      }

      // Calculer les objectifs quotidiens si une goalConfig est fournie
      final dailyGoals = <DateTime, double>{};
      if (widget.goalConfig != null) {
        for (int day = 1; day <= lastDay.day; day++) {
          final date = DateTime(selectedYear, selectedMonth, day);
          final goalForDate = await _goalCalculator.calculateGoalForDate(
            widget.goalConfig!,
            widget.affectedSide,
            date,
          );
          dailyGoals[date] = goalForDate;
        }
      }

      if (mounted) {
        setState(() {
          _monthlyAsymmetryData = asymmetryData;
          _dailyGoals = dailyGoals;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      debugPrint('Erreur lors du chargement des données: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final int daysInMonth = DateUtils.getDaysInMonth(selectedYear, selectedMonth);
    final DateTime firstDay = DateTime(selectedYear, selectedMonth, 1);
    final int firstWeekday = (firstDay.weekday % 7); // Dimanche = 0

    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 20),
              _buildWeekdayLabels(context),
              const SizedBox(height: 4),
              if (_isLoading)
                const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                )
              else
                Expanded(
                  child: Column(
                    children: List.generate(6, (rowIndex) {
                      return Expanded(
                        child: Row(
                          children: List.generate(7, (colIndex) {
                            int cellIndex = rowIndex * 7 + colIndex;
                            if (cellIndex < firstWeekday ||
                                (cellIndex - firstWeekday + 1) > daysInMonth) {
                              return const Expanded(child: SizedBox.shrink());
                            }
                            int day = cellIndex - firstWeekday + 1;
                            DateTime date = DateTime(selectedYear, selectedMonth, day);

                            final asymmetryRatio = _monthlyAsymmetryData[date];
                            final goalForDay = _dailyGoals[date];

                            return Expanded(
                              child: AspectRatio(
                                aspectRatio: 1,
                                child: GestureDetector(
                                  onTap: () => _showDayDetails(context, date, asymmetryRatio),
                                  child: Container(
                                    margin: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color: _getColorForAsymmetry(asymmetryRatio, date: date),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(2),
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            // Numéro du jour
                                            Text(
                                              "$day",
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: asymmetryRatio != null
                                                    ? Colors.white
                                                    : Colors.black45,
                                                fontWeight: FontWeight.bold,
                                                height: 1.0,
                                              ),
                                            ),
                                            // Ratio réel
                                            if (asymmetryRatio != null)
                                              Text(
                                                "${asymmetryRatio.toStringAsFixed(0)}%",
                                                style: const TextStyle(
                                                  fontSize: 8,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w500,
                                                  height: 1.0,
                                                ),
                                              ),
                                            // Objectif
                                            if (goalForDay != null)
                                              Text(
                                                "↑${goalForDay.toStringAsFixed(0)}%",
                                                style: TextStyle(
                                                  fontSize: 7,
                                                  color: Colors.white.withOpacity(0.8),
                                                  fontWeight: FontWeight.normal,
                                                  height: 1.0,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      );
                    }),
                  ),
                ),
              const SizedBox(height: 12),
              _buildLegend(),
            ],
          ),
        );
      },
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
                      fontSize: 11,
                    ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              Text(
                "${DateFormat.MMMM('fr_FR').format(DateTime(selectedYear, selectedMonth))} $selectedYear",
                style: const TextStyle(fontSize: 9),
              ),
            ],
          ),
        ),
      Column(children: [
        _buildTypeToggle(context),
        const SizedBox(height: 8),
        _buildDropdowns(),
      ],)
      ],
    );
  }

  Widget _buildTypeToggle(BuildContext context) {
    return Container(
      width: 160,
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
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: _buildToggleButton(
              context,
              'Magnitude',
              HeatMapType.magnitude,
              Icons.timeline,
            ),
          ),
          const SizedBox(width: 2),
          Flexible(
            child: _buildToggleButton(
              context,
              'Axis',
              HeatMapType.axis,
              Icons.multiline_chart,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton(
    BuildContext context,
    String label,
    HeatMapType type,
    IconData icon,
  ) {
    final isSelected = _selectedType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedType = type;
        });
        _loadMonthData();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.6)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected
                  ? Colors.white
                  : Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
            ),
            const SizedBox(width: 3),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: isSelected
                      ? Colors.white
                      : Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekdayLabels(BuildContext context) {
    final List<String> weekDays = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    return Row(
      children: weekDays.map((label) {
        return Expanded(
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDropdowns() {
    return Row(
      children: [
        _styledDropdown(
          selectedMonth,
          (v) {
            setState(() {
              selectedMonth = v!;
            });
            _loadMonthData();
          },
          List.generate(12, (i) => i + 1).map((m) {
            return DropdownMenuItem(
              value: m,
              child: Text(
                DateFormat.MMMM('fr_FR').format(DateTime(0, m)),
                style: TextStyle(
                  fontSize: 10,
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(width: 6),
        _styledDropdown(
          selectedYear,
          (v) {
            setState(() {
              selectedYear = v!;
            });
            _loadMonthData();
          },
          List.generate(5, (i) => DateTime.now().year - 2 + i).map((y) {
            return DropdownMenuItem(
              value: y,
              child: Text(
                "$y",
                style: TextStyle(
                  fontSize: 10,
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _styledDropdown<T>(
    T value,
    void Function(T?) onChanged,
    List<DropdownMenuItem<T>> items,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          isDense: true,
          value: value,
          onChanged: onChanged,
          items: items,
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Wrap(
      spacing: 12,
      runSpacing: 4,
      alignment: WrapAlignment.center,
      children: [
        _legendItem(Colors.grey.shade300, "Aucune"),
        _legendItem(Colors.red.shade600, "Déséquilibré"),
        _legendItem(Colors.orange.shade400, "Proche"),
        _legendItem(Colors.green.shade600, "Équilibré"),
      ],
    );
  }

  Widget _legendItem(Color color, String label) {
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
        Text(label, style: const TextStyle(fontSize: 9)),
      ],
    );
  }

  /// Affiche les détails d'une journée dans un dialog
  Future<void> _showDayDetails(BuildContext context, DateTime date, double? ratio) async {
    // Charger les données détaillées du jour
    final endDate = date.add(const Duration(days: 1));

    final leftData = await _db.getMovementData(
      'left',
      startDate: date,
      endDate: endDate,
      limit: 10000,
    );

    final rightData = await _db.getMovementData(
      'right',
      startDate: date,
      endDate: endDate,
      limit: 10000,
    );

    final String fieldName = _selectedType == HeatMapType.magnitude
        ? 'magnitudeActiveTime'
        : 'axisActiveTime';

    // Calculer les valeurs pour gauche (moyenne en minutes)
    double leftValue = 0.0;
    if (leftData.isNotEmpty) {
      final values = leftData
          .where((d) => d[fieldName] != null)
          .map((d) {
            final val = d[fieldName];
            final doubleVal = (val is int) ? val.toDouble() : (val as double);
            return doubleVal / 60.0; // Convertir secondes en minutes
          })
          .toList();

      if (values.isNotEmpty) {
        leftValue = values.reduce((a, b) => a + b) / values.length;
      }
    }

    // Calculer les valeurs pour droite (moyenne en minutes)
    double rightValue = 0.0;
    if (rightData.isNotEmpty) {
      final values = rightData
          .where((d) => d[fieldName] != null)
          .map((d) {
            final val = d[fieldName];
            final doubleVal = (val is int) ? val.toDouble() : (val as double);
            return doubleVal / 60.0; // Convertir secondes en minutes
          })
          .toList();

      if (values.isNotEmpty) {
        rightValue = values.reduce((a, b) => a + b) / values.length;
      }
    }

    final total = leftValue + rightValue;
    final hasData = total > 0;
    final affectedValue = widget.affectedSide == 'left' ? leftValue : rightValue;
    final calculatedRatio = hasData ? (affectedValue / total) * 100 : null;

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          DateFormat('EEEE d MMMM yyyy', 'fr_FR').format(date),
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Type: ${_selectedType == HeatMapType.magnitude ? 'Magnitude' : 'Axis'}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            if (!hasData)
              const Text(
                'Aucune donnée disponible pour ce jour',
                style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
              )
            else ...[
              _buildDetailRow('Gauche', leftValue, Colors.blueAccent),
              const SizedBox(height: 4),
              Text(
                '${leftData.length} enregistrements',
                style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 12),
              _buildDetailRow('Droite', rightValue, Colors.green),
              const SizedBox(height: 4),
              Text(
                '${rightData.length} enregistrements',
                style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Ratio:',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getColorForAsymmetry(calculatedRatio),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${calculatedRatio?.toStringAsFixed(1)}%',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _getAsymmetryLabel(calculatedRatio ?? 50),
                style: TextStyle(
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                  color: _getColorForAsymmetry(calculatedRatio),
                ),
              ),
              // Afficher l'objectif du jour
              if (_dailyGoals.containsKey(date)) ...[
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Objectif du jour:',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade700,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${_dailyGoals[date]?.toStringAsFixed(1)}%',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Indicateur de réussite
                if (calculatedRatio != null)
                  Row(
                    children: [
                      Icon(
                        calculatedRatio >= (_dailyGoals[date]! - 5) &&
                        calculatedRatio <= (_dailyGoals[date]! + 5)
                            ? Icons.check_circle
                            : Icons.info_outline,
                        size: 16,
                        color: calculatedRatio >= (_dailyGoals[date]! - 5) &&
                               calculatedRatio <= (_dailyGoals[date]! + 5)
                            ? Colors.green
                            : Colors.orange,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          calculatedRatio >= (_dailyGoals[date]! - 5) &&
                          calculatedRatio <= (_dailyGoals[date]! + 5)
                              ? 'Objectif atteint'
                              : 'Objectif non atteint (écart: ${(calculatedRatio - _dailyGoals[date]!).abs().toStringAsFixed(1)}%)',
                          style: TextStyle(
                            fontSize: 11,
                            fontStyle: FontStyle.italic,
                            color: calculatedRatio >= (_dailyGoals[date]! - 5) &&
                                   calculatedRatio <= (_dailyGoals[date]! + 5)
                                ? Colors.green
                                : Colors.orange,
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, double value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        Text(
          '${value.toStringAsFixed(1)} min',
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
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

  /// Détermine la couleur en fonction du ratio d'asymétrie
  ///
  /// - Aucune donnée: gris
  /// - Équilibré (dans la tolérance): vert
  /// - Proche (hors tolérance mais < 2x tolérance): orange
  /// - Déséquilibré (> 2x tolérance): rouge
  ///
  /// Utilise l'objectif quotidien si disponible (pour les objectifs dynamiques)
  Color _getColorForAsymmetry(double? ratio, {DateTime? date}) {
    if (ratio == null) {
      return Colors.grey.shade300;
    }

    // Déterminer l'objectif à utiliser
    double targetRatio;
    if (date != null && _dailyGoals.containsKey(date)) {
      // Utiliser l'objectif quotidien spécifique
      targetRatio = _dailyGoals[date]!;
    } else {
      // Utiliser l'objectif par défaut
      targetRatio = widget.targetRatio;
    }

    // Calculer la distance par rapport à l'objectif
    final distance = (ratio - targetRatio).abs();

    if (distance <= widget.tolerance) {
      // Dans la tolérance = équilibré
      return Color.lerp(
        Colors.green.shade400,
        Colors.green.shade700,
        (widget.tolerance - distance) / widget.tolerance,
      )!;
    } else if (distance <= widget.tolerance * 2) {
      // Proche de la tolérance
      return Color.lerp(
        Colors.orange.shade300,
        Colors.orange.shade600,
        (distance - widget.tolerance) / widget.tolerance,
      )!;
    } else {
      // Déséquilibré
      return Color.lerp(
        Colors.red.shade400,
        Colors.red.shade800,
        ((distance - widget.tolerance * 2) / (50 - widget.tolerance * 2)).clamp(0.0, 1.0),
      )!;
    }
  }
}
