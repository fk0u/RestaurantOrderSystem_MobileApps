import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/presentation/auth_controller.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/cart/presentation/cart_screen.dart';
import '../../features/payment/presentation/payment_screen.dart';
import '../../features/menu/presentation/product_detail_screen.dart';
import '../../features/menu/domain/product_entity.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/tables/presentation/table_screen.dart';
import '../../features/menu/presentation/menu_screen.dart';
import '../../features/kitchen/presentation/kitchen_dashboard.dart';
import '../../features/admin/presentation/admin_dashboard.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/main_wrapper.dart';
import '../../features/orders_screen.dart';
import '../../features/profile_screen.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authControllerProvider);

  return GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isLoading = authState.isLoading;
      final hasError = authState.hasError;
      final isAuthenticated = authState.value != null;
      final user = authState.value;

      final isSplash = state.uri.toString() == '/splash';
      final isLogin = state.uri.toString() == '/login';
      final isRegister = state.uri.toString() == '/register';

      // Allow Splash to run
      if (isSplash) return null;

      if (isLoading || hasError) return null;

      if (!isAuthenticated) {
        if (isLogin || isRegister) return null;
        return '/login';
      }

      if (isLogin || isRegister) {
        switch (user?.role) {
          case 'admin': return '/admin';
          case 'kitchen': return '/kitchen';
          case 'cashier': return '/tables';
          case 'customer': default: return '/menu'; // Customer goes to menu directly
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/tables',
        builder: (context, state) => const TableScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register', // Placeholder for now, LoginScreen handles it internally
         builder: (context, state) => const LoginScreen(), 
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),

      // Customer Main Shell (The Dock)
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainWrapper(navigationShell: navigationShell);
        },
        branches: [
          // Tab 1: Home (Menu)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/menu',
                builder: (context, state) => const MenuScreen(),
              ),
            ],
          ),
          // Tab 2: Orders
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/orders',
                builder: (context, state) => const OrdersScreen(),
              ),
            ],
          ),
          // Tab 3: Cart
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/cart',
                builder: (context, state) => const CartScreen(),
              ),
            ],
          ),
          // Tab 4: Profile
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

      GoRoute(path: '/payment', builder: (context, state) => const PaymentScreen()),
      GoRoute(path: '/kitchen', builder: (context, state) => const KitchenDashboard()),
      GoRoute(path: '/admin', builder: (context, state) => const AdminDashboard()),
      GoRoute(
        path: '/product_detail',
        builder: (context, state) {
          final product = state.extra as Product;
          return ProductDetailScreen(product: product);
        },
      ),
    ],
  );
});
