import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/design_system.dart';

class MainWrapper extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const MainWrapper({super.key, required this.navigationShell});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  void _goBranch(int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: widget.navigationShell, // The current tab's body
      extendBody: true, // Allow body to flow behind the floating dock
      bottomNavigationBar: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppDimens.s21,
          vertical: AppDimens.s21,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.95), // Glass-ish
          borderRadius: BorderRadius.circular(AppDimens.r32),
          boxShadow: AppShadows.dock,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppDimens.r32),
          child: NavigationBar(
            height: 70,
            backgroundColor: Colors.transparent,
            indicatorColor: AppColors.primary.withValues(alpha: 0.15),
            selectedIndex: widget.navigationShell.currentIndex,
            onDestinationSelected: _goBranch,
            labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.table_restaurant_outlined),
                selectedIcon: Icon(
                  Icons.table_restaurant,
                  color: AppColors.primary,
                ),
                label: 'Meja',
              ),
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home, color: AppColors.primary),
                label: 'Beranda',
              ),
              NavigationDestination(
                icon: Icon(Icons.receipt_long_outlined),
                selectedIcon: Icon(
                  Icons.receipt_long,
                  color: AppColors.primary,
                ),
                label: 'Pesanan',
              ),
              NavigationDestination(
                icon: Icon(Icons.shopping_bag_outlined),
                selectedIcon: Icon(
                  Icons.shopping_bag,
                  color: AppColors.primary,
                ),
                label: 'Keranjang',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person, color: AppColors.primary),
                label: 'Profil',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
