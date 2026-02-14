import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/order_entity.dart';
import '../../../core/services/mock_service.dart';

final orderRepositoryProvider = Provider((ref) => OrderRepository());

class OrderRepository {
  final MockService _service =
      MockService(); // Should ideally be injected via provider but consistent with other repos

  Future<int> getNextQueueNumber(String orderType, DateTime date) async {
    return 0;
  }

  Future<Order> createOrder(Order order) async {
    return await _service.createOrder(order);
  }

  Future<List<Order>> getOrders({String? userId}) async {
    return await _service.getOrders(userId: userId);
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    await _service.updateOrderStatus(orderId, newStatus);
  }

  Future<void> createPayment({
    required String orderId,
    required String method,
    required double amount,
    String? reference,
  }) async {
    await _service.createPayment(orderId, method, amount);
  }

  Future<Order?> getOrderById(String orderId) async {
    final orders = await _service.getOrders();
    for (final order in orders) {
      if (order.id == orderId) return order;
    }
    return null;
  }

  Future<Map<String, dynamic>> getSalesStats() async {
    return await _service.getSalesStats();
  }
}
