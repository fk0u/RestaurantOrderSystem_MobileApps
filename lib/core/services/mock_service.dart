import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/tables/domain/table_entity.dart';
import '../../features/menu/domain/product_entity.dart';
import '../../features/orders/domain/order_entity.dart';

final mockServiceProvider = Provider((ref) => MockService());

class MockService {
  // final _uuid = const Uuid();

  // --- TABLES ---
  final List<RestaurantTable> _tables = List.generate(
    12,
    (index) => RestaurantTable(
      id: 'table_${index + 1}',
      number: 'T${index + 1}',
      capacity: 4,
      status: 'available',
      x: 0,
      y: 0,
    ),
  );

  Future<List<RestaurantTable>> getTables() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _tables;
  }

  Future<void> updateTableStatus(String id, String status) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _tables.indexWhere((t) => t.id == id);
    if (index != -1) {
      _tables[index] = _tables[index].copyWith(status: status);
    }
  }

  // --- MENU ---
  final List<Product> _products = [
    // Starter
    Product(
      id: 'p1',
      name: 'Caesar Salad',
      description: 'Fresh romaine lettuce with parmesan and croutons',
      price: 45000,
      imageUrl:
          'https://images.unsplash.com/photo-1550304943-4f24f54ddde9?auto=format&fit=crop&w=500&q=60',
      category: 'Starter',
      calories: 320,
      stock: 50,
    ),
    Product(
      id: 'p2',
      name: 'Mushroom Soup',
      description: 'Creamy woodland mushroom soup',
      price: 35000,
      imageUrl:
          'https://images.unsplash.com/photo-1547592166-23acbe3a624b?auto=format&fit=crop&w=500&q=60',
      category: 'Starter',
      calories: 250,
      stock: 40,
    ),
    // Main Course
    Product(
      id: 'p3',
      name: 'Grilled Salmon',
      description: 'Salmon fillet with asparagus and lemon butter sauce',
      price: 120000,
      imageUrl:
          'https://images.unsplash.com/photo-1467003909585-2f8a7270028d?auto=format&fit=crop&w=500&q=60',
      category: 'Main Course',
      calories: 650,
      stock: 20,
    ),
    Product(
      id: 'p4',
      name: 'Ribeye Steak',
      description: 'Premium Australian beef with mashed potatoes',
      price: 185000,
      imageUrl:
          'https://images.unsplash.com/photo-1600891964092-4316c288032e?auto=format&fit=crop&w=500&q=60',
      category: 'Main Course',
      calories: 850,
      stock: 15,
    ),
    Product(
      id: 'p5',
      name: 'Wagyu Burger',
      description: 'Juicy wagyu patty with cheddar and caramelized onions',
      price: 95000,
      imageUrl:
          'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?auto=format&fit=crop&w=500&q=60',
      category: 'Main Course',
      calories: 900,
      stock: 30,
    ),
    // Dessert
    Product(
      id: 'p6',
      name: 'Chocolate Lava Cake',
      description: 'Warm chocolate cake with vanilla ice cream',
      price: 55000,
      imageUrl:
          'https://images.unsplash.com/photo-1606313564200-e75d5e30476d?auto=format&fit=crop&w=500&q=60',
      category: 'Dessert',
      calories: 500,
      stock: 25,
    ),
    Product(
      id: 'p7',
      name: 'Tiramisu',
      description: 'Classic Italian coffee-flavoured dessert',
      price: 48000,
      imageUrl:
          'https://images.unsplash.com/photo-1571877227200-a0d98ea607e9?auto=format&fit=crop&w=500&q=60',
      category: 'Dessert',
      calories: 450,
      stock: 30,
    ),
    // Drinks
    Product(
      id: 'p8',
      name: 'Fresh Orange Juice',
      description: 'Squeezed from fresh oranges',
      price: 28000,
      imageUrl:
          'https://images.unsplash.com/photo-1613478223719-2ab802602423?auto=format&fit=crop&w=500&q=60',
      category: 'Drinks',
      calories: 120,
      stock: 100,
    ),
    Product(
      id: 'p9',
      name: 'Iced Latte',
      description: 'Espresso with cold milk and ice',
      price: 32000,
      imageUrl:
          'https://images.unsplash.com/photo-1517701604599-bb29b5dd7359?auto=format&fit=crop&w=500&q=60',
      category: 'Drinks',
      calories: 150,
      stock: 80,
    ),
  ];

  Future<List<Product>> getProducts() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _products;
  }

  // --- RESERVATIONS ---
  final List<dynamic> _reservations = [];

  Future<List<dynamic>> getReservations() async {
    await Future.delayed(const Duration(seconds: 1));
    return _reservations;
  }

  Future<dynamic> createReservation(Map<String, dynamic> data) async {
    await Future.delayed(const Duration(seconds: 1));
    final newReservation = {
      'id': 'res_${_reservations.length + 1}',
      ...data,
      'status': 'reserved',
    };
    _reservations.add(newReservation);
    return newReservation;
  }

  // --- ORDERS ---
  final List<Order> _orders = [];

  Future<List<Order>> getOrders({String? userId}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (userId != null) {
      return _orders.where((o) => o.userId == userId).toList();
    }
    return _orders;
  }

  Future<Order> createOrder(Order order) async {
    await Future.delayed(const Duration(seconds: 1));
    // Simulate ID generation if not present or just reuse
    // In PaymentScreen, logic generates ID. So we just save it.
    _orders.insert(0, order); // Add to top
    return order;
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      _orders[index] = _orders[index].copyWith(status: status);
    }
  }

  Future<void> createPayment(
    String orderId,
    String method,
    double amount,
  ) async {
    await Future.delayed(const Duration(seconds: 1));
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      _orders[index] = _orders[index].copyWith(
        paymentStatus: 'paid',
        paymentMethod: method,
        paidAt: DateTime.now(),
      );
    }
  }

  Future<Map<String, dynamic>> getSalesStats() async {
    await Future.delayed(const Duration(seconds: 1));
    final paidOrders = _orders.where((o) => o.paymentStatus == 'paid');
    final revenue = paidOrders.fold(0.0, (sum, o) => sum + o.totalPrice);
    return {
      'count': paidOrders.length,
      'revenue': revenue,
      'active_orders': _orders
          .where(
            (o) =>
                o.status == 'Sedang Diproses' || o.status == 'Sedang Dimasak',
          )
          .length,
    };
  }
}
