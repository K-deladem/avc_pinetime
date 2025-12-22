enum NotificationStrategy { discreet, normal, aggressive }

extension NotificationStrategyExtension on NotificationStrategy {
  String get label {
    switch (this) {
      case NotificationStrategy.discreet:
        return 'Discrète';
      case NotificationStrategy.normal:
        return 'Normale';
      case NotificationStrategy.aggressive:
        return 'Agressive';
    }
  }

  static NotificationStrategy fromLabel(String label) {
    return NotificationStrategy.values.firstWhere((e) => e.label == label);
  }
}