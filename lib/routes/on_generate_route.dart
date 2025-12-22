import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc_app_template/ui/main/main_screen.dart';
import 'package:flutter_bloc_app_template/ui/onboarding/onboarding_screen.dart';
import 'package:flutter_bloc_app_template/ui/setting/page/about_page.dart';
import 'package:flutter_bloc_app_template/ui/setting/page/bluetooth_settings_page.dart';
import 'package:flutter_bloc_app_template/ui/setting/page/chart_preferences_page.dart';
import 'package:flutter_bloc_app_template/ui/setting/page/contact_support_page.dart';
import 'package:flutter_bloc_app_template/ui/setting/page/goal_settings_page.dart';
import 'package:flutter_bloc_app_template/ui/setting/page/language_settings_page.dart';
import 'package:flutter_bloc_app_template/ui/setting/page/privacy_policy_page.dart';
import 'package:flutter_bloc_app_template/ui/setting/page/profile_settings_page.dart';
import 'package:flutter_bloc_app_template/ui/setting/page/theme_settings_page.dart';
import 'package:flutter_bloc_app_template/ui/setting/page/watch_management_page.dart';

import '../models/watch_device.dart';
import 'app_routes.dart';

class RouteGenerator {
  static Map<String, Widget Function(BuildContext, dynamic)> appRoutes = {
    AppRoutes.app: (context, _) => const MainScreen(),
    AppRoutes.onboarding: (context, _) => const OnboardingScreen(),
    AppRoutes.about: (context, _) => const AboutPage(),
    AppRoutes.contact: (context, _) => const ContactSupportPage(),
    AppRoutes.profile: (context, _) => const ProfileSettingsPage(),
    AppRoutes.language: (context, _) => const LanguageSettingsPage(),
    AppRoutes.privacy: (context, _) => const PrivacyPolicyPage(),
    AppRoutes.themeSettings: (context, _) => const ThemeSettingsPage(),
    AppRoutes.bluetoothSettings: (context, _) => const BluetoothSettingsPage(),
    AppRoutes.chartPreferences: (context, _) => const ChartPreferencesPage(),
    AppRoutes.goalSettings: (context, _) => const GoalSettingsPage(),
    AppRoutes.watchLeft: (context, args) {
      final device = args as WatchDevice;
      return WatchManagementPage(watch: device);
    },
    AppRoutes.watchRight: (context, args) {
      final device = args as WatchDevice;
      return WatchManagementPage(watch: device);
    },
  };
}
