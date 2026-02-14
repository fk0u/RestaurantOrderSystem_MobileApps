import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:restaurant_order_system/features/orders/data/order_repository.dart';
import 'package:restaurant_order_system/features/orders/domain/order_entity.dart';

final adminOrdersControllerProvider =
    StateNotifierProvider.autoDispose<
      AdminOrdersController,
      AsyncValue<List<Order>>
    >((ref) {
      return AdminOrdersController(ref.read(orderRepositoryProvider));
    });

class AdminOrdersController extends StateNotifier<AsyncValue<List<Order>>> {
  final OrderRepository _repository;

  AdminOrdersController(this._repository) : super(const AsyncValue.loading()) {
    getOrders();
  }

  Future<void> getOrders() async {
    try {
      state = const AsyncValue.loading();
      // Fetch all orders (no userId filter)
      final orders = await _repository.getOrders();
      state = AsyncValue.data(orders);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateStatus(String orderId, String status) async {
    try {
      await _repository.updateOrderStatus(orderId, status);
      await getOrders(); // Refresh list
    } catch (e) {
      // Handle error (UI should show toast via repo or catch here)
      print('Error updating status: $e');
    }
  }
}
