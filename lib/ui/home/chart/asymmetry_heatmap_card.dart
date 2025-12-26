// ui/home/chart/asymmetry_heatmap_card.dart

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app_template/app/app_database.dart';
import 'package:flutter_bloc_app_template/generated/l10n.dart';
import 'package:flutter_bloc_app_template/models/arm_side.dart';
import 'package:flutter_bloc_app_template/models/goal_config.dart';
import 'package:flutter_bloc_app_template/service/chart_refresh_notifier.dart';
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

/// Classe pour regrouper les données du heatmap
class _HeatMapData {
  final Map<DateTime, double> asymmetryData;
  final Map<DateTime, double> dailyGoals;

  _HeatMapData({
    required this.asymmetryData,
    required this.dailyGoals,
  });
}

class _AsymmetryHeatMapCardState extends State<AsymmetryHeatMapCard> {
  late int selectedMonth;
  late int selectedYear;
  HeatMapType _selectedType = HeatMapType.magnitude;
  final AppDatabase _db = AppDatabase.instance;
  final GoalCalculatorService _goalCalculator = GoalCalculatorService();

  // Cache intelligent pour éviter les rechargements inutiles
  Future<_HeatMapData>? _cachedFuture;
  String? _lastCacheKey;

  // Abonnement aux notifications de rafraîchissement
  StreamSubscription<ChartRefreshEvent>? _refreshSubscription;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    selectedMonth = now.month;
    selectedYear = now.year;

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

  /// Invalide le cache et force un rechargement
  void _invalidateCache() {
    setState(() {
      _cachedFuture = null;
      _lastCacheKey = null;
    });
  }

  /// Génère une clé unique basée sur les paramètres actuels
  String _generateCacheKey() {
    return '$selectedYear-$selectedMonth-$_selectedType-${widget.affectedSide}';
  }

  /// Retourne le Future en cache ou en crée un nouveau si nécessaire
  Future<_HeatMapData> _getDataFuture() {
    final currentKey = _generateCacheKey();
    if (_cachedFuture != null && _lastCacheKey == currentKey) {
      return _cachedFuture!;
    }
    _lastCacheKey = currentKey;
    _cachedFuture = _loadMonthData();
    return _cachedFuture!;
  }

  @override
  void dispose() {
    _refreshSubscription?.cancel();
    super.dispose();
  }

  /// Charge les données d'asymétrie pour le mois sélectionné
  /// Utilise compute() pour exécuter les calculs lourds dans un isolate
  Future<_HeatMapData> _loadMonthData() async {
    final lastDay = DateTime(selectedYear, selectedMonth + 1, 0);

    // Charger toutes les données du mois en une seule requête (plus efficace)
    final startDate = DateTime(selectedYear, selectedMonth, 1);
    final endDate = DateTime(selectedYear, selectedMonth + 1, 1);

    // Charger les données gauche et droite en parallèle
    final results = await Future.wait([
      _db.getMovementData('left', startDate: startDate, endDate: endDate, limit: 50000),
      _db.getMovementData('right', startDate: startDate, endDate: endDate, limit: 50000),
    ]);

    final leftData = results[0];
    final rightData = results[1];

    // Exécuter les calculs lourds dans un isolate pour éviter ANR
    final fieldName = _selectedType == HeatMapType.magnitude
        ? 'magnitudeActiveTime'
        : 'axisActiveTime';

    final asymmetryData = await compute(
      computeMonthlyAsymmetry,
      HeatMapComputeParams(
        leftData: leftData,
        rightData: rightData,
        fieldName: fieldName,
        isLeftAffected: widget.affectedSide == ArmSide.left,
        year: selectedYear,
        month: selectedMonth,
        lastDayOfMonth: lastDay.day,
      ),
    );

    // Calculer les objectifs quotidiens si une goalConfig est fournie
    // Utiliser Future.wait() pour paralléliser les calculs
    final dailyGoals = <DateTime, double>{};
    if (widget.goalConfig != null) {
      final futures = <Future<MapEntry<DateTime, double>>>[];
      for (int day = 1; day <= lastDay.day; day++) {
        final date = DateTime(selectedYear, selectedMonth, day);
        futures.add(
          _goalCalculator.calculateGoalForDate(
            widget.goalConfig!,
            widget.affectedSide,
            date,
          ).then((goal) => MapEntry(date, goal)),
        );
      }
      // Exécuter tous les calculs en parallèle
      final goalResults = await Future.wait(futures);
      for (final entry in goalResults) {
        dailyGoals[entry.key] = entry.value;
      }
    }

    return _HeatMapData(
      asymmetryData: asymmetryData,
      dailyGoals: dailyGoals,
    );
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
              Expanded(
                child: FutureBuilder<_HeatMapData>(
                  future: _getDataFuture(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Erreur: ${snapshot.error}',
                          style: TextStyle(color: Colors.red.shade400, fontSize: 12),
                        ),
                      );
                    }

                    final data = snapshot.data;
                    final asymmetryData = data?.asymmetryData ?? {};
                    final dailyGoals = data?.dailyGoals ?? {};

                    return Column(
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

                              final asymmetryRatio = asymmetryData[date];
                              final goalForDay = dailyGoals[date];

                              return Expanded(
                                child: AspectRatio(
                                  aspectRatio: 1,
                                  child: GestureDetector(
                                    onTap: () => _showDayDetails(context, date, asymmetryRatio, dailyGoals),
                                    child: Container(
                                      margin: const EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                        color: _getColorForAsymmetry(asymmetryRatio, date: date, dailyGoals: dailyGoals),
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
                                                    color: Colors.white.withValues(alpha: 0.8),
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
                    );
                  },
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
        if (_selectedType != type) {
          setState(() {
            _selectedType = type;
            _cachedFuture = null; // Invalider le cache
          });
        }
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
    final List<String> weekDays = [
      S.of(context).weekdayMon,
      S.of(context).weekdayTue,
      S.of(context).weekdayWed,
      S.of(context).weekdayThu,
      S.of(context).weekdayFri,
      S.of(context).weekdaySat,
      S.of(context).weekdaySun,
    ];
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
            if (v != null && v != selectedMonth) {
              setState(() {
                selectedMonth = v;
                _cachedFuture = null; // Invalider le cache
              });
            }
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
            if (v != null && v != selectedYear) {
              setState(() {
                selectedYear = v;
                _cachedFuture = null; // Invalider le cache
              });
            }
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
        _legendItem(Colors.grey.shade300, S.of(context).noLegendData),
        _legendItem(Colors.red.shade600, S.of(context).unbalanced),
        _legendItem(Colors.orange.shade400, S.of(context).closeToGoal),
        _legendItem(Colors.green.shade600, S.of(context).balancedStatus),
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
  Future<void> _showDayDetails(BuildContext context, DateTime date, double? ratio, Map<DateTime, double> dailyGoals) async {
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

    // Calculer les deltas à partir des valeurs cumulatives
    final String fieldName = _selectedType == HeatMapType.magnitude
        ? 'magnitudeActiveTime'
        : 'axisActiveTime';

    // Calculer le temps actif pour gauche en minutes
    double leftValue = _calculateTotalActiveTime(leftData, fieldName);

    // Calculer le temps actif pour droite en minutes
    double rightValue = _calculateTotalActiveTime(rightData, fieldName);

    final total = leftValue + rightValue;
    final hasData = total > 0;
    final affectedValue = widget.affectedSide == ArmSide.left ? leftValue : rightValue;
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
              S.of(context).typeDisplay(_selectedType == HeatMapType.magnitude ? 'Magnitude' : 'Axis'),
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            if (!hasData)
              Text(
                S.of(context).noDataForDay,
                style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
              )
            else ...[
              _buildDetailRow(S.of(context).left, leftValue, Colors.blueAccent),
              const SizedBox(height: 4),
              Text(
                S.of(context).recordsCount(leftData.length),
                style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 12),
              _buildDetailRow(S.of(context).right, rightValue, Colors.green),
              const SizedBox(height: 4),
              Text(
                S.of(context).recordsCount(rightData.length),
                style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    S.of(context).ratioLabel,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
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
                _getAsymmetryLabel(context, calculatedRatio ?? 50),
                style: TextStyle(
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                  color: _getColorForAsymmetry(calculatedRatio),
                ),
              ),
              // Afficher l'objectif du jour
              if (dailyGoals.containsKey(date)) ...[
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      S.of(context).goalOfTheDay,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade700,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${dailyGoals[date]?.toStringAsFixed(1)}%',
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
                        calculatedRatio >= (dailyGoals[date]! - 5) &&
                        calculatedRatio <= (dailyGoals[date]! + 5)
                            ? Icons.check_circle
                            : Icons.info_outline,
                        size: 16,
                        color: calculatedRatio >= (dailyGoals[date]! - 5) &&
                               calculatedRatio <= (dailyGoals[date]! + 5)
                            ? Colors.green
                            : Colors.orange,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          calculatedRatio >= (dailyGoals[date]! - 5) &&
                          calculatedRatio <= (dailyGoals[date]! + 5)
                              ? S.of(context).goalReached
                              : S.of(context).goalNotReached((calculatedRatio - dailyGoals[date]!).abs().toStringAsFixed(1)),
                          style: TextStyle(
                            fontSize: 11,
                            fontStyle: FontStyle.italic,
                            color: calculatedRatio >= (dailyGoals[date]! - 5) &&
                                   calculatedRatio <= (dailyGoals[date]! + 5)
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
            child: Text(S.of(context).close),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, double valueInMinutes, Color color) {
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
          _formatDuration(valueInMinutes),
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  /// Formate une durée en minutes vers le format 00:00:00
  String _formatDuration(double minutes) {
    if (minutes <= 0) return '00:00:00';

    final totalSeconds = (minutes * 60).round();
    final hours = totalSeconds ~/ 3600;
    final remainingMinutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    // Format: 00:00:00 (heures:minutes:secondes)
    final hoursStr = hours.toString().padLeft(2, '0');
    final minutesStr = remainingMinutes.toString().padLeft(2, '0');
    final secondsStr = seconds.toString().padLeft(2, '0');

    return '$hoursStr:$minutesStr:$secondsStr';
  }

  String _getAsymmetryLabel(BuildContext context, double ratio) {
    if (ratio >= 45 && ratio <= 55) return S.of(context).balancedStatus;
    if (ratio > 55) return S.of(context).rightDominanceStatus;
    if (ratio < 45) return S.of(context).leftDominanceStatus;
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
  Color _getColorForAsymmetry(double? ratio, {DateTime? date, Map<DateTime, double>? dailyGoals}) {
    if (ratio == null) {
      return Colors.grey.shade300;
    }

    // Déterminer l'objectif à utiliser
    double targetRatio;
    if (date != null && dailyGoals != null && dailyGoals.containsKey(date)) {
      // Utiliser l'objectif quotidien spécifique
      targetRatio = dailyGoals[date]!;
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

  /// Récupère la dernière valeur (temps cumulé) en minutes
  /// Les valeurs sont cumulatives depuis le boot de la montre
  double _calculateTotalActiveTime(List<Map<String, dynamic>> data, String fieldName) {
    if (data.isEmpty) return 0.0;

    // Trier par timestamp pour obtenir le plus récent
    final sorted = List<Map<String, dynamic>>.from(data);
    sorted.sort((a, b) {
      final aTime = DateTime.parse(a['createdAt'] as String);
      final bTime = DateTime.parse(b['createdAt'] as String);
      return bTime.compareTo(aTime); // Ordre décroissant (plus récent en premier)
    });

    // Prendre la première valeur (la plus récente)
    final latest = sorted.first;
    final value = latest[fieldName];
    if (value == null) return 0.0;

    final intValue = (value is int) ? value : (value as double).toInt();

    // Valider que la valeur est raisonnable (< 24h en ms)
    if (intValue < 0 || intValue > 86400000) return 0.0;

    return intValue / 60000.0; // Convertir ms en minutes
  }
}

// ============================================================================
// FONCTIONS TOP-LEVEL POUR COMPUTE() - Exécutées dans un isolate séparé
// IMPORTANT: Ces classes/fonctions doivent être publiques (sans _) pour compute()
// ============================================================================

/// Paramètres pour le calcul d'asymétrie mensuelle dans un isolate
class HeatMapComputeParams {
  final List<Map<String, dynamic>> leftData;
  final List<Map<String, dynamic>> rightData;
  final String fieldName;
  final bool isLeftAffected;
  final int year;
  final int month;
  final int lastDayOfMonth;

  HeatMapComputeParams({
    required this.leftData,
    required this.rightData,
    required this.fieldName,
    required this.isLeftAffected,
    required this.year,
    required this.month,
    required this.lastDayOfMonth,
  });
}

/// Fonction top-level pour calculer l'asymétrie mensuelle dans un isolate
/// Utilisée par compute() pour éviter le blocage du thread principal
///
/// Calcule les deltas à partir des valeurs cumulatives par jour
Map<DateTime, double> computeMonthlyAsymmetry(HeatMapComputeParams params) {
  final asymmetryData = <DateTime, double>{};

  // Grouper les données par jour
  final leftByDay = <int, List<Map<String, dynamic>>>{};
  final rightByDay = <int, List<Map<String, dynamic>>>{};

  // Grouper données gauche par jour
  for (final data in params.leftData) {
    final createdAt = data['createdAt'] as String?;
    if (createdAt == null) continue;
    final timestamp = DateTime.parse(createdAt);
    final day = timestamp.day;
    leftByDay.putIfAbsent(day, () => []);
    leftByDay[day]!.add(data);
  }

  // Grouper données droite par jour
  for (final data in params.rightData) {
    final createdAt = data['createdAt'] as String?;
    if (createdAt == null) continue;
    final timestamp = DateTime.parse(createdAt);
    final day = timestamp.day;
    rightByDay.putIfAbsent(day, () => []);
    rightByDay[day]!.add(data);
  }

  // Calculer l'asymétrie pour chaque jour
  for (int day = 1; day <= params.lastDayOfMonth; day++) {
    final leftData = leftByDay[day] ?? [];
    final rightData = rightByDay[day] ?? [];

    if (leftData.isEmpty && rightData.isEmpty) continue;

    // Récupérer la dernière valeur cumulée pour le jour (en minutes)
    final leftTotal = _getLatestValue(leftData, params.fieldName) / 60000.0;
    final rightTotal = _getLatestValue(rightData, params.fieldName) / 60000.0;

    // Calculer le ratio d'asymétrie (membre atteint / total)
    final total = leftTotal + rightTotal;
    if (total > 0) {
      final affectedValue = params.isLeftAffected ? leftTotal : rightTotal;
      final ratio = (affectedValue / total) * 100;
      final dateKey = DateTime(params.year, params.month, day);
      asymmetryData[dateKey] = ratio;
    }
  }

  return asymmetryData;
}

/// Récupère la dernière valeur (temps cumulé) pour une liste de données
/// Les valeurs sont cumulatives depuis le boot de la montre
double _getLatestValue(List<Map<String, dynamic>> data, String fieldName) {
  if (data.isEmpty) return 0.0;

  // Trier par timestamp pour obtenir le plus récent
  final sorted = List<Map<String, dynamic>>.from(data);
  sorted.sort((a, b) {
    final aTime = DateTime.parse(a['createdAt'] as String);
    final bTime = DateTime.parse(b['createdAt'] as String);
    return bTime.compareTo(aTime); // Ordre décroissant (plus récent en premier)
  });

  // Prendre la première valeur (la plus récente)
  final latest = sorted.first;
  final value = latest[fieldName];
  if (value == null) return 0.0;

  final intValue = (value is int) ? value : (value as double).toInt();

  // Valider que la valeur est raisonnable (< 24h en ms)
  if (intValue < 0 || intValue > 86400000) return 0.0;

  return intValue.toDouble();
}
