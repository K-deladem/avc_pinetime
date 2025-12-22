import 'package:flutter/material.dart';
import 'package:flutter_bloc_app_template/theme/style.dart';

enum AppTheme {
  light,
  dark,
  lightGold,
  darkGold,
  lightMint,
  darkMint,
  system,
  experimental,
}

extension AppThemeExtension on AppTheme {
  String get label {
    switch (this) {
      case AppTheme.light: return "Clair (standard)";
      case AppTheme.dark: return "Sombre (standard)";
      case AppTheme.lightGold: return "Or (clair)";
      case AppTheme.darkGold: return "Or (sombre)";
      case AppTheme.lightMint: return "Menthe (clair)";
      case AppTheme.darkMint: return "Menthe (sombre)";
      case AppTheme.system: return "Suivre le système";
      case AppTheme.experimental: return "Expérimental";
    }
  }

  static AppTheme fromLabel(String label) {
    return AppTheme.values.firstWhere(
          (e) => e.label == label,
      orElse: () => AppTheme.system,
    );
  }

  static AppTheme fromName(String name) {
    return AppTheme.values.firstWhere(
          (e) => e.name == name,
      orElse: () => AppTheme.system,
    );
  }

  bool get isDark => [
    AppTheme.dark,
    AppTheme.darkGold,
    AppTheme.darkMint,
    AppTheme.experimental,
  ].contains(this);

  bool get isLight => [
    AppTheme.light,
    AppTheme.lightGold,
    AppTheme.lightMint,
  ].contains(this);
}

extension AppThemeJsonExtension on AppTheme {
  String toJson() => name;

  static AppTheme fromJson(String name) {
    return AppTheme.values.firstWhere((e) => e.name == name, orElse: () => AppTheme.system);
  }
}

extension StringToAppTheme on String {
  AppTheme toAppTheme() => AppThemeExtension.fromLabel(this);
}

AppTheme parseAppTheme(String name) {
  return AppTheme.values.firstWhere(
        (e) => e.name == name,
    orElse: () => AppTheme.system,
  );
}

class ThemeHelper {
  static ThemeData getLightTheme(AppTheme theme) {
    switch (theme) {
      case AppTheme.light:
        return Style.light;
      case AppTheme.lightGold:
        return Style.lightGoldTheme;
      case AppTheme.lightMint:
        return Style.lightMintTheme;
      default:
        return Style.light;
    }
  }

  static ThemeData getDarkTheme(AppTheme theme) {
    switch (theme) {
      case AppTheme.dark:
        return Style.dark;
      case AppTheme.darkGold:
        return Style.darkGoldTheme;
      case AppTheme.darkMint:
        return Style.darkMintTheme;
      case AppTheme.experimental:
        return Style.experimental;
      default:
        return Style.dark;
    }
  }

  static ThemeMode getThemeMode(AppTheme theme) {
    if (theme == AppTheme.system || theme == AppTheme.experimental) {
      return ThemeMode.system;
    } else if (theme.isDark) {
      return ThemeMode.dark;
    } else {
      return ThemeMode.light;
    }
  }
}