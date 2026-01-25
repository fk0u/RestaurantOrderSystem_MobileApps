import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/design_system.dart';
import 'orders/presentation/orders_controller.dart';
import 'orders/domain/order_entity.dart';

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ordersState = ref.watch(ordersControllerProvider);

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
                  Text('Pesanan Kamu', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.refresh), 
                    onPressed: () => ref.refresh(ordersControllerProvider),
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
              child: ordersState.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('Error: $err')),
                data: (orders) {
                  final activeOrders = orders.where((o) => o.status != 'Selesai' && o.status != 'Dibatalkan').toList();
                  final historyOrders = orders.where((o) => o.status == 'Selesai' || o.status == 'Dibatalkan').toList();

                  return TabBarView(
                    controller: _tabController,
                    children: [
                       // Active Orders
                       _buildOrderList(activeOrders),
                       // History
                       _buildOrderList(historyOrders),
                    ],
                  );
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
            Text('Belum ada pesanan', style: TextStyle(color: Colors.grey[500])),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(AppDimens.s21, AppDimens.s21, AppDimens.s21, 100),
      itemCount: orders.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final order = orders[index];
        final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

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
                        Text(order.id, style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text(
                          'Antrian #${order.queueNumber}',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor(order.status).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      order.status,
                      style: TextStyle(color: _getStatusColor(order.status), fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      order.orderType == 'dine_in' ? 'Dine In' : 'Takeaway',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                  if (order.orderType == 'dine_in' && order.tableNumber != null) ...[
                    const SizedBox(width: 8),
                    Text('Meja ${order.tableNumber}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                  if (order.readyAt != null) ...[
                    const SizedBox(width: 8),
                    Text('Siap ${DateFormat('HH:mm').format(order.readyAt!)}',
                        style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ],
              ),
              if (order.paymentStatus != null || order.paymentMethod != null) ...[
                const SizedBox(height: 6),
                Text(
                  'Pembayaran: ${order.paymentStatus ?? '-'}${order.paymentMethod != null ? ' (${order.paymentMethod})' : ''}',
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
              const Divider(height: 24),
              ...order.items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Text('${item.quantity}x', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.product.name),
                          if (item.modifiers.isNotEmpty)
                             Text(item.modifiers.join(', '), style: TextStyle(fontSize: 10, color: Colors.grey[500], fontStyle: FontStyle.italic)),
                        ]
                      )
                    ),
                  ],
                ),
              )),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${order.items.length} Item', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  Text(currencyFormatter.format(order.totalPrice), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
      case 'selesai': return AppColors.success;
      case 'dibatalkan': return Colors.red;
      case 'sedang diproses': return Colors.orange;
      case 'sedang dimasak': return AppColors.warning;
      default: return AppColors.primary;
    }
  }
}
