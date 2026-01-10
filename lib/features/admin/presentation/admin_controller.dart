import 'package:flutter_riverpod/flutter_riverpod.dart';

class OrderSummary {
  final String orderId;
  final double total;
  final String date;
  final String status;

  OrderSummary(this.orderId, this.total, this.date, this.status);
}

final adminControllerProvider = StateNotifierProvider<AdminController, AsyncValue<List<OrderSummary>>>((ref) {
  return AdminController();
});

class AdminController extends StateNotifier<AsyncValue<List<OrderSummary>>> {
  AdminController() : super(const AsyncValue.loading()) {
    _loadStats();
  }

  Future<void> _loadStats() async {
    state = const AsyncValue.loading();
    await Future.delayed(const Duration(seconds: 1)); // Mock loading
    
    // Mock Data
    state = AsyncValue.data([
      OrderSummary('ORD-001', 150000, '2023-10-27 12:30', 'Completed'),
      OrderSummary('ORD-002', 75000, '2023-10-27 12:45', 'Completed'),
      OrderSummary('ORD-003', 220000, '2023-10-27 13:10', 'Completed'),
      OrderSummary('ORD-004', 55000, '2023-10-27 13:20', 'Pending'),
    ]);
  }
}
