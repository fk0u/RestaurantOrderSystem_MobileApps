import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/presentation/auth_controller.dart';
import '../data/order_repository.dart';
import '../domain/order_entity.dart';
import '../../auth/domain/user_entity.dart';

final ordersControllerProvider = StateNotifierProvider.autoDispose<OrdersController, AsyncValue<List<Order>>>((ref) {
  return OrdersController(ref.read(orderRepositoryProvider), ref.read(authControllerProvider).value);
});

class OrdersController extends StateNotifier<AsyncValue<List<Order>>> {
  final OrderRepository _repository;
  final User? _user;

  OrdersController(this._repository, this._user) : super(const AsyncValue.loading()) {
    getOrders();
  }

  Future<void> getOrders() async {
    try {
      state = const AsyncValue.loading();
      final orders = await _repository.getOrders(userId: _user?.id);
      state = AsyncValue.data(orders);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}
