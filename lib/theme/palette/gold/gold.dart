import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc_app_template/theme/palette/extra.dart';

/// ------------------------------
/// Palette pour le thème "Gold"
/// ------------------------------
class GoldPalette {
  // Couleur primaire Gold avec opacité complète pour un bon contraste
  static const Color primary = Color(0xFFD4A574);
  static const Color onPrimary = Color(0xFF3D2314);
  static const Color primaryContainer = Color(0xFFFFDCC1);
  static const Color onPrimaryContainer = Color(0xFF2E1500);

  static const Color secondary = Color(0xFF745943);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFFFDCC1);
  static const Color onSecondaryContainer = Color(0xFF2A1707);

  static const Color tertiary = Color(0xFF5B6237);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFFDFE7B1);
  static const Color onTertiaryContainer = Color(0xFF181E00);

  static const Color error = Color(0xFFBA1A1A);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color onErrorContainer = Color(0xFF410002);

  static const Color outline = Color(0xFF837469);
  static const Color surfaceTint = primary;

  static const lightExtras = Extras(
    surface: Color(0xFFFFFBFF),
    onSurface: Color(0xFF201B17),
    surfaceContainerHighest: Color(0xFFF3DFD1),
    onSurfaceVariant: Color(0xFF51443B),
    onInverseSurface: Color(0xFFFAEFE8),
    inverseSurface: Color(0xFF352F2B),
    inversePrimary: Color(0xFFFFB779),
    shadow: Color(0xFF000000),
    outlineVariant: Color(0xFFD6C3B6),
    scrim: Color(0xFF000000),
  );

  static const darkExtras = Extras(
    surface: Color(0xFF2A1707),
    onSurface: Color(0xFFFAEFE8),
    surfaceContainerHighest: Color(0xFF2A1707),
    onSurfaceVariant: Color(0xFFBFC9C2),
    onInverseSurface: Color(0xFFFAEFE8),
    inverseSurface: Color(0xFF352F2B),
    inversePrimary: Color(0xFFFFB779),
    shadow: Color(0xFF000000),
    outlineVariant: Color(0xFFD6C3B6),
    scrim: Color(0xFF000000),
  );
}
