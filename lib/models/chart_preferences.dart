class ChartPreferences {
  final bool showAsymmetryGauge; // Asymétrie Magnitude & Axis
  final bool showBatteryComparison; // Comparaison Batterie
  final bool
      showAsymmetryHeatmap; // Heatmap Magnitude/Axis (Objectif Équilibre)
  final bool showAsymmetryRatioChart; // Graphique Ratio Asymétrie (Magnitude/Axe avec Objectif)
  final bool showStepsComparison; // Comparaison Pas

  const ChartPreferences({
    this.showAsymmetryGauge = true,
    this.showBatteryComparison = true,
    this.showAsymmetryHeatmap = true,
    this.showAsymmetryRatioChart = true,
    this.showStepsComparison = true,
  });

  Map<String, dynamic> toMap() => {
        'showAsymmetryGauge': showAsymmetryGauge ? 1 : 0,
        'showBatteryComparison': showBatteryComparison ? 1 : 0,
        'showAsymmetryHeatmap': showAsymmetryHeatmap ? 1 : 0,
        'showAsymmetryRatioChart': showAsymmetryRatioChart ? 1 : 0,
        'showStepsComparison': showStepsComparison ? 1 : 0,
      };

  factory ChartPreferences.fromMap(Map<String, dynamic> map) =>
      ChartPreferences(
        showAsymmetryGauge: (map['showAsymmetryGauge'] as int? ?? 1) == 1,
        showBatteryComparison: (map['showBatteryComparison'] as int? ?? 1) == 1,
        showAsymmetryHeatmap: (map['showAsymmetryHeatmap'] as int? ?? 1) == 1,
        showAsymmetryRatioChart: (map['showAsymmetryRatioChart'] as int? ?? 1) == 1,
        showStepsComparison: (map['showStepsComparison'] as int? ?? 1) == 1,
      );

  Map<String, dynamic> toJson() => {
        'showAsymmetryGauge': showAsymmetryGauge,
        'showBatteryComparison': showBatteryComparison,
        'showAsymmetryHeatmap': showAsymmetryHeatmap,
        'showAsymmetryRatioChart': showAsymmetryRatioChart,
        'showStepsComparison': showStepsComparison,
      };

  factory ChartPreferences.fromJson(Map<String, dynamic> json) =>
      ChartPreferences(
        showAsymmetryGauge: json['showAsymmetryGauge'] as bool? ?? true,
        showBatteryComparison: json['showBatteryComparison'] as bool? ?? true,
        showAsymmetryHeatmap: json['showAsymmetryHeatmap'] as bool? ?? true,
        showAsymmetryRatioChart: json['showAsymmetryRatioChart'] as bool? ?? true,
        showStepsComparison: json['showStepsComparison'] as bool? ?? true,
      );

  ChartPreferences copyWith({
    bool? showAsymmetryGauge,
    bool? showBatteryComparison,
    bool? showAsymmetryHeatmap,
    bool? showAsymmetryRatioChart,
    bool? showStepsComparison,
  }) {
    return ChartPreferences(
      showAsymmetryGauge: showAsymmetryGauge ?? this.showAsymmetryGauge,
      showBatteryComparison:
          showBatteryComparison ?? this.showBatteryComparison,
      showAsymmetryHeatmap: showAsymmetryHeatmap ?? this.showAsymmetryHeatmap,
      showAsymmetryRatioChart: showAsymmetryRatioChart ?? this.showAsymmetryRatioChart,
      showStepsComparison: showStepsComparison ?? this.showStepsComparison,
    );
  }

  /// Retourne le nombre de graphiques activés
  int get enabledCount {
    int count = 0;
    if (showAsymmetryGauge) count++;
    if (showBatteryComparison) count++;
    if (showAsymmetryHeatmap) count++;
    if (showAsymmetryRatioChart) count++;
    if (showStepsComparison) count++;
    return count;
  }

  /// Vérifie si au moins un graphique est activé
  bool get hasAnyEnabled => enabledCount > 0;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ChartPreferences &&
        other.showAsymmetryGauge == showAsymmetryGauge &&
        other.showBatteryComparison == showBatteryComparison &&
        other.showAsymmetryHeatmap == showAsymmetryHeatmap &&
        other.showAsymmetryRatioChart == showAsymmetryRatioChart &&
        other.showStepsComparison == showStepsComparison;
  }

  @override
  int get hashCode {
    return showAsymmetryGauge.hashCode ^
        showBatteryComparison.hashCode ^
        showAsymmetryHeatmap.hashCode ^
        showAsymmetryRatioChart.hashCode ^
        showStepsComparison.hashCode;
  }
}
