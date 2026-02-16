import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/design_system.dart';
import 'bloc/order_bloc.dart';
import 'bloc/order_event.dart';
import 'bloc/order_state.dart';
import '../domain/order_entity.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Fetch orders when screen initializes
    context.read<OrderBloc>().add(FetchOrders());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(AppDimens.s21),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Pesanan Kamu',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () {
                      context.read<OrderBloc>().add(FetchOrders());
                    },
                  ),
                ],
              ),
            ),

            // Tab Bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: AppDimens.s21),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppDimens.r24),
                boxShadow: AppShadows.card,
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: AppColors.textSecondary,
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(text: 'Sedang Diproses'),
                  Tab(text: 'Riwayat'),
                ],
              ),
            ),

            Expanded(
              child: BlocBuilder<OrderBloc, OrderState>(
                builder: (context, state) {
                  if (state is OrderLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is OrderError) {
                    return Center(child: Text('Error: ${state.message}'));
                  } else if (state is OrderLoaded) {
                    final orders = state.orders;

                    final activeOrders = orders.where((o) {
                      final status = o.status.toLowerCase();
                      return status != 'selesai' &&
                          status != 'completed' &&
                          status != 'dibatalkan' &&
                          status != 'cancelled';
                    }).toList();

                    final historyOrders = orders.where((o) {
                      final status = o.status.toLowerCase();
                      return status == 'selesai' ||
                          status == 'completed' ||
                          status == 'dibatalkan' ||
                          status == 'cancelled';
                    }).toList();

                    return TabBarView(
                      controller: _tabController,
                      children: [
                        // Active Orders
                        _buildOrderList(activeOrders),
                        // History
                        _buildOrderList(historyOrders),
                      ],
                    );
                  }

                  // Initial or unknown state - try fetching if not loading
                  if (state is OrderInitial) {
                    context.read<OrderBloc>().add(FetchOrders());
                    return const Center(child: CircularProgressIndicator());
                  }

                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderList(List<Order> orders) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'Belum ada pesanan',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.s21,
        AppDimens.s21,
        AppDimens.s21,
        100,
      ),
      itemCount: orders.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final order = orders[index];
        final currencyFormatter = NumberFormat.currency(
          locale: 'id_ID',
          symbol: 'Rp ',
          decimalDigits: 0,
        );

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: AppShadows.card,
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order #${order.id}', // Customized display
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Antrian #${order.queueNumber}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(
                        order.status,
                      ).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      order.status.toUpperCase(),
                      style: TextStyle(
                        color: _getStatusColor(order.status),
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      order.orderType == 'dine_in' ? 'Dine In' : 'Takeaway',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (order.orderType == 'dine_in' &&
                      order.tableNumber != null) ...[
                    const SizedBox(width: 8),
                    Text(
                      'Meja ${order.tableNumber}',
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                  if (order.readyAt != null) ...[
                    const SizedBox(width: 8),
                    Text(
                      'Siap ${DateFormat('HH:mm').format(order.readyAt!)}',
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ],
              ),
              if (order.paymentStatus != null ||
                  order.paymentMethod != null) ...[
                const SizedBox(height: 6),
                Text(
                  'Pembayaran: ${order.paymentStatus ?? '-'}${order.paymentMethod != null ? ' (${order.paymentMethod})' : ''}',
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
              const Divider(height: 24),
              ...order.items.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Text(
                        '${item.quantity}x',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.product.name),
                            if (item.modifiers.isNotEmpty)
                              Text(
                                item.modifiers.join(', '),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[500],
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                          ],
                        ),
                      ),
                      Text(
                        currencyFormatter.format(
                          item.product.price * item.quantity,
                        ),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${order.items.length} Item',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  Text(
                    currencyFormatter.format(order.totalPrice),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'selesai':
      case 'completed':
        return AppColors.success;
      case 'dibatalkan':
      case 'cancelled':
        return Colors.red;
      case 'sedang diproses':
      case 'processing':
      case 'pending':
        return Colors.orange;
      case 'sedang dimasak':
      case 'cooking':
        return AppColors.warning;
      case 'siap saji':
      case 'ready':
        return Colors.blue;
      case 'paid':
        return Colors.teal;
      default:
        return AppColors.primary;
    }
  }
}
