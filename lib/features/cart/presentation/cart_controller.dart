import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/cart_item.dart';
import '../../menu/domain/product_entity.dart';

final cartControllerProvider = StateNotifierProvider<CartController, List<CartItem>>((ref) {
  return CartController();
});

// Providers for calculations
final cartSubtotalProvider = Provider<double>((ref) {
  final cart = ref.watch(cartControllerProvider);
  return cart.fold(0, (sum, item) => sum + item.totalPrice);
});

final cartTaxProvider = Provider<double>((ref) {
  final subtotal = ref.watch(cartSubtotalProvider);
  return subtotal * 0.11; // PPN 11%
});

final cartTotalProvider = Provider<double>((ref) {
  final subtotal = ref.watch(cartSubtotalProvider);
  final tax = ref.watch(cartTaxProvider);
  return subtotal + tax;
});

class CartController extends StateNotifier<List<CartItem>> {
  CartController() : super([]);

  void addItem(Product product) {
    // Check if exists
    final index = state.indexWhere((item) => item.product.id == product.id);
    if (index >= 0) {
      // Increment
      final oldItem = state[index];
      final newQuantity = oldItem.quantity + 1;
      state = [
        ...state.sublist(0, index),
        oldItem.copyWith(quantity: newQuantity),
        ...state.sublist(index + 1),
      ];
    } else {
      // Add new
      state = [...state, CartItem(product: product)];
    }
  }

  void updateQuantity(String productId, int newQuantity) {
    final index = state.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      if (newQuantity <= 0) {
        // Remove
        state = state.where((item) => item.product.id != productId).toList();
      } else {
        // Update
        final oldItem = state[index];
        state = [
          ...state.sublist(0, index),
          oldItem.copyWith(quantity: newQuantity),
          ...state.sublist(index + 1),
        ];
      }
    }
  }

  void removeItem(String productId) {
    state = state.where((item) => item.product.id != productId).toList();
  }

  void clearCart() {
    state = [];
  }
}
