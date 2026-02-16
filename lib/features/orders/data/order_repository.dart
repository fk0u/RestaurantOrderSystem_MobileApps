import 'dart:convert';
import 'package:uuid/uuid.dart';
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
          // Add tax and subtotal
          'subtotal': order.subtotal,
          'tax': order.tax,
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
          List<String> modifiers = [];
          if (itemMap['modifiers'] != null) {
            if (itemMap['modifiers'] is String) {
              try {
                final decoded = jsonDecode(itemMap['modifiers']);
                if (decoded is List) modifiers = List<String>.from(decoded);
              } catch (e) {
                // Ignore parsing errors for modifiers
              }
            } else if (itemMap['modifiers'] is List) {
              modifiers = List<String>.from(itemMap['modifiers']);
            }
          }

          return CartItem(
            id: const Uuid().v4(), // Generated for display/reorder purposes
            product: Product(
              id: itemMap['productId'].toString(),
              name: itemMap['productName'] ?? itemMap['name'] ?? '',
              price: _parseDouble(itemMap['price']),
              imageUrl: '',
              category: '',
              description: '',
            ),
            quantity: _parseInt(itemMap['quantity']),
            note: itemMap['note'] as String?,
            modifiers: modifiers,
          );
        }).toList();

        return Order(
          id: map['app_id'] as String? ?? map['id'].toString(),
          userId: (map['userId'] ?? '').toString(),
          userName: map['guestName'] ?? map['userName'] ?? 'Guest',
          totalPrice: _parseDouble(map['totalPrice']),
          status: map['status'] ?? 'pending',
          subtotal: _parseDouble(map['subtotal']),
          tax: _parseDouble(map['tax']),
          orderType: map['orderType'] ?? 'dine_in',
          queueNumber: _parseInt(map['queueNumber']),
          tableId: (map['tableId'] != null) ? map['tableId'].toString() : null,
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

  Future<void> cancelOrder(String orderId) async {
    return updateOrderStatus(orderId, 'Dibatalkan');
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
        body: {'method': method, 'amount': amount, 'reference': reference},
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
        'revenue': _parseDouble(response['revenue']),
        'active_orders': response['active_orders'],
      };
    } catch (e) {
      return {'count': 0, 'revenue': 0.0, 'active_orders': 0};
    }
  }

  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}
