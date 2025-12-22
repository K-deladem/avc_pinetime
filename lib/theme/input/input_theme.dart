import 'package:flutter/material.dart';
import 'package:flutter_bloc_app_template/constants/index.dart';

class AppInputDecorationTheme {


  static InputDecorationTheme lightInputDecorationTheme = InputDecorationTheme(
    fillColor: AppColors.lightGrey,
    filled: true,
    hintStyle: const TextStyle(color: AppColors.grey),
    border: outlineInputBorder,
    enabledBorder: outlineInputBorder,
    focusedBorder: focusedOutlineInputBorder,
    errorBorder: errorOutlineInputBorder,
  );

  static InputDecorationTheme darkInputDecorationTheme = InputDecorationTheme(
    fillColor: AppColors.darkGrey,
    filled: true,
    hintStyle: const TextStyle(color: AppColors.white40),
    border: outlineInputBorder,
    enabledBorder: outlineInputBorder,
    focusedBorder: focusedOutlineInputBorder,
    errorBorder: errorOutlineInputBorder,
  );

  static OutlineInputBorder outlineInputBorder = const OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(AppDefaults.radius)),
    borderSide: BorderSide(
      color: Colors.transparent,
    ),
  );

  static OutlineInputBorder focusedOutlineInputBorder =
      const OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(AppDefaults.radius)),
    borderSide: BorderSide(color: AppColors.primary),
  );

  static OutlineInputBorder errorOutlineInputBorder = const OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(AppDefaults.radius)),
    borderSide: BorderSide(
      color: AppColors.error,
    ),
  );

  static OutlineInputBorder secodaryOutlineInputBorder(BuildContext context) {
    return OutlineInputBorder(
      borderRadius: const BorderRadius.all(Radius.circular(AppDefaults.radius)),
      borderSide: BorderSide(
        color: Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(0.15),
      ),
    );
  }
}
