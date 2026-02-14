import 'package:flutter_riverpod/flutter_riverpod.dart';

enum OrderType { dineIn, takeaway, delivery }

extension OrderTypeExtension on OrderType {
  String get label {
    switch (this) {
      case OrderType.dineIn:
        return 'Makan di Tempat';
      case OrderType.takeaway:
        return 'Bawa Pulang';
      case OrderType.delivery:
        return 'Delivery';
    }
  }

  String get value {
    switch (this) {
      case OrderType.dineIn:
        return 'dine_in';
      case OrderType.takeaway:
        return 'takeaway';
      case OrderType.delivery:
        return 'delivery';
    }
  }
}

final orderTypeProvider = StateProvider<OrderType>((ref) => OrderType.dineIn);
