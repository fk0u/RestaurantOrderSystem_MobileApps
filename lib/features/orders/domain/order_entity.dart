import '../../cart/domain/cart_item.dart';

class Order {
  final String id;
  final String userId;
  final String userName;
  final double totalPrice;
  final String status;
  final DateTime timestamp;
  final List<CartItem> items; // Make sure this is populated when fetching

  Order({
    required this.id,
    required this.userId,
    required this.userName,
    required this.totalPrice,
    required this.status, // 'pending', 'processing', 'completed', 'cancelled'
    required this.timestamp,
    this.items = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'totalPrice': totalPrice,
      'status': status,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  factory Order.fromMap(Map<String, dynamic> map, {List<CartItem> items = const []}) {
    return Order(
      id: map['id'],
      userId: map['userId'],
      userName: map['userName'],
      totalPrice: map['totalPrice'],
      status: map['status'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
      items: items,
    );
  }
}
