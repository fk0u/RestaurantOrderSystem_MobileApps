import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/table_repository.dart';
import '../domain/table_entity.dart';

final tableControllerProvider =
    StateNotifierProvider.autoDispose<
      TableController,
      AsyncValue<List<RestaurantTable>>
    >((ref) {
      final controller = TableController(ref.read(tableRepositoryProvider));
      ref.onDispose(() => controller.dispose());
      return controller;
    });

class TableController extends StateNotifier<AsyncValue<List<RestaurantTable>>> {
  final TableRepository _repository;
  Timer? _pollTimer;

  TableController(this._repository) : super(const AsyncValue.loading()) {
    loadTables();
    _startPolling();
  }

  void _startPolling() {
    _pollTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _silentRefresh();
    });
  }

  /// Refreshes data without emitting a loading state (prevents UI flicker)
  Future<void> _silentRefresh() async {
    try {
      final tables = await _repository.getTables();
      if (mounted) {
        state = AsyncValue.data(tables);
      }
    } catch (_) {
      // Silently ignore poll errors to avoid disrupting the UI
    }
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

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }
}

final selectedTableProvider = StateProvider<RestaurantTable?>((ref) => null);
final selectedSeatCountProvider = StateProvider<int?>((ref) => null);
