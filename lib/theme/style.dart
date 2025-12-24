import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app_template/constants/index.dart';
import 'package:flutter_bloc_app_template/theme/appbar/appbar.dart';
import 'package:flutter_bloc_app_template/theme/button/button.dart';
import 'package:flutter_bloc_app_template/theme/checkbox/checkbox.dart';
import 'package:flutter_bloc_app_template/theme/input/input_theme.dart';
import 'package:flutter_bloc_app_template/theme/palette/experimental/experimental.dart';
import 'package:flutter_bloc_app_template/theme/palette/extra.dart';
import 'package:flutter_bloc_app_template/theme/palette/gold/gold.dart';
import 'package:flutter_bloc_app_template/theme/palette/mint/mint.dart';
import 'package:flutter_bloc_app_template/theme/palette/standard/standard.dart';
import 'package:flutter_bloc_app_template/theme/scaffold/scaffold.dart';
import 'package:flutter_bloc_app_template/theme/tabbar/tabbar.dart';
import 'package:flutter_bloc_app_template/theme/typography/typo.dart';

/// ------------------------------
/// Classe regroupant les styles de l'application
/// ------------------------------
class Style {
  /// Personnalisation des transitions de page
  static const _pageTransitionsTheme = PageTransitionsTheme(
    builders: {
      TargetPlatform.android: ZoomPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
    },
  );

  // ---------------------------------------------------------
  // Thèmes Gold (clair et sombre) – utilisation de GoldPalette
  // ---------------------------------------------------------
  static ThemeData get lightGoldTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: _buildColorScheme(
        brightness: Brightness.light,
        primary: GoldPalette.primary,
        onPrimary: GoldPalette.onPrimary,
        primaryContainer: GoldPalette.primaryContainer,
        onPrimaryContainer: GoldPalette.onPrimaryContainer,
        secondary: GoldPalette.secondary,
        onSecondary: GoldPalette.onSecondary,
        secondaryContainer: GoldPalette.secondaryContainer,
        onSecondaryContainer: GoldPalette.onSecondaryContainer,
        tertiary: GoldPalette.tertiary,
        onTertiary: GoldPalette.onTertiary,
        tertiaryContainer: GoldPalette.tertiaryContainer,
        onTertiaryContainer: GoldPalette.onTertiaryContainer,
        error: GoldPalette.error,
        errorContainer: GoldPalette.errorContainer,
        onError: GoldPalette.onError,
        onErrorContainer: GoldPalette.onErrorContainer,
        extras: GoldPalette.lightExtras,
        outline: GoldPalette.outline,
        surfaceTint: GoldPalette.surfaceTint,
      ),
      textTheme: AppTypography.getTextTheme(ThemeData.light().textTheme),
      tabBarTheme: AppTabBarTheme.lightTabBarTheme,
      scaffoldBackgroundColor:
          AppScaffoldTheme.getScaffoldBackground(Brightness.light),
      pageTransitionsTheme: _pageTransitionsTheme,
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(),
      ),
      cupertinoOverrideTheme: const CupertinoThemeData(
        textTheme: CupertinoTextThemeData(),
      ),
    );
  }

  static ThemeData get darkGoldTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: _buildColorScheme(
        brightness: Brightness.dark,
        primary: GoldPalette.primary,
        onPrimary: GoldPalette.onPrimary,
        primaryContainer: GoldPalette.primaryContainer,
        onPrimaryContainer: GoldPalette.onPrimaryContainer,
        secondary: GoldPalette.secondary,
        onSecondary: GoldPalette.onSecondary,
        secondaryContainer: GoldPalette.secondaryContainer,
        onSecondaryContainer: GoldPalette.onSecondaryContainer,
        tertiary: GoldPalette.tertiary,
        onTertiary: GoldPalette.onTertiary,
        tertiaryContainer: GoldPalette.tertiaryContainer,
        onTertiaryContainer: GoldPalette.onTertiaryContainer,
        error: GoldPalette.error,
        errorContainer: GoldPalette.errorContainer,
        onError: GoldPalette.onError,
        onErrorContainer: GoldPalette.onErrorContainer,
        extras: GoldPalette.darkExtras,
        outline: GoldPalette.outline,
        surfaceTint: GoldPalette.surfaceTint,
      ),
      textTheme: AppTypography.getTextTheme(ThemeData.dark().textTheme),
      tabBarTheme: AppTabBarTheme.darkTabBarTheme,
      scaffoldBackgroundColor:
          AppScaffoldTheme.getScaffoldBackground(Brightness.dark),
      pageTransitionsTheme: _pageTransitionsTheme,
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(),
      ),
      cupertinoOverrideTheme: const CupertinoThemeData(
        textTheme: CupertinoTextThemeData(),
      ),
    );
  }

  // ---------------------------------------------------------
  // Thèmes Mint (clair et sombre) – utilisation de MintPalette
  // ---------------------------------------------------------
  static ThemeData get lightMintTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: _buildColorScheme(
        brightness: Brightness.light,
        primary: MintPalette.primaryLight,
        onPrimary: MintPalette.onPrimaryLight,
        primaryContainer: MintPalette.primaryContainerLight,
        onPrimaryContainer: MintPalette.onPrimaryContainerLight,
        secondary: MintPalette.secondaryLight,
        onSecondary: MintPalette.onSecondaryLight,
        secondaryContainer: MintPalette.secondaryContainerLight,
        onSecondaryContainer: MintPalette.onSecondaryContainerLight,
        tertiary: MintPalette.tertiaryLight,
        onTertiary: MintPalette.onTertiaryLight,
        tertiaryContainer: MintPalette.tertiaryContainerLight,
        onTertiaryContainer: MintPalette.onTertiaryContainerLight,
        error: MintPalette.error,
        errorContainer: MintPalette.errorContainer,
        onError: MintPalette.onError,
        onErrorContainer: MintPalette.onErrorContainer,
        extras: MintPalette.lightExtras,
        outline: MintPalette.outlineLight,
        surfaceTint: MintPalette.surfaceTintLight,
      ),
      textTheme: AppTypography.getTextTheme(ThemeData.light().textTheme),
      tabBarTheme: AppTabBarTheme.lightTabBarTheme,
      scaffoldBackgroundColor:
          AppScaffoldTheme.getScaffoldBackground(Brightness.light),
      pageTransitionsTheme: _pageTransitionsTheme,
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(),
      ),
      cupertinoOverrideTheme: const CupertinoThemeData(
        textTheme: CupertinoTextThemeData(),
      ),
    );
  }

  static ThemeData get darkMintTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: _buildColorScheme(
        brightness: Brightness.dark,
        primary: MintPalette.primaryDark,
        onPrimary: MintPalette.onPrimaryDark,
        primaryContainer: MintPalette.primaryContainerDark,
        onPrimaryContainer: MintPalette.onPrimaryContainerDark,
        secondary: MintPalette.secondaryDark,
        onSecondary: MintPalette.onSecondaryDark,
        secondaryContainer: MintPalette.secondaryContainerDark,
        onSecondaryContainer: MintPalette.onSecondaryContainerDark,
        tertiary: MintPalette.tertiaryDark,
        onTertiary: MintPalette.onTertiaryDark,
        tertiaryContainer: MintPalette.tertiaryContainerDark,
        onTertiaryContainer: MintPalette.onTertiaryContainerDark,
        error: MintPalette.error,
        errorContainer: MintPalette.errorContainer,
        onError: MintPalette.onError,
        onErrorContainer: MintPalette.onErrorContainer,
        extras: MintPalette.darkExtras,
        outline: MintPalette.outlineDark,
        surfaceTint: MintPalette.surfaceTintDark,
      ),
      textTheme: AppTypography.getTextTheme(ThemeData.dark().textTheme),
      tabBarTheme: AppTabBarTheme.darkTabBarTheme,
      scaffoldBackgroundColor:
          AppScaffoldTheme.getScaffoldBackground(Brightness.dark),
      pageTransitionsTheme: _pageTransitionsTheme,
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(),
      ),
      cupertinoOverrideTheme: const CupertinoThemeData(
        textTheme: CupertinoTextThemeData(),
      ),
    );
  }

  // ---------------------------------------------------------
  // Thème Experimental (exemple en mode sombre)
  // ---------------------------------------------------------
  static ThemeData get experimental {
    return ThemeData(
      useMaterial3: true,
      colorScheme: _buildColorScheme(
        brightness: Brightness.light,
        primary: ExperimentalPalette.primary,
        onPrimary: ExperimentalPalette.onPrimary,
        primaryContainer: ExperimentalPalette.primaryContainer,
        onPrimaryContainer: ExperimentalPalette.onPrimaryContainer,
        secondary: ExperimentalPalette.secondary,
        onSecondary: ExperimentalPalette.onSecondary,
        secondaryContainer: ExperimentalPalette.secondaryContainer,
        onSecondaryContainer: ExperimentalPalette.onSecondaryContainer,
        tertiary: ExperimentalPalette.tertiary,
        onTertiary: ExperimentalPalette.onTertiary,
        tertiaryContainer: ExperimentalPalette.tertiaryContainer,
        onTertiaryContainer: ExperimentalPalette.onTertiaryContainer,
        error: ExperimentalPalette.error,
        errorContainer: ExperimentalPalette.errorContainer,
        onError: ExperimentalPalette.onError,
        onErrorContainer: ExperimentalPalette.onErrorContainer,
        extras: ExperimentalPalette.extras,
        outline: ExperimentalPalette.outline,
        surfaceTint: ExperimentalPalette.surfaceTint,
      ),
      textTheme: AppTypography.getTextTheme(ThemeData.dark().textTheme),
      tabBarTheme: AppTabBarTheme.darkTabBarTheme,
      //scaffoldBackgroundColor: AppScaffoldTheme.getScaffoldBackground(Brightness.dark),
      pageTransitionsTheme: _pageTransitionsTheme,
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(),
      ),
      cupertinoOverrideTheme: const CupertinoThemeData(
        textTheme: CupertinoTextThemeData(),
      ),
    );
  }

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      colorScheme: _buildColorScheme(
        brightness: Brightness.light,
        primary: StandardPalette.primaryLight,
        onPrimary: StandardPalette.onPrimaryLight,
        primaryContainer: StandardPalette.primaryContainerLight,
        onPrimaryContainer: StandardPalette.onPrimaryContainerLight,
        secondary: StandardPalette.secondaryLight,
        onSecondary: StandardPalette.onSecondaryLight,
        secondaryContainer: StandardPalette.secondaryContainerLight,
        onSecondaryContainer: StandardPalette.onSecondaryContainerLight,
        tertiary: StandardPalette.tertiaryLight,
        onTertiary: StandardPalette.onTertiaryLight,
        tertiaryContainer: StandardPalette.tertiaryContainerLight,
        onTertiaryContainer: StandardPalette.onTertiaryContainerLight,
        error: StandardPalette.errorLight,
        errorContainer: StandardPalette.errorContainerLight,
        onError: StandardPalette.onErrorLight,
        onErrorContainer: StandardPalette.onErrorContainerLight,
        extras: StandardPalette.lightExtras,
        outline: StandardPalette.outlineLight,
        surfaceTint: StandardPalette.surfaceTintLight,
      ),
      fontFamily: "Plus Jakarta",
      textTheme: AppTypography.getTextTheme(ThemeData.light().textTheme),
      elevatedButtonTheme: AppButton.elevatedButtonThemeData,
      textButtonTheme: AppButton.textButtonThemeData,
      outlinedButtonTheme: AppButton.outlinedButtonTheme(),
      inputDecorationTheme: AppInputDecorationTheme.lightInputDecorationTheme,
      checkboxTheme: AppCheckboxTheme.checkboxThemeData.copyWith(
        side: const BorderSide(color: AppColors.black40),
      ),
      appBarTheme: AppAppBarTheme.appBarLightTheme,
      scrollbarTheme: AppAppBarTheme.scrollbarThemeData,
      dataTableTheme: AppAppBarTheme.dataTableLightThemeData,
      pageTransitionsTheme: _pageTransitionsTheme,
      cupertinoOverrideTheme: const CupertinoThemeData(
        textTheme: CupertinoTextThemeData(),
      ),
    );
  }

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      colorScheme: _buildColorScheme(
        brightness: Brightness.dark,
        primary: StandardPalette.primaryDark,
        onPrimary: StandardPalette.onPrimaryDark,
        primaryContainer: StandardPalette.primaryContainerDark,
        onPrimaryContainer: StandardPalette.onPrimaryContainerDark,
        secondary: StandardPalette.secondaryDark,
        onSecondary: StandardPalette.onSecondaryDark,
        secondaryContainer: StandardPalette.secondaryContainerDark,
        onSecondaryContainer: StandardPalette.onSecondaryContainerDark,
        tertiary: StandardPalette.tertiaryDark,
        onTertiary: StandardPalette.onTertiaryDark,
        tertiaryContainer: StandardPalette.tertiaryContainerDark,
        onTertiaryContainer: StandardPalette.onTertiaryContainerDark,
        error: StandardPalette.errorDark,
        errorContainer: StandardPalette.errorContainerDark,
        onError: StandardPalette.onErrorDark,
        onErrorContainer: StandardPalette.onErrorContainerDark,
        extras: StandardPalette.darkExtras,
        outline: StandardPalette.outlineDark,
        surfaceTint: StandardPalette.surfaceTintDark,
      ),
      fontFamily: "Plus Jakarta",
      textTheme: AppTypography.getTextTheme(ThemeData.dark().textTheme),
      elevatedButtonTheme: AppButton.elevatedButtonThemeData,
      textButtonTheme: AppButton.textButtonThemeData,
      outlinedButtonTheme: AppButton.outlinedButtonTheme(),
      inputDecorationTheme: AppInputDecorationTheme.darkInputDecorationTheme,
      checkboxTheme: AppCheckboxTheme.checkboxThemeData.copyWith(
        side: const BorderSide(color: AppColors.black40),
      ),
      appBarTheme: AppAppBarTheme.appBarDarkTheme,
      scrollbarTheme: AppAppBarTheme.scrollbarThemeData,
      dataTableTheme: AppAppBarTheme.dataTableDarkThemeData,
      pageTransitionsTheme: _pageTransitionsTheme,
      cupertinoOverrideTheme: const CupertinoThemeData(
        textTheme: CupertinoTextThemeData(),
      ),
    );
  }





  // ---------------------------------------------------------
  // Fonction générique pour construire un ColorScheme
  // ---------------------------------------------------------
  static ColorScheme _buildColorScheme({
    required Brightness brightness,
    required Color primary,
    required Color onPrimary,
    required Color primaryContainer,
    required Color onPrimaryContainer,
    required Color secondary,
    required Color onSecondary,
    required Color secondaryContainer,
    required Color onSecondaryContainer,
    required Color tertiary,
    required Color onTertiary,
    required Color tertiaryContainer,
    required Color onTertiaryContainer,
    required Color error,
    required Color errorContainer,
    required Color onError,
    required Color onErrorContainer,
    required Extras extras,
    required Color outline,
    required Color surfaceTint,
  }) {
    return ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: onPrimary,
      primaryContainer: primaryContainer,
      onPrimaryContainer: onPrimaryContainer,
      secondary: secondary,
      onSecondary: onSecondary,
      secondaryContainer: secondaryContainer,
      onSecondaryContainer: onSecondaryContainer,
      tertiary: tertiary,
      onTertiary: onTertiary,
      tertiaryContainer: tertiaryContainer,
      onTertiaryContainer: onTertiaryContainer,
      error: error,
      errorContainer: errorContainer,
      onError: onError,
      onErrorContainer: onErrorContainer,
      surface: extras.surface,
      onSurface: extras.onSurface,
      surfaceContainerHighest: extras.surfaceContainerHighest,
      onSurfaceVariant: extras.onSurfaceVariant,
      outline: outline,
      onInverseSurface: extras.onInverseSurface,
      inverseSurface: extras.inverseSurface,
      inversePrimary: extras.inversePrimary,
      shadow: extras.shadow,
      surfaceTint: surfaceTint,
      outlineVariant: extras.outlineVariant,
      scrim: extras.scrim,
    );
  }

  static PopupMenuThemeData _buildPopupMenuThemeData() {
    return PopupMenuThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
    );
  }
}
