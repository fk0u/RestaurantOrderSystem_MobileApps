import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../orders/data/order_repository.dart';

class OrderSummary {
  final String orderId;
  final double total;
  final String date;
  final String status;

  OrderSummary(this.orderId, this.total, this.date, this.status);
}

final adminControllerProvider = StateNotifierProvider<AdminController, AsyncValue<List<OrderSummary>>>((ref) {
  return AdminController(ref.read(orderRepositoryProvider));
});

class AdminController extends StateNotifier<AsyncValue<List<OrderSummary>>> {
  final OrderRepository _repository;

  AdminController(this._repository) : super(const AsyncValue.loading()) {
    _loadStats();
  }

  Future<void> _loadStats() async {
    state = const AsyncValue.loading();
    try {
      final orders = await _repository.getOrders();
      // final stats = await _repository.getSalesStats(); // Kept for future use if needed, or just remove.
      
      // We are fetching all orders, but for the summary list let's just use the recent ones.
      // But we need to pass the Total Revenue from the DB stats, not just the list sum (if we wanted pagination).
      // For now, since getOrders returns all, we can compute locally or use the DB stats.
      // Let's use the DB stats for the "Top Cards" and the list for the "List".
      // But the state is List<OrderSummary>. 
      // I should update the state to be a custom class or just map the orders.
      // For simplicity, I will stick to mapping orders but I will inject the DB total into the first item or handle it in UI?
      // Actually AdminDashboard computes totalSales from the list: final totalSales = orders.fold(...)
      // So if getOrders() returns all orders, that's fine.
      
      final summaries = orders.map((o) => OrderSummary(
        o.id,
        o.totalPrice,
        o.timestamp.toString(), 
        o.status,
      )).toList();
      state = AsyncValue.data(summaries);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}
