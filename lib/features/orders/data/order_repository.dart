import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/database_helper.dart';
import '../../cart/domain/cart_item.dart';
import '../../menu/domain/product_entity.dart';
import '../domain/order_entity.dart';

final orderRepositoryProvider = Provider((ref) => OrderRepository());

class OrderRepository {
  Future<void> createOrder(Order order) async {
    final db = await DatabaseHelper.instance.database;
    
    await db.transaction((txn) async {
      // 1. Verify and Deduct Stock
      for (var item in order.items) {
        // Get current stock
        final List<Map<String, dynamic>> result = await txn.query(
          'products',
          columns: ['stock'],
          where: 'id = ?',
          whereArgs: [item.product.id],
        );

        if (result.isNotEmpty) {
          final currentStock = result.first['stock'] as int;
          if (currentStock < item.quantity) {
             throw Exception('Stok tidak cukup untuk ${item.product.name}. Sisa: $currentStock');
          }
          
          // Deduct
          await txn.update(
            'products',
            {'stock': currentStock - item.quantity},
            where: 'id = ?',
            whereArgs: [item.product.id],
          );
        }
      }

      // 2. Insert Order
      await txn.insert('orders', order.toMap());

      // 3. Insert Items
      for (var item in order.items) {
        final modifiersJson = item.modifiers.isNotEmpty ? jsonEncode(item.modifiers) : null;
        await txn.insert('order_items', {
          'orderId': order.id,
          'productId': item.product.id,
          'productName': item.product.name,
          'productPrice': item.product.price,
          'quantity': item.quantity,
          'note': item.note,
          'modifiers': modifiersJson,
        });
      }
    });

    // Notify listeners or refresh logic if needed (handled by providers)
  }

  Future<List<Order>> getOrders() async {
    final db = await DatabaseHelper.instance.database;
    
    // Get Orders
    final orderMaps = await db.query('orders', orderBy: 'timestamp DESC');
    
    List<Order> orders = [];

    for (var map in orderMaps) {
      final orderId = map['id'] as String;
      
      // Get Items for this order
      final itemMaps = await db.query(
        'order_items',
        where: 'orderId = ?',
        whereArgs: [orderId],
      );

      final items = itemMaps.map((itemMap) {
        // Reconstruct Product (Simplified, just for display)
        // In a real app we might fetch the full product again, but for history, preserving the snapshot name/price is better.
        final product = Product(
          id: itemMap['productId'] as String,
          name: itemMap['productName'] as String,
          description: '', // Not needed for history list
          price: itemMap['productPrice'] as double,
          imageUrl: '', // We might need to fetch this if we want to show image
          category: '',
        );

        final modifiersString = itemMap['modifiers'] as String?;
        final List<String> modifiers = modifiersString != null 
            ? List<String>.from(jsonDecode(modifiersString)) 
            : [];

        return CartItem(
          product: product,
          quantity: itemMap['quantity'] as int,
          note: itemMap['note'] as String?,
          modifiers: modifiers,
        );
      }).toList();

      orders.add(Order.fromMap(map, items: items));
    }

    return orders;
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    final db = await DatabaseHelper.instance.database;
    await db.update(
      'orders',
      {'status': newStatus},
      where: 'id = ?',
      whereArgs: [orderId],
    );
  }

  Future<Map<String, dynamic>> getSalesStats() async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.rawQuery('''
      SELECT 
        COUNT(*) as count, 
        SUM(totalPrice) as revenue 
      FROM orders 
      WHERE status = 'Selesai'
    ''');

    if (result.isNotEmpty) {
      return {
        'count': result.first['count'] ?? 0,
        'revenue': result.first['revenue'] ?? 0.0,
      };
    }
    return {'count': 0, 'revenue': 0.0};
  }
}
