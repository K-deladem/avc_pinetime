import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app_template/index.dart';
import 'package:flutter_bloc_app_template/models/nav_destination.dart';
import 'package:flutter_bloc_app_template/routes/on_generate_route.dart';



final List<NavDestination> destinations = [
  NavDestination(
    label: 'Home',
    icon: const Icon(Icons.home_filled),
    selectedIcon: const Icon(Icons.home_filled),
    screen: HomeScreen(),
  ),
  NavDestination(
    label: 'History',
    icon: const Icon(Icons.search),
    selectedIcon: const Icon(Icons.search),
    screen: HistoryScreen(),
  ),


  const NavDestination(
    label: 'Profile',
    icon: Icon(Icons.account_circle_outlined),
    selectedIcon: Icon(Icons.account_circle_outlined),
    screen: SettingsScreen(),
  ),

  /*
  NavDestination(
    label: 'Profile',
    icon: Assets.icons.navigation.profile.svg(),
    selectedIcon: Assets.icons.navigation.profile.svg(),
    screen: SettingsScreen(),
  ),*/
];



final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

class NavigationService {


  // iOS: full screen routes pop up from the bottom and disappear vertically too
  // On iOS that's a standard full screen dialog
  // Has no effect on Android.
  final Set<String> _fullScreenRoutes = {};

  // iOS transition: Pages that slides in from the right and exits in reverse.
  final Set<String> _cupertinoRoutes = {};

  static NavigationService of(BuildContext context) =>
      RepositoryProvider.of<NavigationService>(context);

  Future<dynamic> navigateTo(
    String routeName, [
    Object? arguments,
    bool replace = false,
  ]) async {
    if (RouteGenerator.appRoutes[routeName] != null) {
      return replace
          ? appNavigatorKey.currentState
          ?.pushReplacementNamed(routeName, arguments: arguments)
          : appNavigatorKey.currentState
          ?.pushNamed(routeName, arguments: arguments);
    }
  }

  Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final name = settings.name;
    final builder = RouteGenerator.appRoutes[name];

    if (builder != null) {
      final isCupertino = _cupertinoRoutes.contains(name);
      final isFullscreen = _fullScreenRoutes.contains(name);

      return isCupertino
          ? CupertinoPageRoute(
        settings: settings,
        builder: (context) => builder(context, settings.arguments),
        fullscreenDialog: isFullscreen,
      )
            : MaterialPageRoute(
          settings: settings,
          builder: (context) => builder(context, settings.arguments),
          fullscreenDialog: isFullscreen,
        );
    }
    return MaterialPageRoute(
      builder: (_) => const Scaffold(
        body: Center(child: Text("404 - Page non trouvée")),
      ),
    );
  }

  Future<dynamic> pushAndRemoveAll(
    String routeName, [
    Object? arguments,
  ]) async {
    return appNavigatorKey.currentState
        ?.pushNamedAndRemoveUntil(routeName, (route) => false);
  }
}

