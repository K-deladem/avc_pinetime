import 'package:flutter/material.dart';
import 'package:flutter_bloc_app_template/constants/index.dart';

class AppCheckboxTheme {
  static CheckboxThemeData checkboxThemeData = CheckboxThemeData(
    checkColor: WidgetStateProperty.all(Colors.white),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(AppDefaults.radius / 2),
      ),
    ),
    side: const BorderSide(color: AppColors.white40),
  );
}
