import 'package:flutter/material.dart';
import 'package:flutter_bloc_app_template/constants/index.dart';

class AppButton {
  static ElevatedButtonThemeData elevatedButtonThemeData = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      padding: const EdgeInsets.all(AppDefaults.padding),
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      minimumSize: const Size(double.infinity, 32),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(AppDefaults.radius)),
      ),
    ),
  );

  static OutlinedButtonThemeData outlinedButtonTheme(
      {Color borderColor = AppColors.black10}) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.all(AppDefaults.padding),
        minimumSize: const Size(double.infinity, 32),
        side: BorderSide(width: 1.5, color: borderColor),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppDefaults.radius)),
        ),
      ),
    );
  }

  static final textButtonThemeData = TextButtonThemeData(
    style: TextButton.styleFrom(foregroundColor: AppColors.primary),
  );
}