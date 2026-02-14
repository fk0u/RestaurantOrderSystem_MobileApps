import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/auth_controller.dart';
import '../../features/main_wrapper.dart';
import '../../features/menu/presentation/menu_screen.dart';
import '../../features/orders_screen.dart';
import '../../features/payment/presentation/payment_screen.dart';
import '../../features/kitchen/presentation/kitchen_screen.dart';
import '../../features/admin/presentation/dashboard_screen.dart';
import '../../features/admin/presentation/category_management_screen.dart';
import '../../features/admin/presentation/product_management_screen.dart';
import '../../features/admin/presentation/order_management_screen.dart';
import '../../features/cart/presentation/cart_screen.dart';
import '../../features/tables/presentation/table_screen.dart';
import '../../features/profile_screen.dart';
import '../../features/menu/presentation/product_detail_screen.dart';
import '../../features/menu/domain/product_entity.dart';

import '../../features/home/presentation/order_type_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authControllerProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/login',
    refreshListenable: GoRouterRefreshStream(
      ref.watch(authControllerProvider.notifier).stream,
    ),
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull != null;
      final isLoggingIn = state.uri.toString() == '/login';

      if (!isLoggedIn && !isLoggingIn) {
        return '/login';
      }

      if (isLoggedIn && isLoggingIn) {
        final user = authState.value;
        if (user?.role == 'admin') return '/admin';
        if (user?.role == 'kitchen') return '/kitchen';
        return '/order-type'; // New home for staff/customer
      }

      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/order-type',
        builder: (context, state) => const OrderTypeScreen(),
      ),
      GoRoute(
        path: '/payment',
        builder: (context, state) => const PaymentScreen(),
      ),
      GoRoute(
        path: '/kitchen',
        builder: (context, state) => const KitchenScreen(),
      ),
      GoRoute(
        path: '/product_detail',
        builder: (context, state) {
          final product = state.extra as Product;
          return ProductDetailScreen(product: product);
        },
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const DashboardScreen(),
        routes: [
          GoRoute(
            path: 'categories',
            builder: (context, state) => const CategoryManagementScreen(),
          ),
          GoRoute(
            path: 'products',
            builder: (context, state) => const ProductManagementScreen(),
          ),
          GoRoute(
            path: 'orders',
            builder: (context, state) => const OrderManagementScreen(),
          ),
        ],
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
});

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final dynamic _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
