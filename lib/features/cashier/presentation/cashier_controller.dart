import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../orders/data/order_repository.dart';
import '../../orders/domain/order_entity.dart';

// State classes
class CashierState {
  final AsyncValue<List<Order>> orders;
  final Order? selectedOrder;
  final double cashTendered;
  final bool isProcessing;
  final String? error;
  final String selectedPaymentMethod;

  CashierState({
    required this.orders,
    this.selectedOrder,
    this.cashTendered = 0,
    this.isProcessing = false,
    this.error,
    this.selectedPaymentMethod = 'cash',
  });

  CashierState copyWith({
    AsyncValue<List<Order>>? orders,
    Order? selectedOrder,
    double? cashTendered,
    bool? isProcessing,
    String? error,
    String? selectedPaymentMethod,
  }) {
    return CashierState(
      orders: orders ?? this.orders,
      selectedOrder: selectedOrder ?? this.selectedOrder,
      cashTendered: cashTendered ?? this.cashTendered,
      isProcessing: isProcessing ?? this.isProcessing,
      error: error, // Nullable update
      selectedPaymentMethod:
          selectedPaymentMethod ?? this.selectedPaymentMethod,
    );
  }

  double get change =>
      selectedOrder != null ? cashTendered - selectedOrder!.totalPrice : 0;

  bool get canProcess =>
      selectedOrder != null &&
      cashTendered >= selectedOrder!.totalPrice &&
      !isProcessing;
}

final cashierControllerProvider =
    StateNotifierProvider<CashierController, CashierState>((ref) {
      return CashierController(ref.read(orderRepositoryProvider));
    });

class CashierController extends StateNotifier<CashierState> {
  final OrderRepository _repository;

  CashierController(this._repository)
    : super(CashierState(orders: const AsyncValue.loading())) {
    loadOrders();
  }

  Future<void> loadOrders() async {
    try {
      state = state.copyWith(orders: const AsyncValue.loading());
      final allOrders = await _repository.getOrders();
      // Filter for orders that are NOT 'Selesai' (Completed) and NOT 'Dibatalkan' (Cancelled)
      // And typically Cashier pays for orders that are 'Siap Saji' or even 'pending'.
      // For now, let's show all active orders that might need payment.
      // Ideally, backend filters by paymentStatus = 'pending'.
      // Assuming 'status' doesn't fully reflect payment, but for this simplified app,
      // let's assume we handle payment for any active order.
      final activeOrders = allOrders
          .where((o) => o.status != 'Selesai' && o.status != 'Dibatalkan')
          .toList();

      // Sort oldest first
      activeOrders.sort((a, b) => a.timestamp.compareTo(b.timestamp));

      state = state.copyWith(orders: AsyncValue.data(activeOrders));
    } catch (e, stack) {
      state = state.copyWith(orders: AsyncValue.error(e, stack));
    }
  }

  void selectOrder(Order order) {
    state = state.copyWith(
      selectedOrder: order,
      cashTendered: 0, // Reset cash on new selection
      error: null,
    );
  }

  void updateCashTendered(double amount) {
    state = state.copyWith(cashTendered: amount, error: null);
  }

  void addCash(double amount) {
    final current = state.cashTendered;
    state = state.copyWith(cashTendered: current + amount, error: null);
  }

  Future<bool> processPayment({
    required String paymentMethod,
    String? reference,
  }) async {
    if (state.selectedOrder == null) return false;

    // For Cash, validate amount
    if (paymentMethod == 'cash' && state.change < 0) {
      state = state.copyWith(error: 'Uang tunai kurang!');
      return false;
    }

    state = state.copyWith(isProcessing: true, error: null);

    try {
      await _repository.createPayment(
        orderId: state.selectedOrder!.id,
        method: paymentMethod,
        amount: state
            .cashTendered, // Sent for record, though mostly relevant for cash
        reference: reference, // Auth code for card/qris
      );

      // Refresh orders
      await loadOrders();

      state = state.copyWith(
        isProcessing: false,
        selectedOrder: null, // Deselect after success
        cashTendered: 0,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isProcessing: false, error: e.toString());
      return false;
    }
  }

  Future<void> cancelOrder(String orderId) async {
    try {
      state = state.copyWith(isProcessing: true, error: null);
      await _repository.cancelOrder(orderId);
      await loadOrders();
      if (state.selectedOrder?.id == orderId) {
        clearSelection();
      }
      state = state.copyWith(isProcessing: false);
    } catch (e) {
      state = state.copyWith(isProcessing: false, error: e.toString());
    }
  }

  Future<bool> createWalkInOrder({
    required List<dynamic> items, // dynamic to match CartItem import
    required String guestName,
    String orderType = 'takeaway',
  }) async {
    state = state.copyWith(isProcessing: true, error: null);

    try {
      final subtotal = items.fold<double>(
        0,
        (sum, item) => sum + (item.product.price * item.quantity),
      );
      final tax =
          subtotal * 0.11; // PPN 11% only, no service charge for walk-in
      final totalPrice = subtotal + tax;

      final order = Order(
        id: DateTime.now().millisecondsSinceEpoch
            .toString(), // Simple ID generation
        userId: 'cashier', // Indicate created by staff
        userName: guestName,
        totalPrice: totalPrice,
        subtotal: subtotal,
        tax: tax,
        status:
            'Sedang Diproses', // Directly to processing as it is confirmed by cashier
        timestamp: DateTime.now(),
        orderType: orderType,
        queueNumber: 0, // Repository will assign
        items: items.cast(), // Ensure type compatibility
      );

      await _repository.createOrder(order);
      await loadOrders();

      state = state.copyWith(isProcessing: false);
      return true;
    } catch (e) {
      state = state.copyWith(isProcessing: false, error: e.toString());
      return false;
    }
  }

  void clearSelection() {
    state = state.copyWith(
      selectedOrder: null,
      cashTendered: 0,
      // change is a getter, so it updates automatically
      error: null,
      selectedPaymentMethod: 'cash',
    );
  }

  void selectPaymentMethod(String method) {
    state = state.copyWith(selectedPaymentMethod: method);
  }
}
