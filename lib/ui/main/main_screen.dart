import 'package:flutter/material.dart';
import 'package:flutter_bloc_app_template/generated/l10n.dart';
import 'package:flutter_bloc_app_template/routes/router.dart' as router;
import 'package:flutter_bloc_app_template/utils/battery_optimization_helper.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Vérifier et demander la désactivation de l'optimisation batterie après un délai
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        BatteryOptimizationHelper.showBatteryOptimizationReminder(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    void onSelected(int index) {
      setState(() {
        currentIndex = index;
      });
    }

    return LayoutBuilder(
      builder: (context, dimens) {
        return Scaffold(
          body: IndexedStack(
            index: currentIndex,
            children: router.destinations.map((d) => d.screen).toList(),
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: currentIndex,
            onTap: onSelected,
            type: BottomNavigationBarType.fixed,
            backgroundColor: theme.colorScheme.surface,
            selectedItemColor: theme.colorScheme.primary,
            unselectedItemColor: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            selectedFontSize: 12,
            unselectedFontSize: 12,
            showUnselectedLabels: true,
            items: [
              BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  "assets/icons/navigation/home.svg",
                  colorFilter: ColorFilter.mode(
                    theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    BlendMode.srcIn,
                  ),
                ),
                activeIcon: SvgPicture.asset(
                  "assets/icons/navigation/home.svg",
                  colorFilter: ColorFilter.mode(
                    theme.colorScheme.primary,
                    BlendMode.srcIn,
                  ),
                ),
                label: S.of(context).navHome,
              ),
              BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  "assets/icons/navigation/Category.svg",
                  colorFilter: ColorFilter.mode(
                    theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    BlendMode.srcIn,
                  ),
                ),
                activeIcon: SvgPicture.asset(
                  "assets/icons/navigation/Category.svg",
                  colorFilter: ColorFilter.mode(
                    theme.colorScheme.primary,
                    BlendMode.srcIn,
                  ),
                ),
                label: S.of(context).navHistory,
              ),
              BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  "assets/icons/navigation/profile.svg",
                  colorFilter: ColorFilter.mode(
                    theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    BlendMode.srcIn,
                  ),
                ),
                activeIcon: SvgPicture.asset(
                  "assets/icons/navigation/profile.svg",
                  colorFilter: ColorFilter.mode(
                    theme.colorScheme.primary,
                    BlendMode.srcIn,
                  ),
                ),
                label: S.of(context).navProfile,
              ),
            ],
          ),
        );
      },
    );
  }
}