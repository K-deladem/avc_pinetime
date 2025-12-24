import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc_app_template/theme/palette/extra.dart';

/// ------------------------------
/// Palette pour le thème "Standard" (basé sur la couleur primaire de l'app)
/// Couleur principale: #fc4a39 (rouge-orange)
/// ------------------------------
class StandardPalette {
  // Thème clair
  static const Color primaryLight = Color(0xFFfc4a39);
  static const Color onPrimaryLight = Color(0xFFFFFFFF);
  static const Color primaryContainerLight = Color(0xFFFFDAD5);
  static const Color onPrimaryContainerLight = Color(0xFF410002);

  static const Color secondaryLight = Color(0xFF775652);
  static const Color onSecondaryLight = Color(0xFFFFFFFF);
  static const Color secondaryContainerLight = Color(0xFFFFDAD5);
  static const Color onSecondaryContainerLight = Color(0xFF2C1512);

  static const Color tertiaryLight = Color(0xFF715B2E);
  static const Color onTertiaryLight = Color(0xFFFFFFFF);
  static const Color tertiaryContainerLight = Color(0xFFFDDFA6);
  static const Color onTertiaryContainerLight = Color(0xFF261900);

  static const Color errorLight = Color(0xFFBA1A1A);
  static const Color errorContainerLight = Color(0xFFFFDAD6);
  static const Color onErrorLight = Color(0xFFFFFFFF);
  static const Color onErrorContainerLight = Color(0xFF410002);

  static const Color outlineLight = Color(0xFF857371);
  static const Color surfaceTintLight = primaryLight;

  // Thème sombre
  static const Color primaryDark = Color(0xFFFFB4A9);
  static const Color onPrimaryDark = Color(0xFF690003);
  static const Color primaryContainerDark = Color(0xFFc23a2b);
  static const Color onPrimaryContainerDark = Color(0xFFFFDAD5);

  static const Color secondaryDark = Color(0xFFE7BDB8);
  static const Color onSecondaryDark = Color(0xFF442926);
  static const Color secondaryContainerDark = Color(0xFF5D3F3B);
  static const Color onSecondaryContainerDark = Color(0xFFFFDAD5);

  static const Color tertiaryDark = Color(0xFFDFC38C);
  static const Color onTertiaryDark = Color(0xFF3E2E04);
  static const Color tertiaryContainerDark = Color(0xFF574419);
  static const Color onTertiaryContainerDark = Color(0xFFFDDFA6);

  static const Color errorDark = Color(0xFFFFB4AB);
  static const Color errorContainerDark = Color(0xFF93000A);
  static const Color onErrorDark = Color(0xFF690005);
  static const Color onErrorContainerDark = Color(0xFFFFDAD6);

  static const Color outlineDark = Color(0xFFA08C8A);
  static const Color surfaceTintDark = primaryDark;

  static const lightExtras = Extras(
    surface: Color(0xFFFFFBFF),
    onSurface: Color(0xFF201A19),
    surfaceContainerHighest: Color(0xFFEDE0DE),
    onSurfaceVariant: Color(0xFF534341),
    onInverseSurface: Color(0xFFFBEEEC),
    inverseSurface: Color(0xFF362F2E),
    inversePrimary: Color(0xFFFFB4A9),
    shadow: Color(0xFF000000),
    outlineVariant: Color(0xFFD8C2BF),
    scrim: Color(0xFF000000),
  );

  static const darkExtras = Extras(
    surface: Color(0xFF201A19),
    onSurface: Color(0xFFEDE0DE),
    surfaceContainerHighest: Color(0xFF534341),
    onSurfaceVariant: Color(0xFFD8C2BF),
    onInverseSurface: Color(0xFF201A19),
    inverseSurface: Color(0xFFEDE0DE),
    inversePrimary: primaryLight,
    shadow: Color(0xFF000000),
    outlineVariant: Color(0xFF534341),
    scrim: Color(0xFF000000),
  );
}
