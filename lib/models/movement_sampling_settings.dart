/// Configuration de l'échantillonnage des données de mouvement
/// Permet de réduire le volume de données stockées
class MovementSamplingSettings {
  /// Mode d'échantillonnage
  final MovementSamplingMode mode;

  /// Intervalle d'échantillonnage en millisecondes (pour mode interval)
  /// Ex: 1000 = garder 1 échantillon par seconde
  final int intervalMs;

  /// Seuil de changement significatif en g (pour mode threshold)
  /// Ex: 0.5 = ne stocker que si la magnitude change de plus de 0.5g
  final double changeThreshold;

  /// Nombre maximum d'échantillons à garder par flush
  final int maxSamplesPerFlush;

  /// Activer l'agrégation (moyenne sur l'intervalle au lieu du dernier échantillon)
  final bool useAggregation;

  /// Nombre d'enregistrements par unité de temps (pour mode recordsPerTimeUnit)
  final int recordsCount;

  /// Unité de temps pour le mode recordsPerTimeUnit
  final SamplingTimeUnit timeUnit;

  const MovementSamplingSettings({
    this.mode = MovementSamplingMode.recordsPerTimeUnit, // Par défaut: nouveau mode
    this.intervalMs = 1000, // 1 seconde par défaut
    this.changeThreshold = 0.5,
    this.maxSamplesPerFlush = 60,
    this.useAggregation = false,
    this.recordsCount = 4, // 4 enregistrements par défaut (1 toutes les 15 min)
    this.timeUnit = SamplingTimeUnit.hour, // Par heure par défaut
  });

  /// Préréglage: Économie maximale (1 échantillon / 5 secondes)
  static const MovementSamplingSettings economyMax = MovementSamplingSettings(
    mode: MovementSamplingMode.interval,
    intervalMs: 5000,
    maxSamplesPerFlush: 20,
  );

  /// Préréglage: Économie (1 échantillon / 2 secondes)
  static const MovementSamplingSettings economy = MovementSamplingSettings(
    mode: MovementSamplingMode.interval,
    intervalMs: 2000,
    maxSamplesPerFlush: 30,
  );

  /// Préréglage: Normal (1 échantillon / seconde)
  static const MovementSamplingSettings normal = MovementSamplingSettings(
    mode: MovementSamplingMode.interval,
    intervalMs: 1000,
    maxSamplesPerFlush: 60,
  );

  /// Préréglage: Précis (1 échantillon / 500ms)
  static const MovementSamplingSettings precise = MovementSamplingSettings(
    mode: MovementSamplingMode.interval,
    intervalMs: 500,
    maxSamplesPerFlush: 120,
  );

  /// Préréglage: Tout garder (pas de filtrage)
  static const MovementSamplingSettings all = MovementSamplingSettings(
    mode: MovementSamplingMode.all,
    intervalMs: 100,
    maxSamplesPerFlush: 300,
  );

  /// Calcule l'intervalle en ms pour le mode recordsPerTimeUnit
  int get calculatedIntervalMs {
    if (mode != MovementSamplingMode.recordsPerTimeUnit || recordsCount <= 0) {
      return intervalMs;
    }

    int unitMs;
    switch (timeUnit) {
      case SamplingTimeUnit.second:
        unitMs = 1000;
        break;
      case SamplingTimeUnit.minute:
        unitMs = 60 * 1000;
        break;
      case SamplingTimeUnit.hour:
        unitMs = 60 * 60 * 1000;
        break;
    }
    return unitMs ~/ recordsCount;
  }

  /// Description lisible du mode actuel
  String get description {
    switch (mode) {
      case MovementSamplingMode.all:
        return 'Tout enregistrer (~600/min)';
      case MovementSamplingMode.interval:
        if (intervalMs >= 1000) {
          final seconds = intervalMs ~/ 1000;
          final perMinute = 60 ~/ seconds;
          return '1 échantillon / ${seconds}s (~$perMinute/min)';
        } else {
          final perSecond = 1000 ~/ intervalMs;
          return '$perSecond échantillons/s (~${perSecond * 60}/min)';
        }
      case MovementSamplingMode.threshold:
        return 'Sur changement > ${changeThreshold}g';
      case MovementSamplingMode.aggregate:
        final seconds = intervalMs ~/ 1000;
        return 'Moyenne sur ${seconds}s';
      case MovementSamplingMode.recordsPerTimeUnit:
        final unitLabel = _getTimeUnitLabel(timeUnit);
        final perMinute = _calculatePerMinute();
        return '$recordsCount enregistrement${recordsCount > 1 ? 's' : ''}/$unitLabel (~$perMinute/min)';
    }
  }

  String _getTimeUnitLabel(SamplingTimeUnit unit) {
    switch (unit) {
      case SamplingTimeUnit.second:
        return 'seconde';
      case SamplingTimeUnit.minute:
        return 'minute';
      case SamplingTimeUnit.hour:
        return 'heure';
    }
  }

  int _calculatePerMinute() {
    switch (timeUnit) {
      case SamplingTimeUnit.second:
        return recordsCount * 60;
      case SamplingTimeUnit.minute:
        return recordsCount;
      case SamplingTimeUnit.hour:
        return (recordsCount / 60).ceil();
    }
  }

  /// Nom court du préréglage
  String get presetName {
    if (mode == MovementSamplingMode.all) return 'Maximum';
    if (mode == MovementSamplingMode.recordsPerTimeUnit) {
      return 'Par unité de temps';
    }
    if (intervalMs >= 5000) return 'Économie Max';
    if (intervalMs >= 2000) return 'Économie';
    if (intervalMs >= 1000) return 'Normal';
    if (intervalMs >= 500) return 'Précis';
    return 'Personnalisé';
  }

  Map<String, dynamic> toMap() => {
        'movementSamplingMode': mode.index,
        'movementSamplingIntervalMs': intervalMs,
        'movementSamplingChangeThreshold': changeThreshold,
        'movementSamplingMaxPerFlush': maxSamplesPerFlush,
        'movementSamplingUseAggregation': useAggregation ? 1 : 0,
        'movementSamplingRecordsCount': recordsCount,
        'movementSamplingTimeUnit': timeUnit.index,
      };

  factory MovementSamplingSettings.fromMap(Map<String, dynamic> map) {
    // Gérer la migration: si le mode est 4 (recordsPerTimeUnit) mais qu'il n'existe pas encore
    // dans les anciennes versions, utiliser le mode par défaut
    final modeIndex = map['movementSamplingMode'] as int? ?? MovementSamplingMode.recordsPerTimeUnit.index;
    final mode = modeIndex < MovementSamplingMode.values.length
        ? MovementSamplingMode.values[modeIndex]
        : MovementSamplingMode.recordsPerTimeUnit;

    return MovementSamplingSettings(
      mode: mode,
      intervalMs: map['movementSamplingIntervalMs'] as int? ?? 1000,
      changeThreshold: (map['movementSamplingChangeThreshold'] as num? ?? 0.5).toDouble(),
      maxSamplesPerFlush: map['movementSamplingMaxPerFlush'] as int? ?? 60,
      useAggregation: (map['movementSamplingUseAggregation'] as int? ?? 0) == 1,
      recordsCount: map['movementSamplingRecordsCount'] as int? ?? 4,
      timeUnit: SamplingTimeUnit.values[map['movementSamplingTimeUnit'] as int? ?? SamplingTimeUnit.hour.index],
    );
  }

  Map<String, dynamic> toJson() => {
        'movementSamplingMode': mode.index,
        'movementSamplingIntervalMs': intervalMs,
        'movementSamplingChangeThreshold': changeThreshold,
        'movementSamplingMaxPerFlush': maxSamplesPerFlush,
        'movementSamplingUseAggregation': useAggregation,
        'movementSamplingRecordsCount': recordsCount,
        'movementSamplingTimeUnit': timeUnit.index,
      };

  factory MovementSamplingSettings.fromJson(Map<String, dynamic> json) {
    final modeIndex = json['movementSamplingMode'] as int? ?? MovementSamplingMode.recordsPerTimeUnit.index;
    final mode = modeIndex < MovementSamplingMode.values.length
        ? MovementSamplingMode.values[modeIndex]
        : MovementSamplingMode.recordsPerTimeUnit;

    return MovementSamplingSettings(
      mode: mode,
      intervalMs: json['movementSamplingIntervalMs'] as int? ?? 1000,
      changeThreshold: (json['movementSamplingChangeThreshold'] as num? ?? 0.5).toDouble(),
      maxSamplesPerFlush: json['movementSamplingMaxPerFlush'] as int? ?? 60,
      useAggregation: json['movementSamplingUseAggregation'] as bool? ?? false,
      recordsCount: json['movementSamplingRecordsCount'] as int? ?? 4,
      timeUnit: SamplingTimeUnit.values[json['movementSamplingTimeUnit'] as int? ?? SamplingTimeUnit.hour.index],
    );
  }

  MovementSamplingSettings copyWith({
    MovementSamplingMode? mode,
    int? intervalMs,
    double? changeThreshold,
    int? maxSamplesPerFlush,
    bool? useAggregation,
    int? recordsCount,
    SamplingTimeUnit? timeUnit,
  }) {
    return MovementSamplingSettings(
      mode: mode ?? this.mode,
      intervalMs: intervalMs ?? this.intervalMs,
      changeThreshold: changeThreshold ?? this.changeThreshold,
      maxSamplesPerFlush: maxSamplesPerFlush ?? this.maxSamplesPerFlush,
      useAggregation: useAggregation ?? this.useAggregation,
      recordsCount: recordsCount ?? this.recordsCount,
      timeUnit: timeUnit ?? this.timeUnit,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MovementSamplingSettings &&
        other.mode == mode &&
        other.intervalMs == intervalMs &&
        other.changeThreshold == changeThreshold &&
        other.maxSamplesPerFlush == maxSamplesPerFlush &&
        other.useAggregation == useAggregation &&
        other.recordsCount == recordsCount &&
        other.timeUnit == timeUnit;
  }

  @override
  int get hashCode {
    return mode.hashCode ^
        intervalMs.hashCode ^
        changeThreshold.hashCode ^
        maxSamplesPerFlush.hashCode ^
        useAggregation.hashCode ^
        recordsCount.hashCode ^
        timeUnit.hashCode;
  }
}

/// Modes d'échantillonnage des données de mouvement
enum MovementSamplingMode {
  /// Tout garder (pas de filtrage)
  all,

  /// Garder un échantillon par intervalle de temps
  interval,

  /// Garder uniquement lors de changements significatifs
  threshold,

  /// Calculer une moyenne sur l'intervalle
  aggregate,

  /// Nombre d'enregistrements par unité de temps (heure/minute/seconde)
  recordsPerTimeUnit,
}

/// Unité de temps pour le mode recordsPerTimeUnit
enum SamplingTimeUnit {
  /// Par seconde
  second,

  /// Par minute
  minute,

  /// Par heure
  hour,
}
