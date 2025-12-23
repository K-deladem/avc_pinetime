class TimePreferences {
  /// Format d'heure (true = 24h, false = 12h)
  final bool use24HourFormat;

  /// Décalage du fuseau horaire en heures (ex: 2.0 pour UTC+2, -5.0 pour UTC-5)
  final double timezoneOffsetHours;

  /// Utiliser le fuseau horaire du téléphone (true) ou personnalisé (false)
  final bool usePhoneTimezone;

  const TimePreferences({
    this.use24HourFormat = true,
    this.timezoneOffsetHours = 0.0,
    this.usePhoneTimezone = true,
  });

  /// Retourne le décalage en Duration
  Duration get timezoneOffset => Duration(
        minutes: (timezoneOffsetHours * 60).round(),
      );

  Map<String, dynamic> toMap() => {
        'use24HourFormat': use24HourFormat ? 1 : 0,
        'timezoneOffsetHours': timezoneOffsetHours,
        'usePhoneTimezone': usePhoneTimezone ? 1 : 0,
      };

  factory TimePreferences.fromMap(Map<String, dynamic> map) => TimePreferences(
        use24HourFormat: (map['use24HourFormat'] as int? ?? 1) == 1,
        timezoneOffsetHours: (map['timezoneOffsetHours'] as num? ?? 0.0).toDouble(),
        usePhoneTimezone: (map['usePhoneTimezone'] as int? ?? 1) == 1,
      );

  Map<String, dynamic> toJson() => {
        'use24HourFormat': use24HourFormat,
        'timezoneOffsetHours': timezoneOffsetHours,
        'usePhoneTimezone': usePhoneTimezone,
      };

  factory TimePreferences.fromJson(Map<String, dynamic> json) =>
      TimePreferences(
        use24HourFormat: json['use24HourFormat'] as bool? ?? true,
        timezoneOffsetHours: (json['timezoneOffsetHours'] as num? ?? 0.0).toDouble(),
        usePhoneTimezone: json['usePhoneTimezone'] as bool? ?? true,
      );

  TimePreferences copyWith({
    bool? use24HourFormat,
    double? timezoneOffsetHours,
    bool? usePhoneTimezone,
  }) {
    return TimePreferences(
      use24HourFormat: use24HourFormat ?? this.use24HourFormat,
      timezoneOffsetHours: timezoneOffsetHours ?? this.timezoneOffsetHours,
      usePhoneTimezone: usePhoneTimezone ?? this.usePhoneTimezone,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TimePreferences &&
        other.use24HourFormat == use24HourFormat &&
        other.timezoneOffsetHours == timezoneOffsetHours &&
        other.usePhoneTimezone == usePhoneTimezone;
  }

  @override
  int get hashCode {
    return use24HourFormat.hashCode ^
        timezoneOffsetHours.hashCode ^
        usePhoneTimezone.hashCode;
  }

  /// Retourne une description lisible du fuseau horaire
  String get timezoneDescription {
    if (usePhoneTimezone) {
      return 'Fuseau du téléphone';
    }

    final hours = timezoneOffsetHours.floor();
    final minutes = ((timezoneOffsetHours - hours) * 60).abs().round();

    if (timezoneOffsetHours >= 0) {
      return minutes > 0
          ? 'UTC+$hours:${minutes.toString().padLeft(2, '0')}'
          : 'UTC+$hours';
    } else {
      return minutes > 0
          ? 'UTC$hours:${minutes.toString().padLeft(2, '0')}'
          : 'UTC$hours';
    }
  }
}
