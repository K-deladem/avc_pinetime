import 'package:flutter/material.dart';

/// Point de données d'asymétrie
class AsymmetryDataPoint {
  final DateTime timestamp;
  final double leftValue;
  final double rightValue;
  final double asymmetryRatio; // Pourcentage membre atteint (0-100%)
  final AsymmetryCategory asymmetryCategory;

  AsymmetryDataPoint({
    required this.timestamp,
    required this.leftValue,
    required this.rightValue,
    required this.asymmetryRatio,
    required this.asymmetryCategory,
  });

  /// Obtenir le score d'asymétrie (-50 à +50)
  /// Négatif = dominance gauche, Positif = dominance droite
  double get asymmetryScore => asymmetryRatio - 50.0;
}

/// Catégories d'asymétrie
enum AsymmetryCategory {
  balanced, // Équilibré (45-55%)
  leftModerate, // Dominance gauche modérée (55-65%)
  leftStrong, // Dominance gauche forte (>65%)
  rightModerate, // Dominance droite modérée (35-45%)
  rightStrong, // Dominance droite forte (<35%)
}

extension AsymmetryCategoryExtension on AsymmetryCategory {
  String get label {
    switch (this) {
      case AsymmetryCategory.balanced:
        return 'Équilibré';
      case AsymmetryCategory.leftModerate:
        return 'Dominance gauche modérée';
      case AsymmetryCategory.leftStrong:
        return 'Dominance gauche forte';
      case AsymmetryCategory.rightModerate:
        return 'Dominance droite modérée';
      case AsymmetryCategory.rightStrong:
        return 'Dominance droite forte';
    }
  }

  Color get color {
    switch (this) {
      case AsymmetryCategory.balanced:
        return Colors.green;
      case AsymmetryCategory.leftModerate:
      case AsymmetryCategory.rightModerate:
        return Colors.orange;
      case AsymmetryCategory.leftStrong:
      case AsymmetryCategory.rightStrong:
        return Colors.red;
    }
  }
}

/// Helper pour catégoriser l'asymétrie
class AsymmetryHelper {
  AsymmetryHelper._();

  /// Catégorise l'asymétrie selon le ratio
  /// Note: ratio = (membre atteint / total) × 100
  /// 0% = tout à gauche, 50% = équilibré, 100% = tout à droite
  static AsymmetryCategory categorize(double ratio) {
    if (ratio >= 45 && ratio <= 55) {
      return AsymmetryCategory.balanced;
    } else if (ratio > 55 && ratio <= 65) {
      return AsymmetryCategory.rightModerate;
    } else if (ratio > 65) {
      return AsymmetryCategory.rightStrong;
    } else if (ratio < 45 && ratio >= 35) {
      return AsymmetryCategory.leftModerate;
    } else {
      return AsymmetryCategory.leftStrong;
    }
  }
}
