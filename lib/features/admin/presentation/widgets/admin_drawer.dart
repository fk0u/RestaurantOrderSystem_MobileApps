import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:restaurant_order_system/features/auth/presentation/auth_controller.dart';

class AdminDrawer extends ConsumerWidget {
  const AdminDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const UserAccountsDrawerHeader(
            accountName: Text('Admin'),
            accountEmail: Text('admin@resto.com'),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.admin_panel_settings, color: Colors.blue),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () {
              context.pop(); // Close drawer
              context.go('/admin');
            },
          ),
          ListTile(
            leading: const Icon(Icons.category),
            title: const Text('Kategori Menu'),
            onTap: () {
              context.pop();
              context.push('/admin/categories');
            },
          ),
          ListTile(
            leading: const Icon(Icons.restaurant_menu),
            title: const Text('Manajemen Menu & Stok'),
            onTap: () {
              context.pop();
              context.push('/admin/products');
            },
          ),
          ListTile(
            leading: const Icon(Icons.receipt_long),
            title: const Text('Manajemen Pesanan'),
            onTap: () {
              context.pop();
              context.push('/admin/orders');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () {
              ref.read(authControllerProvider.notifier).logout();
            },
          ),
        ],
      ),
    );
  }
}
