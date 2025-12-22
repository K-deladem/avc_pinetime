
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc_app_template/theme/palette/extra.dart';

/// ------------------------------
/// Palette pour le thème "Experimental"
/// ------------------------------
class ExperimentalPalette {
  static const Color primary = Color(0xFF66DBB2);
  static const Color onPrimary = Color(0xFF003829);
  static const Color primaryContainer = Color(0xFF00513C);
  static const Color onPrimaryContainer = Color(0xFF83F8CD);

  static const Color secondary = Color(0xFF51DBCD);
  static const Color onSecondary = Color(0xFF003733);
  static const Color secondaryContainer = Color(0xFF00504A);
  static const Color onSecondaryContainer = Color(0xFF72F7E9);

  static const Color tertiary = Color(0xFFA7CCE0);
  static const Color onTertiary = Color(0xFF0A3445);
  static const Color tertiaryContainer = Color(0xFF264B5C);
  static const Color onTertiaryContainer = Color(0xFFC2E8FD);

  static const Color error = Color(0xFFFFB4AB);
  static const Color errorContainer = Color(0xFF93000A);
  static const Color onError = Color(0xFF690005);
  static const Color onErrorContainer = Color(0xFFFFDAD6);

  static const Color outline = Color(0xFF89938D);
  static const Color surfaceTint = primary;

  static const extras = Extras(
    surface: Color(0xFF191C1A),
    onSurface: Color(0xFFE1E3E0),
    surfaceContainerHighest: Color(0xFF404944),
    onSurfaceVariant: Color(0xFFBFC9C2),
    onInverseSurface: Color(0xFF191C1A),
    inverseSurface: Color(0xFFE1E3E0),
    inversePrimary: Color(0xFF006C51),
    shadow: Color(0xFF000000),
    outlineVariant: Color(0xFF404944),
    scrim: Color(0xFF000000),
  );
}
