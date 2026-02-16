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
  final double subtotal;
  final double tax;
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
    this.subtotal = 0,
    this.tax = 0,
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
    double? subtotal,
    double? tax,
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
      subtotal: subtotal ?? this.subtotal,
      tax: tax ?? this.tax,
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
      'subtotal': subtotal,
      'tax': tax,
    };
  }

  factory Order.fromMap(
    Map<String, dynamic> map, {
    List<CartItem> items = const [],
  }) {
    return Order(
      id: map['id']?.toString() ?? '',
      userId: map['userId']?.toString() ?? '',
      userName: map['userName']?.toString() ?? '',
      totalPrice: (map['totalPrice'] is String)
          ? double.tryParse(map['totalPrice']) ?? 0.0
          : (map['totalPrice'] as num?)?.toDouble() ?? 0.0,
      status: map['status']?.toString() ?? 'pending',
      promoCode: map['promoCode']?.toString(),
      discount: (map['discount'] is String)
          ? double.tryParse(map['discount']) ?? 0.0
          : (map['discount'] as num?)?.toDouble() ?? 0.0,
      timestamp: map['timestamp'] is int
          ? DateTime.fromMillisecondsSinceEpoch(map['timestamp'])
          : DateTime.tryParse(map['timestamp']?.toString() ?? '') ??
                DateTime.now(),
      orderType: map['orderType']?.toString() ?? 'takeaway',
      tableId: map['tableId']?.toString(),
      tableNumber: map['tableNumber']?.toString(),
      tableCapacity: int.tryParse(map['tableCapacity']?.toString() ?? ''),
      queueNumber: int.tryParse(map['queueNumber']?.toString() ?? '') ?? 0,
      readyAt: map['readyAt'] != null
          ? (map['readyAt'] is int
                ? DateTime.fromMillisecondsSinceEpoch(map['readyAt'])
                : DateTime.tryParse(map['readyAt'].toString()))
          : null,
      paymentStatus: map['paymentStatus']?.toString(),
      paymentMethod: map['paymentMethod']?.toString(),
      paidAt: map['paidAt'] != null
          ? (map['paidAt'] is int
                ? DateTime.fromMillisecondsSinceEpoch(map['paidAt'])
                : DateTime.tryParse(map['paidAt'].toString()))
          : null,
      subtotal: (map['subtotal'] is String)
          ? double.tryParse(map['subtotal']) ?? 0.0
          : (map['subtotal'] as num?)?.toDouble() ?? 0.0,
      tax: (map['tax'] is String)
          ? double.tryParse(map['tax']) ?? 0.0
          : (map['tax'] as num?)?.toDouble() ?? 0.0,
      items: items,
    );
  }
}
