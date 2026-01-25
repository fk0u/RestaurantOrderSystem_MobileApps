import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../cart/domain/cart_item.dart';
import '../../menu/domain/product_entity.dart';
import '../domain/order_entity.dart';
import '../../../core/services/api_client.dart';

final orderRepositoryProvider = Provider((ref) => OrderRepository());

class OrderRepository {
  final ApiClient _api = ApiClient();

  Future<int> getNextQueueNumber(String orderType, DateTime date) async {
    return 0;
  }

  Future<Order> createOrder(Order order) async {
    final response = await _api.post('/orders', {
      'user_id': order.userId == 'guest' ? null : order.userId,
      'order_type': order.orderType,
      'table_id': order.tableId,
      'table_number': order.tableNumber,
      'table_capacity': order.tableCapacity,
      'promo_code': order.promoCode,
      'items': order.items.map((item) {
        return {
          'product_id': int.tryParse(item.product.id) ?? item.product.id,
          'quantity': item.quantity,
          'note': item.note,
          'modifiers': item.modifiers,
        };
      }).toList(),
    });

    final items = (response['items'] as List<dynamic>? ?? []).map((itemMap) {
      final product = Product(
        id: itemMap['product_id']?.toString() ?? '',
        name: itemMap['product_name'] ?? '',
        description: '',
        price: (itemMap['product_price'] as num?)?.toDouble() ?? 0,
        imageUrl: '',
        category: '',
      );
      final modifiers = (itemMap['modifiers'] as List<dynamic>? ?? []).map((e) => e.toString()).toList();
      return CartItem(
        product: product,
        quantity: (itemMap['quantity'] as num?)?.toInt() ?? 0,
        note: itemMap['note'] as String?,
        modifiers: modifiers,
      );
    }).toList();

    final payment = response['payment'] as Map<String, dynamic>?;

    return Order(
      id: response['id'].toString(),
      userId: response['user_id']?.toString() ?? 'guest',
      userName: response['user']?['name'] ?? order.userName,
      totalPrice: (response['total'] as num?)?.toDouble() ?? order.totalPrice,
      status: response['status'] ?? order.status,
      promoCode: response['promo_code'],
      discount: (response['discount'] as num?)?.toDouble() ?? 0,
      timestamp: DateTime.tryParse(response['created_at'] ?? '') ?? DateTime.now(),
      orderType: response['order_type'] ?? order.orderType,
      tableId: response['table_id']?.toString(),
      tableNumber: response['table_number'],
      tableCapacity: response['table_capacity'] as int?,
      queueNumber: (response['queue_number'] as num?)?.toInt() ?? 0,
      readyAt: response['ready_at'] != null ? DateTime.tryParse(response['ready_at']) : null,
      paymentStatus: payment?['status']?.toString(),
      paymentMethod: payment?['method']?.toString(),
      paidAt: payment?['paid_at'] != null ? DateTime.tryParse(payment?['paid_at']) : null,
      items: items,
    );
  }

  Future<List<Order>> getOrders({String? userId}) async {
    final data = await _api.getList('/orders', query: {
      if (userId != null && userId.isNotEmpty) 'user_id': userId,
    });
    return data.map((item) {
      final map = item as Map<String, dynamic>;
      final items = (map['items'] as List<dynamic>? ?? []).map((itemMap) {
        final product = Product(
          id: itemMap['product_id']?.toString() ?? '',
          name: itemMap['product_name'] ?? '',
          description: '',
          price: (itemMap['product_price'] as num?)?.toDouble() ?? 0,
          imageUrl: '',
          category: '',
        );
        final modifiers = (itemMap['modifiers'] as List<dynamic>? ?? []).map((e) => e.toString()).toList();
        return CartItem(
          product: product,
          quantity: (itemMap['quantity'] as num?)?.toInt() ?? 0,
          note: itemMap['note'] as String?,
          modifiers: modifiers,
        );
      }).toList();

      final payment = map['payment'] as Map<String, dynamic>?;

      return Order(
        id: map['id'].toString(),
        userId: map['user_id']?.toString() ?? 'guest',
        userName: map['user']?['name'] ?? 'Guest',
        totalPrice: (map['total'] as num?)?.toDouble() ?? 0,
        status: map['status'] ?? 'Sedang Diproses',
        promoCode: map['promo_code'],
        discount: (map['discount'] as num?)?.toDouble() ?? 0,
        timestamp: DateTime.tryParse(map['created_at'] ?? '') ?? DateTime.now(),
        orderType: map['order_type'] ?? 'takeaway',
        tableId: map['table_id']?.toString(),
        tableNumber: map['table_number'],
        tableCapacity: map['table_capacity'] as int?,
        queueNumber: (map['queue_number'] as num?)?.toInt() ?? 0,
        readyAt: map['ready_at'] != null ? DateTime.tryParse(map['ready_at']) : null,
        paymentStatus: payment?['status']?.toString(),
        paymentMethod: payment?['method']?.toString(),
        paidAt: payment?['paid_at'] != null ? DateTime.tryParse(payment?['paid_at']) : null,
        items: items,
      );
    }).toList();
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    await _api.patch('/orders/$orderId/status', {
      'status': newStatus,
    });
  }

  Future<void> createPayment({
    required String orderId,
    required String method,
    required double amount,
    String? reference,
  }) async {
    await _api.post('/orders/$orderId/payment', {
      'method': method,
      'amount': amount,
      'reference': reference,
      'status': 'paid',
    });
  }

  Future<Order?> getOrderById(String orderId) async {
    final orders = await getOrders();
    for (final order in orders) {
      if (order.id == orderId) return order;
    }
    return null;
  }

  Future<Map<String, dynamic>> getSalesStats() async {
    return {'count': 0, 'revenue': 0.0};
  }
}
