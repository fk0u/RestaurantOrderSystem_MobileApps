import 'package:get_it/get_it.dart';
import '../../core/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/auth/data/auth_repository.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/menu/data/menu_repository.dart';
import '../../features/menu/presentation/bloc/menu_bloc.dart';
import '../../features/cart/presentation/bloc/cart_bloc.dart';
import '../../core/network/api_client.dart';
import '../../features/orders/data/order_repository.dart';
import '../../features/orders/presentation/bloc/order_bloc.dart';
import '../../features/tables/data/table_repository.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //! External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  //! Features - Auth
  // Repository
  sl.registerLazySingleton<StorageService>(() => StorageService(sl()));

  //! Features - Auth
  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepository(sl(), ApiClient()),
  );

  // Bloc
  sl.registerFactory(() => AuthBloc(authRepository: sl()));

  //! Features - Menu
  // Repository
  sl.registerLazySingleton<MenuRepository>(() => MenuRepository(ApiClient()));

  // Bloc
  sl.registerFactory(() => MenuBloc(menuRepository: sl()));

  //! Features - Cart
  sl.registerFactory(() => CartBloc());

  //! Features - Table
  // Repository
  sl.registerLazySingleton<TableRepository>(() => TableRepository(ApiClient()));

  //! Features - Order
  // Repository
  sl.registerLazySingleton<OrderRepository>(() => OrderRepository(ApiClient()));

  // Bloc
  sl.registerFactory(
    () => OrderBloc(orderRepository: sl(), tableRepository: sl()),
  );
}
