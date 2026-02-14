import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/design_system.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth/presentation/auth_controller.dart';

class MainWrapper extends ConsumerStatefulWidget {
  final StatefulNavigationShell navigationShell;

  const MainWrapper({super.key, required this.navigationShell});

  @override
  ConsumerState<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends ConsumerState<MainWrapper> {
  // Map Navbar Index to Shell Branch Index based on role
  int _mapIndex(int navIndex, bool isAdminOrStaff) {
    if (isAdminOrStaff) return navIndex;
    // Customer: Skip index 0 (Tables)
    // 0 -> 1 (Home)
    // 1 -> 2 (Orders)
    // 2 -> 3 (Cart)
    // 3 -> 4 (Profile)
    return navIndex + 1;
  }

  // Map Shell Branch Index to Navbar Index based on role
  int _unmapIndex(int shellIndex, bool isAdminOrStaff) {
    if (isAdminOrStaff) return shellIndex;
    if (shellIndex == 0) return 0; // Should not happen for customer
    return shellIndex - 1;
  }

  void _goBranch(int navIndex, bool isAdminOrStaff) {
    final branchIndex = _mapIndex(navIndex, isAdminOrStaff);
    widget.navigationShell.goBranch(
      branchIndex,
      initialLocation: branchIndex == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final user = authState.valueOrNull;
    final isAdminOrStaff =
        user?.role == 'admin' ||
        user?.role == 'staff' ||
        user?.role == 'kitchen';

    final destinations = <NavigationDestination>[
      if (isAdminOrStaff)
        const NavigationDestination(
          icon: Icon(Icons.table_restaurant_outlined),
          selectedIcon: Icon(Icons.table_restaurant, color: AppColors.primary),
          label: 'Meja',
        ),
      const NavigationDestination(
        icon: Icon(Icons.home_outlined),
        selectedIcon: Icon(Icons.home, color: AppColors.primary),
        label: 'Beranda',
      ),
      const NavigationDestination(
        icon: Icon(Icons.receipt_long_outlined),
        selectedIcon: Icon(Icons.receipt_long, color: AppColors.primary),
        label: 'Pesanan',
      ),
      const NavigationDestination(
        icon: Icon(Icons.shopping_bag_outlined),
        selectedIcon: Icon(Icons.shopping_bag, color: AppColors.primary),
        label: 'Keranjang',
      ),
      const NavigationDestination(
        icon: Icon(Icons.person_outline),
        selectedIcon: Icon(Icons.person, color: AppColors.primary),
        label: 'Profil',
      ),
    ];

    final currentShellIndex = widget.navigationShell.currentIndex;
    // For customers, if they are somehow on index 0 (Tables), default to Home (index 0 of navbar -> 1 of shell)
    if (!isAdminOrStaff && currentShellIndex == 0) {
      // This might happen on initial load if redirect logic fails or previous state persists
      // But AppRouter redirect should handle it.
      // Just in case, we don't return anything special, the mapping handles it visualy?
      // No, we need safe index.
    }

    final navIndex = _unmapIndex(currentShellIndex, isAdminOrStaff);
    // Safety check
    final safeNavIndex = navIndex.clamp(0, destinations.length - 1);

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
            selectedIndex: safeNavIndex,
            onDestinationSelected: (idx) => _goBranch(idx, isAdminOrStaff),
            labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
            destinations: destinations,
          ),
        ),
      ),
    );
  }
}
