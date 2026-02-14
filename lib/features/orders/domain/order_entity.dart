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
  final String? paymentStatus;
  final String? paymentMethod;
  final DateTime? paidAt;
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
    this.paymentStatus,
    this.paymentMethod,
    this.paidAt,
    this.items = const [],
  });

  Order copyWith({
    String? id,
    String? userId,
    String? userName,
    double? totalPrice,
    String? status,
    String? promoCode,
    double? discount,
    DateTime? timestamp,
    String? orderType,
    int? queueNumber,
    String? tableId,
    String? tableNumber,
    int? tableCapacity,
    DateTime? readyAt,
    String? paymentStatus,
    String? paymentMethod,
    DateTime? paidAt,
    List<CartItem>? items,
  }) {
    return Order(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      promoCode: promoCode ?? this.promoCode,
      discount: discount ?? this.discount,
      timestamp: timestamp ?? this.timestamp,
      orderType: orderType ?? this.orderType,
      queueNumber: queueNumber ?? this.queueNumber,
      tableId: tableId ?? this.tableId,
      tableNumber: tableNumber ?? this.tableNumber,
      tableCapacity: tableCapacity ?? this.tableCapacity,
      readyAt: readyAt ?? this.readyAt,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paidAt: paidAt ?? this.paidAt,
      items: items ?? this.items,
    );
  }

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
      'paymentStatus': paymentStatus,
      'paymentMethod': paymentMethod,
      'paidAt': paidAt?.millisecondsSinceEpoch,
    };
  }

  factory Order.fromMap(
    Map<String, dynamic> map, {
    List<CartItem> items = const [],
  }) {
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
      paymentStatus: map['paymentStatus'],
      paymentMethod: map['paymentMethod'],
      paidAt: map['paidAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['paidAt'])
          : null,
      items: items,
    );
  }
}
