import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../domain/cart_item.dart';
import 'cart_event.dart';
import 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final _uuid = const Uuid();

  CartBloc() : super(const CartLoaded(items: [])) {
    on<LoadCart>(_onLoadCart);
    on<AddCartItem>(_onAddCartItem);
    on<RemoveCartItem>(_onRemoveCartItem);
    on<UpdateCartItemQuantity>(_onUpdateCartItemQuantity);
    on<ClearCart>(_onClearCart);
  }

  void _onLoadCart(LoadCart event, Emitter<CartState> emit) {
    // Usually fetch from local storage or API
    // For now, we start with whatever is in the initial state memory or empty
    if (state is! CartLoaded) {
      emit(const CartLoaded(items: []));
    }
  }

  void _onAddCartItem(AddCartItem event, Emitter<CartState> emit) {
    final currentState = state;
    if (currentState is CartLoaded) {
      final items = List<CartItem>.from(currentState.items);

      final index = items.indexWhere((item) {
        final isSameProduct = item.product.id == event.product.id;
        final isSameNote = item.note == event.note;
        final isSameModifiers =
            item.modifiers.length == event.modifiers.length &&
            item.modifiers.every((m) => event.modifiers.contains(m));

        return isSameProduct && isSameNote && isSameModifiers;
      });

      if (index >= 0) {
        // Increment existing item
        final oldItem = items[index];
        items[index] = oldItem.copyWith(
          quantity: oldItem.quantity + event.quantity,
        );
      } else {
        // Add new item
        items.add(
          CartItem(
            id: _uuid.v4(),
            product: event.product,
            quantity: event.quantity,
            note: event.note,
            modifiers: event.modifiers,
          ),
        );
      }

      emit(CartLoaded(items: items));
    } else {
      // If state was not loaded, initialize with the item
      emit(
        CartLoaded(
          items: [
            CartItem(
              id: _uuid.v4(),
              product: event.product,
              quantity: event.quantity,
              note: event.note,
              modifiers: event.modifiers,
            ),
          ],
        ),
      );
    }
  }

  void _onRemoveCartItem(RemoveCartItem event, Emitter<CartState> emit) {
    if (state is CartLoaded) {
      final items = (state as CartLoaded).items
          .where((item) => item.id != event.cartItemId)
          .toList();
      emit(CartLoaded(items: items));
    }
  }

  void _onUpdateCartItemQuantity(
    UpdateCartItemQuantity event,
    Emitter<CartState> emit,
  ) {
    if (state is CartLoaded) {
      final items = List<CartItem>.from((state as CartLoaded).items);
      final index = items.indexWhere((item) => item.id == event.cartItemId);

      if (index >= 0) {
        if (event.quantity <= 0) {
          items.removeAt(index);
        } else {
          items[index] = items[index].copyWith(quantity: event.quantity);
        }
        emit(CartLoaded(items: items));
      }
    }
  }

  void _onClearCart(ClearCart event, Emitter<CartState> emit) {
    emit(const CartLoaded(items: []));
  }
}
