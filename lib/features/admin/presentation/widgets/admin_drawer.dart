import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:restaurant_order_system/features/auth/presentation/auth_controller.dart';
import '../../../../core/theme/design_system.dart';

class AdminDrawer extends ConsumerWidget {
  const AdminDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Drawer(
      backgroundColor: AppColors.surface,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary,
                  AppColors.primary.withValues(alpha: 0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.admin_panel_settings,
                    size: 32,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Admin Panel',
                        style: AppTypography.heading3.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'admin@resto.com',
                        style: AppTypography.bodySmall.copyWith(
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _DrawerItem(
                  icon: Icons.dashboard_outlined,
                  activeIcon: Icons.dashboard,
                  title: 'Dashboard',
                  route: '/admin',
                  onTap: () {
                    context.pop();
                    context.go('/admin');
                  },
                ),
                const SizedBox(height: 4),
                _DrawerItem(
                  icon: Icons.category_outlined,
                  activeIcon: Icons.category,
                  title: 'Kategori Menu',
                  route: '/admin/categories',
                  onTap: () {
                    context.pop();
                    context.push('/admin/categories');
                  },
                ),
                const SizedBox(height: 4),
                _DrawerItem(
                  icon: Icons.restaurant_menu_outlined,
                  activeIcon: Icons.restaurant_menu,
                  title: 'Manajemen Menu',
                  route: '/admin/products',
                  onTap: () {
                    context.pop();
                    context.push('/admin/products');
                  },
                ),
                const SizedBox(height: 4),
                _DrawerItem(
                  icon: Icons.receipt_long_outlined,
                  activeIcon: Icons.receipt_long,
                  title: 'Manajemen Pesanan',
                  route: '/admin/orders',
                  onTap: () {
                    context.pop();
                    context.push('/admin/orders');
                  },
                ),
              ],
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _DrawerItem(
              icon: Icons.logout,
              activeIcon: Icons.logout,
              title: 'Keluar',
              isDestructive: true,
              onTap: () {
                ref.read(authControllerProvider.notifier).logout();
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String title;
  final VoidCallback onTap;
  final String? route;
  final bool isDestructive;

  const _DrawerItem({
    required this.icon,
    required this.activeIcon,
    required this.title,
    required this.onTap,
    this.route,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    // Basic check for active route - strictly speaking we should check GoRouter state
    // keeping it simple for now or just handling tap.
    // For specific active state visual, we might need to pass current route.
    // Assuming simplistic approach for now.

    final color = isDestructive ? Colors.red : AppColors.textPrimary;
    final iconData = isDestructive ? icon : icon;

    return ListTile(
      leading: Icon(iconData, color: color),
      title: Text(
        title,
        style: AppTypography.bodyMedium.copyWith(
          color: color,
          fontWeight: isDestructive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      hoverColor: isDestructive
          ? Colors.red.withValues(alpha: 0.05)
          : AppColors.primary.withValues(alpha: 0.05),
    );
  }
}
