import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../orders/data/order_repository.dart';

final dashboardControllerProvider =
    StateNotifierProvider.autoDispose<
      DashboardController,
      AsyncValue<Map<String, dynamic>>
    >((ref) {
      return DashboardController(ref.read(orderRepositoryProvider));
    });

class DashboardController
    extends StateNotifier<AsyncValue<Map<String, dynamic>>> {
  final OrderRepository _repository;

  DashboardController(this._repository) : super(const AsyncValue.loading()) {
    loadStats();
  }

  Future<void> loadStats() async {
    try {
      state = const AsyncValue.loading();
      final stats = await _repository.getSalesStats();
      state = AsyncValue.data(stats);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> refresh() => loadStats();
}
