import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/services/storage_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/pusher_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/di/injection_container.dart' as di;
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/menu/presentation/bloc/menu_bloc.dart';
import 'features/menu/presentation/bloc/menu_event.dart';
import 'features/cart/presentation/bloc/cart_bloc.dart';
import 'features/cart/presentation/bloc/cart_event.dart';
import 'features/orders/presentation/bloc/order_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await di.init(); // Initialize GetIt
  final storageService = await StorageService.init();
  await NotificationService.init();
  await PusherService.init();

  runApp(
    ProviderScope(
      overrides: [storageServiceProvider.overrideWithValue(storageService)],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => di.sl<AuthBloc>()..add(AuthCheckRequested()),
          ),
          BlocProvider(
            create: (_) => di.sl<MenuBloc>()..add(FetchMenuProducts()),
          ),
          BlocProvider(create: (_) => di.sl<CartBloc>()..add(LoadCart())),
          BlocProvider(create: (_) => di.sl<OrderBloc>()),
        ],
        child: const RestaurantApp(),
      ),
    ),
  );
}

class RestaurantApp extends ConsumerWidget {
  const RestaurantApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Restaurant Order System',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}
