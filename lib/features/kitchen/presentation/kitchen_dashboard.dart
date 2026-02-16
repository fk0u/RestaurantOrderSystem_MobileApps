import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/design_system.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../orders/domain/order_entity.dart';
import 'kitchen_controller.dart';

class KitchenDashboard extends ConsumerWidget {
  const KitchenDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(kitchenControllerProvider);

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text(
            'Sistem Dapur Displai',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Semua'),
              Tab(text: 'Proses'),
              Tab(text: 'Masak'),
              Tab(text: 'Siap'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => ref.refresh(kitchenControllerProvider),
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () =>
                  ref.read(authControllerProvider.notifier).logout(),
            ),
          ],
        ),
        body: state.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
          data: (orders) {
            if (orders.isEmpty) {
              return const Center(child: Text('Tidak ada pesanan aktif'));
            }

            final sortedOrders = [...orders]
              ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

            List<Order> filtered(String status) {
              if (status == 'all') return sortedOrders;
              return sortedOrders.where((o) => o.status == status).toList();
            }

            return TabBarView(
              children: [
                _buildOrderList(ref, filtered('all')),
                _buildOrderList(ref, filtered('Sedang Diproses')),
                _buildOrderList(ref, filtered('Sedang Dimasak')),
                _buildOrderList(ref, filtered('Siap Saji')),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildOrderList(WidgetRef ref, List<Order> orders) {
    if (orders.isEmpty) {
      return const Center(child: Text('Tidak ada pesanan'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final order = orders[index];
        final duration = DateTime.now().difference(order.timestamp);
        final minutes = duration.inMinutes;
        final durationLabel = minutes < 60
            ? '${minutes}m'
            : '${duration.inHours}j ${minutes % 60}m';

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Text(
                        order.id,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "${order.timestamp.hour}:${order.timestamp.minute.toString().padLeft(2, '0')}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          'Durasi $durationLabel',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  order.userName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
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
                    Text(
                      'Antrian #${order.queueNumber}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    if (order.orderType == 'dine_in' &&
                        order.tableNumber != null)
                      Text(
                        'Meja ${order.tableNumber}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    if (order.orderType == 'dine_in' &&
                        order.tableCapacity != null)
                      Text(
                        'Kapasitas ${order.tableCapacity} orang',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(),
                ),

                ...order.items.map((item) {
                  String displayText =
                      "${item.product.name} x ${item.quantity}";
                  if (item.modifiers.isNotEmpty) {
                    displayText += " (${item.modifiers.join(', ')})";
                  }
                  if (item.note != null && item.note!.isNotEmpty) {
                    displayText += "\nCatatan: ${item.note}";
                  }
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.circle,
                          size: 8,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            displayText,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  );
                }),

                const SizedBox(height: 24),

                Row(
                  children: [
                    _buildStatusButton(
                      ref,
                      order.id,
                      'Sedang Diproses',
                      order.status == 'Sedang Diproses',
                    ),
                    _buildLine(true),
                    _buildStatusButton(
                      ref,
                      order.id,
                      'Sedang Dimasak',
                      order.status == 'Sedang Dimasak',
                    ),
                    _buildLine(true),
                    _buildStatusButton(
                      ref,
                      order.id,
                      'Siap Saji',
                      order.status == 'Siap Saji',
                    ),
                    _buildLine(true),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => ref
                            .read(kitchenControllerProvider.notifier)
                            .updateStatus(order.id, 'Selesai'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Selesai'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusButton(
    WidgetRef ref,
    String orderId,
    String status,
    bool isActive,
  ) {
    return InkWell(
      onTap: () => ref
          .read(kitchenControllerProvider.notifier)
          .updateStatus(orderId, status),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive ? AppColors.primary : Colors.grey.shade300,
          ),
        ),
        child: Text(
          status,
          style: TextStyle(
            fontSize: 11,
            color: isActive ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildLine(bool isActive) {
    return Expanded(
      child: Container(
        height: 2,
        color: isActive ? AppColors.primary : Colors.grey.shade300,
      ),
    );
  }
}
