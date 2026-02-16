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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Manajemen Pesanan', style: AppTypography.heading3),
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
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
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.inbox_outlined,
                    size: 64,
                    color: AppColors.textHint,
                  ),
                  const SizedBox(height: AppDimens.s16),
                  Text('Belum ada pesanan', style: AppTypography.bodyMedium),
                ],
              ),
            );
          }

          // Sort by date ASCENDING (Oldest First)
          final sortedOrders = List<Order>.from(orders)
            ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

          return ListView.separated(
            padding: const EdgeInsets.all(AppDimens.s16),
            itemCount: sortedOrders.length,
            separatorBuilder: (context, index) =>
                const SizedBox(height: AppDimens.s16),
            itemBuilder: (context, index) {
              final order = sortedOrders[index];
              return _DetailedOrderCard(order: order);
            },
          );
        },
      ),
    );
  }
}

class _DetailedOrderCard extends ConsumerWidget {
  final Order order;

  const _DetailedOrderCard({required this.order});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    final statusColor = _getStatusColor(order.status);
    final timeFormatter = DateFormat('dd MMM yyyy, HH:mm', 'id_ID');

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.r16),
        boxShadow: AppShadows.card,
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Strip
          Container(
            height: 6,
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppDimens.r16),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppDimens.s16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header (Order ID, Table, Status)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order #${order.queueNumber}',
                          style: AppTypography.heading3.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (order.tableId != null)
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(AppDimens.r4),
                            ),
                            child: Text(
                              'Meja ${order.tableId}',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    _StatusBadge(status: order.status),
                  ],
                ),
                const SizedBox(height: AppDimens.s12),
                const Divider(height: 1),
                const SizedBox(height: AppDimens.s12),

                // Order Info (Time, Name, Type)
                Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      timeFormatter.format(order.timestamp),
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.person,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      order.userName,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppDimens.r100),
                      ),
                      child: Text(
                        order.orderType,
                        style: AppTypography.bodySmall.copyWith(fontSize: 10),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppDimens.s12),
                const Divider(height: 1),
                const SizedBox(height: AppDimens.s12),

                // Order Items
                Text(
                  'Item Pesanan:',
                  style: AppTypography.bodySmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textHint,
                  ),
                ),
                const SizedBox(height: 8),
                ...order.items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Text(
                            '${item.quantity}x',
                            style: AppTypography.bodySmall.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.product.name,
                                style: AppTypography.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              if (item.modifiers.isNotEmpty)
                                Text(
                                  item.modifiers.join(', '),
                                  style: AppTypography.bodySmall.copyWith(
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              if (item.note != null && item.note!.isNotEmpty)
                                Container(
                                  margin: const EdgeInsets.only(top: 4),
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.yellow.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.note,
                                        size: 10,
                                        color: Colors.orange,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        item.note!,
                                        style: AppTypography.bodySmall.copyWith(
                                          fontSize: 10,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Text(
                          currencyFormatter.format(
                            item.product.price * item.quantity,
                          ),
                          style: AppTypography.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: AppDimens.s12),
                const Divider(height: 1, thickness: 1),
                const SizedBox(height: AppDimens.s12),

                // Footer (Total, Actions)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Total', style: AppTypography.bodySmall),
                        Text(
                          currencyFormatter.format(order.totalPrice),
                          style: AppTypography.heading3.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: AppDimens.s16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _StatusChip(
                        label: 'Proses',
                        targetStatus: 'Sedang Diproses',
                        currentStatus: order.status,
                        color: Colors.blue,
                        onTap: () => _updateStatus(
                          context,
                          ref,
                          order.id,
                          'Sedang Diproses',
                        ),
                      ),
                      const SizedBox(width: 8),
                      _StatusChip(
                        label: 'Masak',
                        targetStatus: 'Sedang Dimasak',
                        currentStatus: order.status,
                        color: Colors.orange,
                        onTap: () => _updateStatus(
                          context,
                          ref,
                          order.id,
                          'Sedang Dimasak',
                        ),
                      ),
                      const SizedBox(width: 8),
                      _StatusChip(
                        label: 'Siap',
                        targetStatus: 'Siap Saji',
                        currentStatus: order.status,
                        color: Colors.green,
                        onTap: () =>
                            _updateStatus(context, ref, order.id, 'Siap Saji'),
                      ),
                      const SizedBox(width: 8),
                      _StatusChip(
                        label: 'Selesai',
                        targetStatus: 'Selesai',
                        currentStatus: order.status,
                        color: AppColors.primary,
                        onTap: () =>
                            _updateStatus(context, ref, order.id, 'Selesai'),
                      ),
                      const SizedBox(width: 8),
                      _StatusChip(
                        label: 'Batal',
                        targetStatus: 'Dibatalkan',
                        currentStatus: order.status,
                        color: Colors.red,
                        onTap: () =>
                            _updateStatus(context, ref, order.id, 'Dibatalkan'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _updateStatus(
    BuildContext context,
    WidgetRef ref,
    String orderId,
    String status,
  ) {
    ref
        .read(adminOrdersControllerProvider.notifier)
        .updateStatus(orderId, status);
    Toaster.showSuccess(context, 'Status updated: $status');
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

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimens.r100),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        status,
        style: AppTypography.bodySmall.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
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

class _StatusChip extends StatelessWidget {
  final String label;
  final String targetStatus;
  final String currentStatus;
  final Color color;
  final VoidCallback onTap;

  const _StatusChip({
    required this.label,
    required this.targetStatus,
    required this.currentStatus,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = targetStatus == currentStatus;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimens.r8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(AppDimens.r8),
          border: Border.all(
            color: isSelected ? color : AppColors.border,
            width: isSelected ? 0 : 1,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
