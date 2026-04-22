import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:home_fitness/values/app_colors.dart';

import '../common/ext/device_ext.dart';
import '../values/app_assets.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  @override
  void initState() {
    super.initState();
    GoRouter.of(context).routerDelegate.addListener(_onRouteChanged);
  }

  @override
  void dispose() {
    GoRouter.of(context).routerDelegate.removeListener(_onRouteChanged);
    super.dispose();
  }

  void _onRouteChanged() {
    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = widget.navigationShell.currentIndex;

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: widget.navigationShell,
      bottomNavigationBar: _SleepTabBar(
        currentIndex: currentIndex,
        onTap: (index) {
          widget.navigationShell.goBranch(
            index,
            initialLocation: index == currentIndex,
          );
        },
      ),
    );
  }
}

class _SleepTabBar extends StatelessWidget {
  const _SleepTabBar({required this.currentIndex, required this.onTap});

  final int currentIndex;
  final ValueChanged<int> onTap;

  static final _tabs = [
    _TabItem(icon: AppIcons.icHome, activeIcon: AppIcons.icHomeCheck),
    _TabItem(icon: AppIcons.icWork, activeIcon: AppIcons.icWorkCheck),
    _TabItem(icon: AppIcons.icCycling, activeIcon: AppIcons.icCyclingCheck),
    _TabItem(icon: AppIcons.icMovies, activeIcon: AppIcons.icMoviesCheck),
    _TabItem(icon: AppIcons.icSetting, activeIcon: AppIcons.icSettingCheck),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.black,
        border: Border(top: BorderSide(color: Color(0xFF2A2840), width: 0.5)),
      ),
      child: SizedBox(
        height: context.isPhone ? 65 : 100,
        child: Row(
          children: List.generate(_tabs.length, (index) {
            return Expanded(
              child: _TabBarItem(
                tab: _tabs[index],
                isActive: currentIndex == index,
                onTap: () => onTap(index),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _TabBarItem extends StatelessWidget {
  const _TabBarItem({
    required this.tab,
    required this.isActive,
    required this.onTap,
  });

  final _TabItem tab;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: double.infinity,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: context.isPhone ? 40 : 60,
                height: context.isPhone ? 40 : 60,
                child: Center(
                  child: Image.asset(
                    isActive ? tab.activeIcon : tab.icon,
                    height: context.isPhone ? 40 : 60,
                    fit: BoxFit.fitHeight,
                  ),
                ),
              ),
              const SizedBox(height: 4),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabItem {
  const _TabItem({
    required this.icon,
    required this.activeIcon,
  });

  final String icon;
  final String activeIcon;
}
