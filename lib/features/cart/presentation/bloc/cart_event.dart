import 'package:equatable/equatable.dart';

import '../../../menu/domain/product_entity.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object?> get props => [];
}

class LoadCart extends CartEvent {}

class AddCartItem extends CartEvent {
  final Product product;
  final int quantity;
  final String? note;
  final List<String> modifiers;

  const AddCartItem({
    required this.product,
    this.quantity = 1,
    this.note,
    this.modifiers = const [],
  });

  @override
  List<Object?> get props => [product, quantity, note, modifiers];
}

class RemoveCartItem extends CartEvent {
  final String cartItemId;

  const RemoveCartItem(this.cartItemId);

  @override
  List<Object?> get props => [cartItemId];
}

class UpdateCartItemQuantity extends CartEvent {
  final String cartItemId;
  final int quantity;

  const UpdateCartItemQuantity(this.cartItemId, this.quantity);

  @override
  List<Object?> get props => [cartItemId, quantity];
}

class ClearCart extends CartEvent {}
