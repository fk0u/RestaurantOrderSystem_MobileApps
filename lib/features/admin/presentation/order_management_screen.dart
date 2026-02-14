import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:restaurant_order_system/core/input/toaster.dart';
import 'package:restaurant_order_system/core/theme/design_system.dart';
import 'package:restaurant_order_system/features/orders/domain/order_entity.dart';
import 'controllers/admin_orders_controller.dart';

class OrderManagementScreen extends ConsumerWidget {
  const OrderManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersState = ref.watch(adminOrdersControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Pesanan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(adminOrdersControllerProvider),
          ),
        ],
      ),
      body: ordersState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (orders) {
          if (orders.isEmpty) {
            return const Center(child: Text('Belum ada pesanan'));
          }

          // Sort by date desc
          final sortedOrders = List<Order>.from(orders)
            ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: sortedOrders.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final order = sortedOrders[index];
              return _AdminOrderCard(order: order);
            },
          );
        },
      ),
    );
  }
}

class _AdminOrderCard extends ConsumerWidget {
  final Order order;

  const _AdminOrderCard({required this.order});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order #${order.queueNumber}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    DateFormat('dd MMM HH:mm').format(order.timestamp),
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(order.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                order.status,
                style: TextStyle(
                  color: _getStatusColor(order.status),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        subtitle: Text(
          '${order.userName} - ${currencyFormatter.format(order.totalPrice)}',
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                if (order.tableId != null) Text('Meja: ${order.tableId}'),
                Text('Tipe: ${order.orderType}'),
                const SizedBox(height: 8),
                const Text(
                  'Items:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                ...order.items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        Text('${item.quantity}x '),
                        Expanded(child: Text(item.product.name)),
                        Text(
                          currencyFormatter.format(
                            item.product.price * item.quantity,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Update Status:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    _StatusButton(
                      orderId: order.id,
                      status: 'Sedang Diproses',
                      currentStatus: order.status,
                      color: Colors.blue,
                    ),
                    _StatusButton(
                      orderId: order.id,
                      status: 'Sedang Dimasak',
                      currentStatus: order.status,
                      color: Colors.orange,
                    ),
                    _StatusButton(
                      orderId: order.id,
                      status: 'Siap Saji',
                      currentStatus: order.status,
                      color: Colors.green,
                    ),
                    _StatusButton(
                      orderId: order.id,
                      status: 'Selesai',
                      currentStatus: order.status,
                      color: AppColors.primary,
                    ),
                    _StatusButton(
                      orderId: order.id,
                      status: 'Dibatalkan',
                      currentStatus: order.status,
                      color: Colors.red,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Sedang Diproses':
        return Colors.blue;
      case 'Sedang Dimasak':
        return Colors.orange;
      case 'Siap Saji':
        return Colors.green;
      case 'Selesai':
        return AppColors.success;
      case 'Dibatalkan':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

class _StatusButton extends ConsumerWidget {
  final String orderId;
  final String status;
  final String currentStatus;
  final Color color;

  const _StatusButton({
    required this.orderId,
    required this.status,
    required this.currentStatus,
    required this.color,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSelected = status == currentStatus;
    return ActionChip(
      label: Text(status),
      backgroundColor: isSelected ? color.withOpacity(0.2) : Colors.grey[100],
      labelStyle: TextStyle(
        color: isSelected ? color : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      onPressed: () {
        ref
            .read(adminOrdersControllerProvider.notifier)
            .updateStatus(orderId, status);
        Toaster.showSuccess(context, 'Status updated to $status');
      },
    );
  }
}
