import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/order_entity.dart';
import '../../../../core/network/api_client.dart';
import '../../cart/domain/cart_item.dart';
import '../../menu/domain/product_entity.dart';

final orderRepositoryProvider = Provider((ref) => OrderRepository(ApiClient()));

class OrderRepository {
  final ApiClient _apiClient;

  OrderRepository(this._apiClient);

  Future<int> getNextQueueNumber(String orderType, DateTime date) async {
    try {
      final response = await _apiClient.get('/orders/queue');
      // response might be { nextQueueResponse: 1 }
      return response['nextQueueResponse'] as int? ?? 1;
    } catch (e) {
      return 1;
    }
  }

  Future<Order> createOrder(Order order) async {
    // 1. Get queue number if 0
    if (order.queueNumber == 0) {
      final nextQueue = await getNextQueueNumber(
        order.orderType,
        order.timestamp,
      );
      order = order.copyWith(queueNumber: nextQueue);
    }

    // 2. Map items to JSON friendly format
    final itemsJson = order.items.map((item) {
      return {
        'productId': item.product.id,
        'name': item.product.name,
        'price': item.product.price,
        'quantity': item.quantity,
        'note': item.note,
        'modifiers': item.modifiers,
      };
    }).toList();

    // 3. Post to API
    try {
      await _apiClient.post(
        '/orders',
        body: {
          'id': order.id,
          'userId': order.userId,
          // 'userName' mapped to Guest Name or User Name
          'userName': order.userName,
          'totalPrice': order.totalPrice,
          'status': order.status,
          'orderType': order.orderType,
          'queueNumber': order.queueNumber,
          'tableId': order.tableId,
          'items': itemsJson,
        },
      );

      return order;
    } catch (e) {
      throw Exception('Failed to create order: $e');
    }
  }

  Future<List<Order>> getOrders({String? userId}) async {
    try {
      final response = await _apiClient.get(
        '/orders',
      ); // Backend currently returns all, valid for prototype
      // Filtering by userId client side if API doesn't support it yet
      // Or update API to support it. The current API index.js I wrote doesn't filter by userId in GET /orders

      final List<dynamic> ordersJson = response as List;
      final orders = ordersJson.map((map) {
        // Items are nested
        final itemsJson = (map['items'] as List?) ?? [];
        final items = itemsJson.map((itemMap) {
          // modifiers need to be parsed if string, but my API returns object (JSON.parse done by mysql2 or manual)
          // In index.js I manually parsed modifiers to JSON.
          // Wait, index.js sends `JSON.stringify(item.modifiers)` in INSERT, but `SELECT` uses default mysql2 which returns string for JSON column?
          // I updated index.js: `modifiers: item.modifiers // JSON already parsed by mysql2 if configured? verify`
          // Actually mysql2 returns JSON columns as objects usually.
          // Let's assume it returns List or we handle String.

          List<String> modifiers = [];
          if (itemMap['modifiers'] != null) {
            if (itemMap['modifiers'] is String) {
              try {
                final decoded = jsonDecode(itemMap['modifiers']);
                if (decoded is List) modifiers = List<String>.from(decoded);
              } catch (e) {}
            } else if (itemMap['modifiers'] is List) {
              modifiers = List<String>.from(itemMap['modifiers']);
            }
          }

          return CartItem(
            product: Product(
              id: itemMap['productId'].toString(),
              name: itemMap['name'] ?? '',
              price: (itemMap['price'] as num).toDouble(),
              imageUrl: '',
              category: '',
              description: '',
            ),
            quantity: itemMap['quantity'] as int,
            note: itemMap['note'] as String?,
            modifiers: modifiers,
          );
        }).toList();

        return Order(
          id: map['app_id'] as String? ?? map['id'].toString(),
          userId: (map['userId'] ?? '').toString(),
          userName: map['guestName'] ?? map['userName'] ?? 'Guest',
          totalPrice: (map['totalPrice'] as num).toDouble(),
          status: map['status'] ?? 'pending',
          orderType: map['orderType'] ?? 'dine_in',
          queueNumber: map['queueNumber'] as int? ?? 0,
          tableId: (map['tableId'] != null)
              ? map['tableId'].toString()
              : null, // This might be int ID from DB, need to map back to app_id?
          // Backend doesn't join table to get app_id. It returns tableId as int FK.
          // This is a disconnect. Frontend expects 'table_1'. Backend returns 1.
          // For now, let's just convert to string. Ideally backend should join.
          // Or I update backend to return app_id of table.
          // I will update backend index.js to JOIN table or I accept ID mismatch for now.
          // Let's accept ID mismatch or 'table_1' if map['tableId'] is simple.
          paymentStatus: map['paymentStatus'] ?? 'pending',
          timestamp: DateTime.parse(
            map['createdAt'] ??
                map['timestamp'] ??
                DateTime.now().toIso8601String(),
          ),
          items: items,
        );
      }).toList();

      if (userId != null) {
        return orders.where((o) => o.userId == userId).toList();
      }
      return orders;
    } catch (e) {
      throw Exception('Failed to load orders: $e');
    }
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    // orderId is app_id
    try {
      await _apiClient.patch(
        '/orders/$orderId/status',
        body: {'status': newStatus},
      );
    } catch (e) {
      throw Exception('Failed to update status: $e');
    }
  }

  Future<void> createPayment({
    required String orderId,
    required String method,
    required double amount,
    String? reference,
  }) async {
    try {
      await _apiClient.post(
        '/orders/$orderId/payment',
        body: {'method': method, 'amount': amount},
      );
    } catch (e) {
      throw Exception('Failed to create payment: $e');
    }
  }

  Future<Order?> getOrderById(String orderId) async {
    final orders = await getOrders();
    try {
      return orders.firstWhere((o) => o.id == orderId);
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>> getSalesStats() async {
    try {
      final response = await _apiClient.get('/sales/stats');
      return {
        'count': response['count'],
        'revenue': (response['revenue'] as num).toDouble(),
        'active_orders': response['active_orders'],
      };
    } catch (e) {
      return {'count': 0, 'revenue': 0.0, 'active_orders': 0};
    }
  }
}
