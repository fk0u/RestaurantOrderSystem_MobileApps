import 'package:flutter_riverpod/flutter_riverpod.dart';

// Mock Order Model for Kitchen
class KitchenOrder {
  final String id;
  final String tableName;
  final List<String> items;
  final String status; // 'pending', 'cooking', 'ready', 'completed'
  final DateTime timestamp;

  KitchenOrder({
    required this.id,
    required this.tableName,
    required this.items,
    required this.status,
    required this.timestamp,
  });

  KitchenOrder copyWith({String? status}) {
    return KitchenOrder(
      id: id,
      tableName: tableName,
      items: items,
      status: status ?? this.status,
      timestamp: timestamp,
    );
  }
}

final kitchenControllerProvider = StateNotifierProvider<KitchenController, List<KitchenOrder>>((ref) {
  return KitchenController();
});

class KitchenController extends StateNotifier<List<KitchenOrder>> {
  KitchenController() : super([
    // Initial Mock Data (Localized)
    KitchenOrder(
      id: 'ORD-001',
      tableName: 'Meja 3',
      items: ['Ayam Goreng Krispi x 2', 'Es Teh Lemon x 2'],
      status: 'pending',
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
    KitchenOrder(
      id: 'ORD-002',
      tableName: 'Meja 5',
      items: ['Burger Sapi Deluxe x 1'],
      status: 'cooking',
      timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
    ),
    KitchenOrder(
      id: 'ORD-003',
      tableName: 'Bawa Pulang - 001',
      items: ['Pasta Carbonara x 1', 'Es Teh Lemon x 1'],
      status: 'ready',
      timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
    ),
  ]);

  void updateStatus(String orderId, String newStatus) {
    state = state.map((order) {
      if (order.id == orderId) {
        return order.copyWith(status: newStatus);
      }
      return order;
    }).toList();
  }
}
