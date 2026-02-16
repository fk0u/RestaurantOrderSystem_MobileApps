import 'package:equatable/equatable.dart';
import '../../domain/order_entity.dart';

abstract class OrderEvent extends Equatable {
  const OrderEvent();

  @override
  List<Object?> get props => [];
}

class FetchOrders extends OrderEvent {
  final String? userId;

  const FetchOrders({this.userId});
}

class PlaceOrder extends OrderEvent {
  final Order order;
  final String paymentMethod;

  const PlaceOrder({required this.order, required this.paymentMethod});

  @override
  List<Object?> get props => [order, paymentMethod];
}
