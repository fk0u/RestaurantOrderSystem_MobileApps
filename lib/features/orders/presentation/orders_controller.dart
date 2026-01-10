import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/order_repository.dart';
import '../domain/order_entity.dart';

final ordersControllerProvider = StateNotifierProvider.autoDispose<OrdersController, AsyncValue<List<Order>>>((ref) {
  return OrdersController(ref.read(orderRepositoryProvider));
});

class OrdersController extends StateNotifier<AsyncValue<List<Order>>> {
  final OrderRepository _repository;

  OrdersController(this._repository) : super(const AsyncValue.loading()) {
    getOrders();
  }

  Future<void> getOrders() async {
    try {
      state = const AsyncValue.loading();
      final orders = await _repository.getOrders();
      state = AsyncValue.data(orders);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}
