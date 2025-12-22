import 'package:flutter_bloc_app_template/app/app_database.dart';
import 'package:flutter_bloc_app_template/models/app_settings.dart';
import 'package:flutter_bloc_app_template/models/arm_side.dart';
import 'package:flutter_bloc_app_template/models/goal_config.dart';

/// Service pour calculer l'objectif d'équilibre
/// Utilisé par les graphiques et le GoalCheckService
class GoalCalculatorService {
  static final GoalCalculatorService _instance = GoalCalculatorService._internal();
  factory GoalCalculatorService() => _instance;
  GoalCalculatorService._internal();

  final AppDatabase _db = AppDatabase.instance;

  /// Calcule le ratio objectif selon la configuration (fixe ou dynamique)
  /// Retourne un ratio entre 0 et 100
  Future<int> calculateGoalRatio(GoalConfig config, ArmSide affectedSide) async {
    if (config.type == GoalType.fixed) {
      return config.fixedRatio ?? 80;
    } else {
      // Objectif dynamique: calculé sur les X derniers jours avec augmentation de Y%
      final periodDays = config.periodDays ?? 7;
      final dailyIncrease = config.dailyIncreasePercentage ?? 1.0;

      // Calculer la moyenne des ratios sur la période
      final averageRatio = await getAverageRatioForPeriod(periodDays, affectedSide);

      // Appliquer l'augmentation quotidienne
      final targetRatio = averageRatio * (1 + (dailyIncrease / 100));

      // Limiter entre 0 et 100
      return targetRatio.clamp(0, 100).round();
    }
  }

  /// Calcule l'objectif depuis les settings
  Future<int> calculateGoalFromSettings(AppSettings settings) async {
    return await calculateGoalRatio(settings.goalConfig, settings.affectedSide);
  }

  /// Obtient la moyenne des ratios sur une période donnée
  /// Utilisé pour le calcul d'objectif dynamique
  /// IMPORTANT: Utilise la même formule que le graphique d'asymétrie
  Future<double> getAverageRatioForPeriod(int days, ArmSide affectedSide) async {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: days));

    double totalRatio = 0;
    int count = 0;

    // Parcourir chaque jour de la période
    for (int i = 0; i < days; i++) {
      final date = startDate.add(Duration(days: i));

      // Récupérer les stats pour chaque bras
      final leftStats = await _db.getDailyMovementStats('left', date);
      final rightStats = await _db.getDailyMovementStats('right', date);

      final leftMagnitude = leftStats['avgMagnitude'] ?? 0.0;
      final rightMagnitude = rightStats['avgMagnitude'] ?? 0.0;

      // FORMULE IDENTIQUE au ChartDataAdapter (ligne 534, 627):
      // asymmetryRatio = (affectedAvg / total) * 100
      final total = leftMagnitude + rightMagnitude;
      if (total > 0) {
        final affectedMagnitude = affectedSide == ArmSide.left ? leftMagnitude : rightMagnitude;
        final ratio = (affectedMagnitude / total) * 100;
        totalRatio += ratio;
        count++;
      }
    }

    return count > 0 ? totalRatio / count : 50.0;
  }

  /// Calcule le ratio actuel d'équilibre pour aujourd'hui
  /// Utilisé pour comparer avec l'objectif
  /// IMPORTANT: Utilise la même formule que le graphique d'asymétrie
  Future<double> getCurrentRatio(AppSettings settings) async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);

    // Récupérer les données du jour pour les deux bras
    final leftStats = await _db.getDailyMovementStats('left', startOfDay);
    final rightStats = await _db.getDailyMovementStats('right', startOfDay);

    final leftMagnitude = leftStats['avgMagnitude'] ?? 0.0;
    final rightMagnitude = rightStats['avgMagnitude'] ?? 0.0;

    if (leftMagnitude == 0 && rightMagnitude == 0) {
      return 50.0; // Pas de données, équilibre parfait par défaut
    }

    // Calculer le ratio selon le côté affecté
    // FORMULE IDENTIQUE au ChartDataAdapter (ligne 534, 627):
    // asymmetryRatio = (affectedAvg / total) * 100
    final total = leftMagnitude + rightMagnitude;
    final affectedIsLeft = settings.affectedSide == ArmSide.left;
    final affectedMagnitude = affectedIsLeft ? leftMagnitude : rightMagnitude;

    if (total == 0) return 50.0;

    // Ratio: pourcentage du membre affecté par rapport au total
    final ratio = (affectedMagnitude / total) * 100;
    return ratio.clamp(0, 100); // Limiter entre 0 et 100%
  }

  /// Calcule l'objectif pour une date spécifique
  /// Utilisé par le heatmap pour afficher l'objectif quotidien
  ///
  /// Pour un objectif fixe: retourne toujours la même valeur
  /// Pour un objectif dynamique: calcule l'objectif en fonction de la date
  ///   - Calcule la progression depuis la date de référence (aujourd'hui)
  ///   - Applique l'augmentation quotidienne
  Future<double> calculateGoalForDate(
    GoalConfig config,
    ArmSide affectedSide,
    DateTime date,
  ) async {
    if (config.type == GoalType.fixed) {
      // Objectif fixe: même valeur pour tous les jours
      return (config.fixedRatio ?? 80).toDouble();
    } else {
      // Objectif dynamique: calculé selon la date
      final periodDays = config.periodDays ?? 7;
      final dailyIncrease = config.dailyIncreasePercentage ?? 1.0;

      // Date de référence: aujourd'hui
      final today = DateTime.now();
      final todayStart = DateTime(today.year, today.month, today.day);
      final dateStart = DateTime(date.year, date.month, date.day);

      // Calculer le nombre de jours entre la date et aujourd'hui
      final daysDifference = dateStart.difference(todayStart).inDays;

      // Calculer la moyenne de référence (sur les N derniers jours avant la date)
      final referenceEndDate = dateStart;
      final referenceStartDate = referenceEndDate.subtract(Duration(days: periodDays));

      double totalRatio = 0;
      int count = 0;

      for (int i = 0; i < periodDays; i++) {
        final refDate = referenceStartDate.add(Duration(days: i));

        final leftStats = await _db.getDailyMovementStats('left', refDate);
        final rightStats = await _db.getDailyMovementStats('right', refDate);

        final leftMagnitude = leftStats['avgMagnitude'] ?? 0.0;
        final rightMagnitude = rightStats['avgMagnitude'] ?? 0.0;

        final total = leftMagnitude + rightMagnitude;
        if (total > 0) {
          final affectedMagnitude = affectedSide == ArmSide.left ? leftMagnitude : rightMagnitude;
          final ratio = (affectedMagnitude / total) * 100;
          totalRatio += ratio;
          count++;
        }
      }

      final averageRatio = count > 0 ? totalRatio / count : 50.0;

      // Appliquer l'augmentation quotidienne
      // Si la date est dans le futur (+X jours), l'objectif augmente
      // Si la date est dans le passé (-X jours), l'objectif diminue
      final targetRatio = averageRatio * (1 + (dailyIncrease * daysDifference / 100));

      return targetRatio.clamp(0, 100);
    }
  }

}
