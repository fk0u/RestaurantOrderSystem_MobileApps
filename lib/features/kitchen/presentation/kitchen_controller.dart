import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../orders/data/order_repository.dart';
import '../../orders/domain/order_entity.dart';
import '../../../core/services/notification_service.dart';

final kitchenControllerProvider =
    StateNotifierProvider<KitchenController, AsyncValue<List<Order>>>((ref) {
      return KitchenController(ref.read(orderRepositoryProvider));
    });

class KitchenController extends StateNotifier<AsyncValue<List<Order>>> {
  final OrderRepository _repository;

  Timer? _timer;

  KitchenController(this._repository) : super(const AsyncValue.loading()) {
    loadOrders();
    _startPolling();
  }

  void _startPolling() {
    _timer = Timer.periodic(const Duration(seconds: 10), (_) {
      loadOrders();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> loadOrders() async {
    try {
      final orders = await _repository.getOrders();
      // Filter for active orders only (pending, cooking, ready)
      // For demo, maybe show all or just active. Let's show all non-completed for Kitchen.
      final activeOrders = orders
          .where((o) => o.status != 'Selesai' && o.status != 'Dibatalkan')
          .toList();
      state = AsyncValue.data(activeOrders);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateStatus(String orderId, String newStatus) async {
    try {
      await _repository.updateOrderStatus(orderId, newStatus);
      if (newStatus == 'Siap Saji') {
        final order = await _repository.getOrderById(orderId);
        if (order != null) {
          await NotificationService.showOrderReadyNotification(
            orderId: order.id,
            queueNumber: order.queueNumber,
            orderType: order.orderType,
            tableNumber: order.tableNumber,
          );
        }
      }
      await loadOrders(); // Refresh
    } catch (e) {
      // Handle error (maybe show toast? but controller can't easily do that without context)
      // Log error (replace with logger in production)
      // debugPrint('Error updating status: $e');
    }
  }
}
