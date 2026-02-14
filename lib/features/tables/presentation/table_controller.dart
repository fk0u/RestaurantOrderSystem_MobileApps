import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/table_repository.dart';
import '../domain/table_entity.dart';

final tableControllerProvider =
    StateNotifierProvider.autoDispose<
      TableController,
      AsyncValue<List<RestaurantTable>>
    >((ref) {
      return TableController(ref.read(tableRepositoryProvider));
    });

class TableController extends StateNotifier<AsyncValue<List<RestaurantTable>>> {
  final TableRepository _repository;

  TableController(this._repository) : super(const AsyncValue.loading()) {
    loadTables();
  }

  Future<void> loadTables() async {
    try {
      final tables = await _repository.getTables();
      state = AsyncValue.data(tables);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateStatus(String id, String status) async {
    try {
      await _repository.updateTableStatus(id, status);
      await loadTables();
    } catch (e) {
      // Log error
    }
  }
}

final selectedTableProvider = StateProvider<RestaurantTable?>((ref) => null);
final selectedSeatCountProvider = StateProvider<int?>((ref) => null);
