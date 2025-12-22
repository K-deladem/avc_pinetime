import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc_app_template/theme/palette/extra.dart';

/// ------------------------------
/// Palette pour le thème "Mint"
/// ------------------------------
class MintPalette {
  // Pour le thème Mint clair
  static const Color primaryLight = Color(0xFF006B55);
  static const Color onPrimaryLight = Color(0xFFFFFFFF);
  static const Color primaryContainerLight = Color(0xFF7FF8D3);
  static const Color onPrimaryContainerLight = Color(0xFF002018);

  static const Color secondaryLight = Color(0xFF4B635A);
  static const Color onSecondaryLight = Color(0xFFFFFFFF);
  static const Color secondaryContainerLight = Color(0xFFCEE9DD);
  static const Color onSecondaryContainerLight = Color(0xFF072019);

  static const Color tertiaryLight = Color(0xFF406376);
  static const Color onTertiaryLight = Color(0xFFFFFFFF);
  static const Color tertiaryContainerLight = Color(0xFFC4E7FF);
  static const Color onTertiaryContainerLight = Color(0xFF001E2C);

  // Pour les deux modes Mint (clair et sombre)
  static const Color error = Color(0xFFBA1A1A);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color onErrorContainer = Color(0xFF410002);

  static const Color outlineLight = Color(0xFF6F7975);
  static const Color surfaceTintLight = primaryLight;

  // Pour le thème Mint sombre (différences sur certaines couleurs)
  static const Color primaryDark = Color(0xFF60DBB8);
  static const Color onPrimaryDark = Color(0xFF00382B);
  static const Color primaryContainerDark = Color(0xFF005140);
  static const Color onPrimaryContainerDark = Color(0xFF7FF8D3);

  static const Color secondaryDark = Color(0xFFB2CCC1);
  static const Color onSecondaryDark = Color(0xFF1E352D);
  static const Color secondaryContainerDark = Color(0xFF344C43);
  static const Color onSecondaryContainerDark = Color(0xFFCEE9DD);

  static const Color tertiaryDark = Color(0xFFA8CBE2);
  static const Color onTertiaryDark = Color(0xFF0D3446);
  static const Color tertiaryContainerDark = Color(0xFF284B5D);
  static const Color onTertiaryContainerDark = Color(0xFFC4E7FF);

  static const Color outlineDark = Color(0xFF89938E);
  static const Color surfaceTintDark = primaryDark;

  static const lightExtras = Extras(
    surface: Color(0xFFFBFDFA),
    onSurface: Color(0xFF191C1B),
    surfaceContainerHighest: Color(0xFFDBE5DF),
    onSurfaceVariant: Color(0xFF3F4945),
    onInverseSurface: Color(0xFFEFF1EE),
    inverseSurface: Color(0xFF2E312F),
    inversePrimary: Color(0xFF60DBB8),
    shadow: Color(0xFF000000),
    outlineVariant: Color(0xFFBFC9C3),
    scrim: Color(0xFF000000),
  );


  static const darkExtras = Extras(
    surface: Color(0xFF191C1B),
    onSurface: Color(0xFFE1E3E0),
    surfaceContainerHighest: Color(0xFF3F4945),
    onSurfaceVariant: Color(0xFFBFC9C3),
    onInverseSurface: Color(0xFF191C1B),
    inverseSurface: Color(0xFFE1E3E0),
    inversePrimary: MintPalette.primaryLight,
    // inverse de primaryDark
    shadow: Color(0xFF000000),
    outlineVariant: Color(0xFF3F4945),
    scrim: Color(0xFF000000),
  );
}