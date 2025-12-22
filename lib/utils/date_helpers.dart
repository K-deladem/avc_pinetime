// utils/date_helpers.dart

/// Utilitaires pour les calculs de dates dans les graphiques
class DateHelpers {
  /// Retourne la date de début pour une période donnée
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
        return DateTime(now.year, now.month, 1);
      default:
        return DateTime(now.year, now.month, now.day);
    }
  }

  /// Retourne la date de fin pour une période donnée
  static DateTime getEndDate(String period, DateTime? selectedDate) {
    final start = getStartDate(period, selectedDate);
    switch (period) {
      case 'Jour':
        return start.add(const Duration(days: 1));
      case 'Semaine':
        return start.add(const Duration(days: 7));
      case 'Mois':
        return DateTime(start.year, start.month + 1, 1);
      default:
        return start.add(const Duration(days: 1));
    }
  }

  /// Groupe une date selon la période (par heure, jour ou mois)
  static DateTime groupDateByPeriod(DateTime date, String period) {
    switch (period) {
      case 'Jour':
        // Grouper par heure
        return DateTime(date.year, date.month, date.day, date.hour);
      case 'Semaine':
        // Grouper par jour
        return DateTime(date.year, date.month, date.day);
      case 'Mois':
        // Grouper par mois
        return DateTime(date.year, date.month, 1);
      default:
        return DateTime(date.year, date.month, date.day);
    }
  }

  /// Retourne un label formaté pour une date selon la période
  static String formatDateLabel(DateTime date, String period) {
    switch (period) {
      case 'Jour':
        return '${date.hour}h';
      case 'Semaine':
        return _getWeekdayShort(date.weekday);
      case 'Mois':
        return _getMonthShort(date.month);
      default:
        return '${date.day}/${date.month}';
    }
  }

  /// Retourne l'abréviation du jour de la semaine
  static String _getWeekdayShort(int weekday) {
    const weekdays = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    return weekdays[weekday - 1];
  }

  /// Retourne l'abréviation du mois
  static String _getMonthShort(int month) {
    const months = [
      'Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Jun',
      'Jul', 'Aoû', 'Sep', 'Oct', 'Nov', 'Déc'
    ];
    return months[month - 1];
  }
}
