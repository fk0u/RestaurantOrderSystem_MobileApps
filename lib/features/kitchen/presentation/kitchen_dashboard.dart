import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../auth/presentation/auth_controller.dart';
import 'kitchen_controller.dart';

class KitchenDashboard extends ConsumerWidget {
  const KitchenDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(kitchenControllerProvider);
    
    // Sort orders: pending first, then cooking
    final sortedOrders = [...orders];
    sortedOrders.sort((a, b) {
      final statusRank = {'pending': 0, 'cooking': 1, 'ready': 2, 'completed': 3};
      return (statusRank[a.status] ?? 4).compareTo(statusRank[b.status] ?? 4);
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Sistem Dapur Displai', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authControllerProvider.notifier).logout(),
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: sortedOrders.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final order = sortedOrders[index];
          if (order.status == 'completed') return const SizedBox.shrink();

          return Card(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     children: [
                       Container(
                         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                         decoration: BoxDecoration(
                           color: AppColors.surfaceLight,
                           borderRadius: BorderRadius.circular(20),
                           border: Border.all(color: Colors.grey[300]!),
                         ),
                         child: Text(order.id, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                       ),
                       Text(
                         order.timestamp.toString().substring(11, 16), // HH:mm
                         style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                       ),
                     ],
                   ),
                   const SizedBox(height: 16),
                   Text(
                     order.tableName,
                     style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                   ),
                   const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider()),
                   
                   // Items
                   ...order.items.map((item) => Padding(
                     padding: const EdgeInsets.symmetric(vertical: 4),
                     child: Row(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         const Icon(Icons.circle, size: 8, color: AppColors.primary),
                         const SizedBox(width: 8),
                         Expanded(child: Text(item, style: const TextStyle(fontSize: 16))),
                       ],
                     ),
                   )),
                   
                   const SizedBox(height: 24),
                   
                   // Timeline / Status Actions
                   Row(
                     children: [
                       _buildStatusIndicator(order.status == 'pending', 'Diterima'),
                       _buildLine(order.status != 'pending'),
                       _buildStatusIndicator(order.status == 'cooking', 'Memasak'),
                       _buildLine(order.status == 'ready' || order.status == 'completed'),
                       _buildStatusIndicator(order.status == 'ready', 'Siap Saji'),
                     ],
                   ),

                   const SizedBox(height: 24),
                   
                   Align(
                     alignment: Alignment.centerRight,
                     child: _buildActionButton(ref, order),
                   ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusIndicator(bool isActive, String label) {
    return Column(
      children: [
        Icon(
          isActive ? Icons.radio_button_checked : Icons.radio_button_unchecked,
          color: isActive ? AppColors.primary : Colors.grey[300],
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isActive ? AppColors.primary : Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildLine(bool isActive) {
    return Expanded(
      child: Container(
        height: 2,
        color: isActive ? AppColors.primary : Colors.grey[300],
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 10), // Alignment adjust
      ),
    );
  }

  Widget _buildActionButton(WidgetRef ref, KitchenOrder order) {
    if (order.status == 'pending') {
      return ElevatedButton.icon(
        onPressed: () => ref.read(kitchenControllerProvider.notifier).updateStatus(order.id, 'cooking'),
        icon: const Icon(Icons.soup_kitchen),
        label: const Text('Mulai Masak'),
      );
    }
    if (order.status == 'cooking') {
      return ElevatedButton.icon(
        onPressed: () => ref.read(kitchenControllerProvider.notifier).updateStatus(order.id, 'ready'),
        style: ElevatedButton.styleFrom(backgroundColor: AppColors.warning),
        icon: const Icon(Icons.check),
        label: const Text('Selesai Masak'),
      );
    }
    if (order.status == 'ready') {
      return ElevatedButton.icon(
        onPressed: () => ref.read(kitchenControllerProvider.notifier).updateStatus(order.id, 'completed'),
        style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
        icon: const Icon(Icons.done_all),
        label: const Text('Selesaikan'),
      );
    }
    return const SizedBox.shrink();
  }
}
