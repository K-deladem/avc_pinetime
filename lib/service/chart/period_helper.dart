/// Helper class for period-based date calculations
class PeriodHelper {
  PeriodHelper._();

  /// Get start date based on period
  static DateTime getStartDate(String period, DateTime? selectedDate) {
    final now = selectedDate ?? DateTime.now();
    switch (period) {
      case 'Jour':
        return DateTime(now.year, now.month, now.day);
      case 'Semaine':
        final weekday = now.weekday;
        final monday = now.subtract(Duration(days: weekday - 1));
        return DateTime(monday.year, monday.month, monday.day);
      case 'Mois':
        // Pour "Mois", afficher toute l'année (12 mois)
        return DateTime(now.year, 1, 1);
      default:
        return DateTime(now.year, now.month, now.day);
    }
  }

  /// Get end date based on period
  static DateTime getEndDate(String period, DateTime? selectedDate) {
    final start = getStartDate(period, selectedDate);
    switch (period) {
      case 'Jour':
        return start.add(const Duration(days: 1));
      case 'Semaine':
        return start.add(const Duration(days: 7));
      case 'Mois':
        // Pour "Mois", fin de l'année (12 mois)
        return DateTime(start.year + 1, 1, 1);
      default:
        return start.add(const Duration(days: 1));
    }
  }

  /// Group date by period for aggregation
  static DateTime groupDateByPeriod(DateTime date, String period) {
    switch (period) {
      case 'Jour':
        return DateTime(date.year, date.month, date.day, date.hour);
      case 'Semaine':
        // Grouper par jour pour la vue semaine
        return DateTime(date.year, date.month, date.day);
      case 'Mois':
        // Grouper par mois pour la vue année (12 mois)
        return DateTime(date.year, date.month, 1);
      default:
        return DateTime(date.year, date.month, date.day);
    }
  }
}
