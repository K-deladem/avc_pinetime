enum GoalType {
  fixed,
  dynamic;

  String get label {
    switch (this) {
      case GoalType.fixed:
        return 'Fixe';
      case GoalType.dynamic:
        return 'Dynamique';
    }
  }
}

extension GoalTypeExtension on GoalType {
  static GoalType fromLabel(String label) {
    switch (label.toLowerCase()) {
      case 'fixe':
        return GoalType.fixed;
      case 'dynamique':
        return GoalType.dynamic;
      default:
        return GoalType.fixed;
    }
  }
}

class GoalConfig {
  final GoalType type;
  final int? fixedRatio;
  final int? periodDays;
  final double? dailyIncreasePercentage;

  const GoalConfig({
    required this.type,
    this.fixedRatio,
    this.periodDays,
    this.dailyIncreasePercentage,
  });

  const GoalConfig.fixed({required int ratio})
      : type = GoalType.fixed,
        fixedRatio = ratio,
        periodDays = null,
        dailyIncreasePercentage = null;

  const GoalConfig.dynamic({
    required int days,
    required double increasePercentage,
  })  : type = GoalType.dynamic,
        fixedRatio = null,
        periodDays = days,
        dailyIncreasePercentage = increasePercentage;

  Map<String, dynamic> toMap() => {
        'goalType': type.label,
        'fixedRatio': fixedRatio,
        'periodDays': periodDays,
        'dailyIncreasePercentage': dailyIncreasePercentage,
      };

  factory GoalConfig.fromMap(Map<String, dynamic> map) {
    final type = GoalTypeExtension.fromLabel(map['goalType'] as String? ?? 'Fixe');

    if (type == GoalType.fixed) {
      return GoalConfig.fixed(ratio: map['fixedRatio'] as int? ?? 80);
    } else {
      return GoalConfig.dynamic(
        days: map['periodDays'] as int? ?? 7,
        increasePercentage: (map['dailyIncreasePercentage'] as num?)?.toDouble() ?? 1.0,
      );
    }
  }

  Map<String, dynamic> toJson() => {
        'goalType': type.name,
        'fixedRatio': fixedRatio,
        'periodDays': periodDays,
        'dailyIncreasePercentage': dailyIncreasePercentage,
      };

  factory GoalConfig.fromJson(Map<String, dynamic> json) {
    final typeStr = json['goalType'] as String? ?? 'fixed';
    final type = typeStr == 'dynamic' ? GoalType.dynamic : GoalType.fixed;

    if (type == GoalType.fixed) {
      return GoalConfig.fixed(ratio: json['fixedRatio'] as int? ?? 80);
    } else {
      return GoalConfig.dynamic(
        days: json['periodDays'] as int? ?? 7,
        increasePercentage: (json['dailyIncreasePercentage'] as num?)?.toDouble() ?? 1.0,
      );
    }
  }

  GoalConfig copyWith({
    GoalType? type,
    int? fixedRatio,
    int? periodDays,
    double? dailyIncreasePercentage,
  }) {
    return GoalConfig(
      type: type ?? this.type,
      fixedRatio: fixedRatio ?? this.fixedRatio,
      periodDays: periodDays ?? this.periodDays,
      dailyIncreasePercentage: dailyIncreasePercentage ?? this.dailyIncreasePercentage,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GoalConfig &&
        other.type == type &&
        other.fixedRatio == fixedRatio &&
        other.periodDays == periodDays &&
        other.dailyIncreasePercentage == dailyIncreasePercentage;
  }

  @override
  int get hashCode {
    return Object.hash(
      type,
      fixedRatio,
      periodDays,
      dailyIncreasePercentage,
    );
  }
}
