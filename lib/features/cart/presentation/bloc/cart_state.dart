import 'package:equatable/equatable.dart';
import '../../domain/cart_item.dart';

abstract class CartState extends Equatable {
  const CartState();

  @override
  List<Object?> get props => [];
}

class CartInitial extends CartState {}

class CartLoading extends CartState {}

class CartLoaded extends CartState {
  final List<CartItem> items;

  const CartLoaded({required this.items});

  double get subtotal => items.fold(0, (sum, item) => sum + item.totalPrice);
  double get tax => subtotal * 0.11; // 11% PPN
  double get serviceFee => subtotal * 0.05; // 5% Service Charge
  double get total => subtotal + tax + serviceFee;

  CartLoaded copyWith({List<CartItem>? items}) {
    return CartLoaded(items: items ?? this.items);
  }

  @override
  List<Object?> get props => [items];
}

class CartError extends CartState {
  final String message;

  const CartError(this.message);

  @override
  List<Object?> get props => [message];
}
