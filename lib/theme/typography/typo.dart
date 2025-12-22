import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// ------------------------------
/// Typographie centralisée
/// ------------------------------
class AppTypography {
  static TextTheme _baseTextTheme(TextTheme base) {
    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(fontSize: 32, fontWeight: FontWeight.bold),
      displaySmall: base.displaySmall?.copyWith(fontSize: 24, fontWeight: FontWeight.bold),
      headlineMedium: base.headlineMedium?.copyWith(fontSize: 20, fontWeight: FontWeight.w600),
      headlineSmall: base.headlineSmall?.copyWith(fontSize: 18, fontWeight: FontWeight.w600),
      titleLarge: base.titleLarge?.copyWith(fontSize: 16, fontWeight: FontWeight.w500),
      titleMedium: base.titleMedium?.copyWith(fontSize: 14, fontWeight: FontWeight.w500),
      bodyLarge: base.bodyLarge?.copyWith(fontSize: 16),
      bodyMedium: base.bodyMedium?.copyWith(fontSize: 14),
      bodySmall: base.bodySmall?.copyWith(fontSize: 12),
      labelLarge: base.labelLarge?.copyWith(fontSize: 14, fontWeight: FontWeight.w500),
    );
  }

  /// TextStyle pour un ElevatedButton dans un thème sombre
  static TextStyle get elevatedButtonTextStyleDark {
    return const TextStyle(fontSize: 14, color: Colors.black);
  }

  static TextTheme getTextTheme(TextTheme base) {
    // Utilisation de Google Fonts (Roboto, par exemple)
    return GoogleFonts.robotoTextTheme(_baseTextTheme(base));
  }
}
