import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../tables/domain/table_entity.dart';

class OrderSessionState {
  final String orderType; // 'dine_in' or 'takeaway'
  final RestaurantTable? table;
  final int guestCount;
  final String? customerName;

  OrderSessionState({
    this.orderType = 'dine_in',
    this.table,
    this.guestCount = 0,
    this.customerName,
  });

  OrderSessionState copyWith({
    String? orderType,
    RestaurantTable? table,
    int? guestCount,
    String? customerName,
  }) {
    return OrderSessionState(
      orderType: orderType ?? this.orderType,
      table: table ?? this.table,
      guestCount: guestCount ?? this.guestCount,
      customerName: customerName ?? this.customerName,
    );
  }
}

class OrderSessionController extends StateNotifier<OrderSessionState> {
  OrderSessionController() : super(OrderSessionState());

  void setOrderType(String type) {
    state = state.copyWith(orderType: type);
    if (type == 'takeaway') {
      state = state.copyWith(table: null, guestCount: 0);
    }
  }

  void setTable(RestaurantTable table, int guestCount) {
    state = state.copyWith(
      table: table,
      guestCount: guestCount,
      orderType: 'dine_in',
    );
  }

  void setCustomerName(String name) {
    state = state.copyWith(customerName: name);
  }
}

final orderSessionProvider =
    StateNotifierProvider<OrderSessionController, OrderSessionState>(
        (ref) => OrderSessionController());
