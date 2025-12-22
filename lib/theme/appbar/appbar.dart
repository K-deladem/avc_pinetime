import 'package:flutter/material.dart';
import 'package:flutter_bloc_app_template/constants/index.dart';

/// ------------------------------
/// Thème centralisé du TabBar
/// ------------------------------

class AppAppBarTheme {

   static AppBarTheme appBarLightTheme = const AppBarTheme(
    backgroundColor: Colors.white,
    elevation: 0,
    iconTheme: IconThemeData(color: AppColors.black),
    titleTextStyle: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color:AppColors.black,
    ),
  );

  static const AppBarTheme appBarDarkTheme = AppBarTheme(
    backgroundColor: AppColors.black,
    elevation: 0,
    iconTheme: IconThemeData(color: Colors.white),
    titleTextStyle: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: Colors.white,
    ),
  );

  static ScrollbarThemeData scrollbarThemeData = ScrollbarThemeData(
    trackColor: WidgetStateProperty.all(AppColors.primary),
  );

   static DataTableThemeData dataTableLightThemeData = DataTableThemeData(
    columnSpacing: 24,
    headingRowColor: WidgetStateProperty.all(Colors.black12),
    decoration: BoxDecoration(
      borderRadius: const BorderRadius.all(Radius.circular(AppDefaults.radius)),
      border: Border.all(color: Colors.black12),
    ),
    dataTextStyle: const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: AppColors.black,
    ),
  );

   static DataTableThemeData dataTableDarkThemeData = DataTableThemeData(
    columnSpacing: 24,
    headingRowColor: WidgetStateProperty.all(Colors.white10),
    decoration: BoxDecoration(
      borderRadius: const BorderRadius.all(Radius.circular(AppDefaults.radius)),
      border: Border.all(color: Colors.white10),
    ),
    dataTextStyle: const TextStyle(
      fontWeight: FontWeight.w500,
      color: Colors.white,
      fontSize: 12,
    ),
  );

}