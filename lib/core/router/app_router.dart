import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/main_wrapper.dart';
import '../../features/menu/presentation/menu_screen.dart';
import '../../features/orders_screen.dart';
import '../../features/payment/presentation/payment_screen.dart';
import '../../features/kitchen/presentation/kitchen_screen.dart';
import '../../features/admin/presentation/dashboard_screen.dart';
import '../../features/cart/presentation/cart_screen.dart';
import '../../features/tables/presentation/table_screen.dart';
import '../../features/profile_screen.dart';
// Will add other screens as they are implemented

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/login',
  routes: [
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(
      path: '/payment',
      builder: (context, state) => const PaymentScreen(),
    ),
    GoRoute(
      path: '/kitchen',
      builder: (context, state) => const KitchenScreen(),
    ),
    GoRoute(
      path: '/admin',
      builder: (context, state) => const DashboardScreen(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainWrapper(navigationShell: navigationShell);
      },
      branches: [
        // Tables
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/tables',
              builder: (context, state) => const TableScreen(),
            ),
          ],
        ),
        // Home (Menu)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/menu',
              builder: (context, state) => const MenuScreen(),
            ),
          ],
        ),
        // Orders
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/orders',
              builder: (context, state) => const OrdersScreen(),
            ),
          ],
        ),
        // Cart
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/cart',
              builder: (context, state) => const CartScreen(),
            ),
          ],
        ),
        // Profile
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
