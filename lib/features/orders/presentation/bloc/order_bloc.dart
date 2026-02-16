import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/order_repository.dart';
import '../../../tables/data/table_repository.dart';
import 'order_event.dart';
import 'order_state.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final OrderRepository _orderRepository;
  final TableRepository _tableRepository;

  Timer? _timer;
  String? _lastUserId;

  OrderBloc({
    required OrderRepository orderRepository,
    required TableRepository tableRepository,
  }) : _orderRepository = orderRepository,
       _tableRepository = tableRepository,
       super(OrderInitial()) {
    on<FetchOrders>(_onFetchOrders);
    on<PlaceOrder>(_onPlaceOrder);
    _startPolling();
  }

  void _startPolling() {
    _timer = Timer.periodic(const Duration(seconds: 10), (_) {
      add(FetchOrders(userId: _lastUserId));
    });
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }

  Future<void> _onFetchOrders(
    FetchOrders event,
    Emitter<OrderState> emit,
  ) async {
    if (event.userId != null) _lastUserId = event.userId;

    // Only show loading spinner on the very first fetch, not on poll refreshes
    final isFirstLoad = state is OrderInitial || state is OrderError;
    if (isFirstLoad) {
      emit(OrderLoading());
    }

    try {
      final orders = await _orderRepository.getOrders(userId: event.userId);
      emit(OrderLoaded(orders));
    } catch (e) {
      // On poll failure, keep existing data if available
      if (state is OrderLoaded) {
        // Silently ignore to avoid disrupting the UI
        return;
      }
      emit(OrderError(e.toString()));
    }
  }

  Future<void> _onPlaceOrder(PlaceOrder event, Emitter<OrderState> emit) async {
    emit(OrderLoading());
    try {
      // Create Order
      final createdOrder = await _orderRepository.createOrder(event.order);

      // Update Table Status if Dine In
      if (event.order.orderType == 'dine_in' && event.order.tableId != null) {
        await _tableRepository.updateTableStatus(
          event.order.tableId!,
          'occupied',
        );
      }

      // Create Payment
      await _orderRepository.createPayment(
        orderId: createdOrder.id,
        method: event.paymentMethod,
        amount: createdOrder.totalPrice,
      );

      emit(OrderOperationSuccess(createdOrder, 'Pesanan berhasil dibuat!'));
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }
}
