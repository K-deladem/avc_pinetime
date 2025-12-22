import 'package:flutter/material.dart';

import 'package:flutter/material.dart';

class AppTabBarTheme {
  static TabBarThemeData get lightTabBarTheme => TabBarThemeData(
    labelColor: Colors.black87,
    unselectedLabelColor: Colors.black45,
    indicator: const UnderlineTabIndicator(
      borderSide: BorderSide(width: 2, color: Colors.black87),
    ),
    overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
      if (states.contains(WidgetState.pressed)) {
        return Colors.black38; // Couleur lors d'un appui
      }
      return Colors.transparent; // Pas de couleur sinon
    }),
    indicatorSize: TabBarIndicatorSize.label, // Ajuste à la largeur du texte
  );

  static TabBarThemeData get darkTabBarTheme => TabBarThemeData(
    labelColor: Colors.white70,
    unselectedLabelColor: Colors.white60,
    indicator: const UnderlineTabIndicator(
      borderSide: BorderSide(width: 2, color: Colors.white70),
    ),
    overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
      if (states.contains(WidgetState.pressed)) {
        return Colors.white30; // Couleur lors d'un appui
      }
      return Colors.transparent; // Pas de couleur sinon
    }),
    indicatorSize: TabBarIndicatorSize.label,
  );
}