import '../../cart/domain/cart_item.dart';

class Order {
  final String id;
  final String userId;
  final String userName;
  final double totalPrice;
  final String status;
  final String? promoCode;
  final double discount;
  final DateTime timestamp;
  final String orderType; // 'dine_in' or 'takeaway'
  final String? tableId;
  final String? tableNumber;
  final int? tableCapacity;
  final int queueNumber;
  final DateTime? readyAt;
  final List<CartItem> items; // Make sure this is populated when fetching

  Order({
    required this.id,
    required this.userId,
    required this.userName,
    required this.totalPrice,
    required this.status, // 'pending', 'processing', 'completed', 'cancelled'
    this.promoCode,
    this.discount = 0,
    required this.timestamp,
    required this.orderType,
    required this.queueNumber,
    this.tableId,
    this.tableNumber,
    this.tableCapacity,
    this.readyAt,
    this.items = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'totalPrice': totalPrice,
      'status': status,
      'promoCode': promoCode,
      'discount': discount,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'orderType': orderType,
      'tableId': tableId,
      'tableNumber': tableNumber,
      'tableCapacity': tableCapacity,
      'queueNumber': queueNumber,
      'readyAt': readyAt?.millisecondsSinceEpoch,
    };
  }

  factory Order.fromMap(Map<String, dynamic> map, {List<CartItem> items = const []}) {
    return Order(
      id: map['id'],
      userId: map['userId'],
      userName: map['userName'],
      totalPrice: map['totalPrice'],
      status: map['status'],
      promoCode: map['promoCode'],
      discount: (map['discount'] as num?)?.toDouble() ?? 0,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
      orderType: map['orderType'] ?? 'takeaway',
      tableId: map['tableId'],
      tableNumber: map['tableNumber'],
      tableCapacity: map['tableCapacity'] as int?,
      queueNumber: map['queueNumber'] ?? 0,
      readyAt: map['readyAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['readyAt'])
          : null,
      items: items,
    );
  }
}
