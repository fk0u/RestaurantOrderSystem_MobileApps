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

final cartServiceFeeProvider = Provider<double>((ref) {
  final subtotal = ref.watch(cartSubtotalProvider);
  return subtotal * 0.05; // Service Charge 5%
});

final cartTotalProvider = Provider<double>((ref) {
  final subtotal = ref.watch(cartSubtotalProvider);
  final tax = ref.watch(cartTaxProvider);
  final service = ref.watch(cartServiceFeeProvider);
  return subtotal + tax + service;
});

class CartController extends StateNotifier<List<CartItem>> {
  CartController() : super([]);

  void addItem(Product product, {int quantity = 1, String? note, List<String> modifiers = const []}) {
    // Check if exists with same product, note, and modifiers
    final index = state.indexWhere((item) {
      final isSameProduct = item.product.id == product.id;
      final isSameNote = item.note == note;
      // Simple list equality check (assuming order implies identity, which is acceptable for this level)
      final isSameModifiers = item.modifiers.length == modifiers.length && 
          item.modifiers.every((m) => modifiers.contains(m));
      
      return isSameProduct && isSameNote && isSameModifiers;
    });

    if (index >= 0) {
      // Increment existing item
      final oldItem = state[index];
      final newQuantity = oldItem.quantity + quantity;
      state = [
        ...state.sublist(0, index),
        oldItem.copyWith(quantity: newQuantity),
        ...state.sublist(index + 1),
      ];
    } else {
      // Add new distinct item
      state = [...state, CartItem(product: product, quantity: quantity, note: note, modifiers: modifiers)];
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
