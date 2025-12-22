import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc_app_template/theme/palette/common/common.dart';

/// ------------------------------
/// Thème centralisé du Scaffold
/// (Ici, on gère par exemple la couleur de fond)
/// ------------------------------
class AppScaffoldTheme {
  static Color getScaffoldBackground(Brightness brightness) {
    return brightness == Brightness.light
        ? CommonPalette.backgroundLight
        : CommonPalette.backgroundDark;
  }
}
