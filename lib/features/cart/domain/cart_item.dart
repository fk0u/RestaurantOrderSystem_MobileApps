import '../../menu/domain/product_entity.dart';

class CartItem {
  final Product product;
  final int quantity;
  final String? note;

  CartItem({
    required this.product,
    this.quantity = 1,
    this.note,
  });

  double get totalPrice => product.price * quantity;

  CartItem copyWith({
    Product? product,
    int? quantity,
    String? note,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      note: note ?? this.note,
    );
  }
}
