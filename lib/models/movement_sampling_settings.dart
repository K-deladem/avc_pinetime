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

  const MovementSamplingSettings({
    this.mode = MovementSamplingMode.interval,
    this.intervalMs = 1000, // 1 seconde par défaut
    this.changeThreshold = 0.5,
    this.maxSamplesPerFlush = 60,
    this.useAggregation = false,
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
    }
  }

  /// Nom court du préréglage
  String get presetName {
    if (mode == MovementSamplingMode.all) return 'Maximum';
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
      };

  factory MovementSamplingSettings.fromMap(Map<String, dynamic> map) {
    return MovementSamplingSettings(
      mode: MovementSamplingMode.values[map['movementSamplingMode'] as int? ?? 0],
      intervalMs: map['movementSamplingIntervalMs'] as int? ?? 1000,
      changeThreshold: (map['movementSamplingChangeThreshold'] as num? ?? 0.5).toDouble(),
      maxSamplesPerFlush: map['movementSamplingMaxPerFlush'] as int? ?? 60,
      useAggregation: (map['movementSamplingUseAggregation'] as int? ?? 0) == 1,
    );
  }

  Map<String, dynamic> toJson() => {
        'movementSamplingMode': mode.index,
        'movementSamplingIntervalMs': intervalMs,
        'movementSamplingChangeThreshold': changeThreshold,
        'movementSamplingMaxPerFlush': maxSamplesPerFlush,
        'movementSamplingUseAggregation': useAggregation,
      };

  factory MovementSamplingSettings.fromJson(Map<String, dynamic> json) {
    return MovementSamplingSettings(
      mode: MovementSamplingMode.values[json['movementSamplingMode'] as int? ?? 0],
      intervalMs: json['movementSamplingIntervalMs'] as int? ?? 1000,
      changeThreshold: (json['movementSamplingChangeThreshold'] as num? ?? 0.5).toDouble(),
      maxSamplesPerFlush: json['movementSamplingMaxPerFlush'] as int? ?? 60,
      useAggregation: json['movementSamplingUseAggregation'] as bool? ?? false,
    );
  }

  MovementSamplingSettings copyWith({
    MovementSamplingMode? mode,
    int? intervalMs,
    double? changeThreshold,
    int? maxSamplesPerFlush,
    bool? useAggregation,
  }) {
    return MovementSamplingSettings(
      mode: mode ?? this.mode,
      intervalMs: intervalMs ?? this.intervalMs,
      changeThreshold: changeThreshold ?? this.changeThreshold,
      maxSamplesPerFlush: maxSamplesPerFlush ?? this.maxSamplesPerFlush,
      useAggregation: useAggregation ?? this.useAggregation,
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
        other.useAggregation == useAggregation;
  }

  @override
  int get hashCode {
    return mode.hashCode ^
        intervalMs.hashCode ^
        changeThreshold.hashCode ^
        maxSamplesPerFlush.hashCode ^
        useAggregation.hashCode;
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
}
