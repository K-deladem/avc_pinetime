import 'package:flutter_bloc_app_template/app/app_database.dart';
import 'package:flutter_bloc_app_template/models/app_settings.dart';
import 'package:flutter_bloc_app_template/models/arm_side.dart';
import 'package:flutter_bloc_app_template/models/goal_config.dart';

/// Service pour calculer l'objectif d'équilibre
/// Utilisé par les graphiques et le GoalCheckService
/// OPTIMISÉ: Utilise des requêtes SQL agrégées pour éviter N+1 queries
class GoalCalculatorService {
  static final GoalCalculatorService _instance = GoalCalculatorService._internal();
  factory GoalCalculatorService() => _instance;
  GoalCalculatorService._internal();

  final AppDatabase _db = AppDatabase.instance;

  // Cache mémoire pour éviter les requêtes DB répétées
  // Clé: "startDate_endDate" -> Stats de la période
  Map<String, Map<String, Map<String, dynamic>>>? _periodStatsCache;
  String? _periodStatsCacheKey;
  DateTime? _cacheTimestamp;
  static const Duration _cacheDuration = Duration(minutes: 5);

  /// Nettoie le cache s'il est trop vieux
  void _cleanCacheIfNeeded() {
    if (_cacheTimestamp != null &&
        DateTime.now().difference(_cacheTimestamp!) > _cacheDuration) {
      _periodStatsCache = null;
      _periodStatsCacheKey = null;
      _cacheTimestamp = null;
    }
  }

  /// Invalide le cache manuellement (appelé après insertion de données)
  void invalidateCache() {
    _periodStatsCache = null;
    _periodStatsCacheKey = null;
    _cacheTimestamp = null;
  }

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
  /// IMPORTANT: Utilise totalMagnitudeActiveTime (somme des deltas en ms)
  /// car les valeurs de la montre sont cumulatives
  /// OPTIMISÉ: Une seule requête SQL avec GROUP BY au lieu de N requêtes
  Future<double> getAverageRatioForPeriod(int days, ArmSide affectedSide) async {
    final endDate = DateTime.now();
    final startDate = DateTime(endDate.year, endDate.month, endDate.day)
        .subtract(Duration(days: days));
    final endOfToday = DateTime(endDate.year, endDate.month, endDate.day)
        .add(const Duration(days: 1));

    // Une seule requête SQL pour toute la période
    final periodStats = await _getOrFetchPeriodStats(startDate, endOfToday);

    // Calculer le ratio moyen basé sur le temps actif (deltas sommés)
    double totalRatio = 0;
    int count = 0;

    for (final dayStats in periodStats.values) {
      // Utiliser totalMagnitudeActiveTime (somme des deltas en ms)
      final leftRaw = dayStats['left']?['totalMagnitudeActiveTime'];
      final rightRaw = dayStats['right']?['totalMagnitudeActiveTime'];
      final leftActiveTime = (leftRaw is num) ? leftRaw.toDouble() : 0.0;
      final rightActiveTime = (rightRaw is num) ? rightRaw.toDouble() : 0.0;

      // Formule asymétrie: (membre atteint / total) * 100
      final total = leftActiveTime + rightActiveTime;
      if (total > 0) {
        final affectedActiveTime = affectedSide == ArmSide.left ? leftActiveTime : rightActiveTime;
        final ratio = (affectedActiveTime / total) * 100;
        totalRatio += ratio;
        count++;
      }
    }

    return count > 0 ? totalRatio / count : 50.0;
  }

  /// Récupère les stats de période depuis le cache ou la DB
  /// OPTIMISÉ: Une seule requête SQL avec GROUP BY
  Future<Map<String, Map<String, Map<String, dynamic>>>> _getOrFetchPeriodStats(
    DateTime startDate,
    DateTime endDate,
  ) async {
    _cleanCacheIfNeeded();

    final cacheKey = '${startDate.toIso8601String()}_${endDate.toIso8601String()}';

    // Vérifier le cache
    if (_periodStatsCacheKey == cacheKey && _periodStatsCache != null) {
      return _periodStatsCache!;
    }

    // Pas dans le cache, faire UNE SEULE requête SQL
    final stats = await _db.getMovementStatsForPeriod(startDate, endDate);

    // Mettre en cache
    _periodStatsCache = stats;
    _periodStatsCacheKey = cacheKey;
    _cacheTimestamp = DateTime.now();

    return stats;
  }

  /// Helper pour récupérer les stats d'un jour spécifique
  /// Utilise le cache de période si disponible
  Future<Map<String, Map<String, dynamic>>> _getDayStats(DateTime date) async {
    final dayKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

    // Vérifier si on a déjà les stats en cache
    if (_periodStatsCache != null && _periodStatsCache!.containsKey(dayKey)) {
      return _periodStatsCache![dayKey]!;
    }

    // Sinon, charger juste ce jour
    final results = await Future.wait([
      _db.getDailyMovementStats('left', date),
      _db.getDailyMovementStats('right', date),
    ]);

    return {
      'left': results[0],
      'right': results[1],
    };
  }

  /// Calcule le ratio actuel d'équilibre pour aujourd'hui
  /// Utilisé pour comparer avec l'objectif
  /// IMPORTANT: Utilise totalMagnitudeActiveTime (somme des deltas en ms)
  /// car les valeurs de la montre sont cumulatives
  Future<double> getCurrentRatio(AppSettings settings) async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);

    // Récupérer les données du jour pour les deux bras
    final dayStats = await _getDayStats(startOfDay);

    // Utiliser totalMagnitudeActiveTime (somme des deltas en ms)
    final leftRaw = dayStats['left']?['totalMagnitudeActiveTime'];
    final rightRaw = dayStats['right']?['totalMagnitudeActiveTime'];
    final leftActiveTime = (leftRaw is num) ? leftRaw.toDouble() : 0.0;
    final rightActiveTime = (rightRaw is num) ? rightRaw.toDouble() : 0.0;

    if (leftActiveTime == 0 && rightActiveTime == 0) {
      return 50.0; // Pas de données, équilibre parfait par défaut
    }

    // Calculer le ratio selon le côté affecté
    // Formule asymétrie: (membre atteint / total) * 100
    final total = leftActiveTime + rightActiveTime;
    final affectedIsLeft = settings.affectedSide == ArmSide.left;
    final affectedActiveTime = affectedIsLeft ? leftActiveTime : rightActiveTime;

    if (total == 0) return 50.0;

    // Ratio: pourcentage du membre affecté par rapport au total
    final ratio = (affectedActiveTime / total) * 100;
    return ratio.clamp(0, 100); // Limiter entre 0 et 100%
  }

  /// Calcule l'objectif pour une date spécifique
  /// Utilisé par le heatmap pour afficher l'objectif quotidien
  ///
  /// Pour un objectif fixe: retourne toujours la même valeur
  /// Pour un objectif dynamique: calcule l'objectif en fonction de la date
  ///   - Calcule la progression depuis la date de référence (aujourd'hui)
  ///   - Applique l'augmentation quotidienne
  /// IMPORTANT: Utilise totalMagnitudeActiveTime (somme des deltas en ms)
  /// OPTIMISÉ: Une seule requête SQL avec GROUP BY au lieu de N requêtes
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

      // UNE SEULE requête SQL pour toute la période
      final periodStats = await _getOrFetchPeriodStats(referenceStartDate, referenceEndDate);

      double totalRatio = 0;
      int count = 0;

      for (final dayStats in periodStats.values) {
        // Utiliser totalMagnitudeActiveTime (somme des deltas en ms)
        final leftRaw = dayStats['left']?['totalMagnitudeActiveTime'];
        final rightRaw = dayStats['right']?['totalMagnitudeActiveTime'];
        final leftActiveTime = (leftRaw is num) ? leftRaw.toDouble() : 0.0;
        final rightActiveTime = (rightRaw is num) ? rightRaw.toDouble() : 0.0;

        final total = leftActiveTime + rightActiveTime;
        if (total > 0) {
          final affectedActiveTime = affectedSide == ArmSide.left ? leftActiveTime : rightActiveTime;
          final ratio = (affectedActiveTime / total) * 100;
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
