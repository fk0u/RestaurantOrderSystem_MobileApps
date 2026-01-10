import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../auth/presentation/auth_controller.dart';
import 'kitchen_controller.dart';

class KitchenDashboard extends ConsumerWidget {
  const KitchenDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(kitchenControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Sistem Dapur Displai', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(kitchenControllerProvider),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authControllerProvider.notifier).logout(),
          ),
        ],
      ),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (orders) {
          if (orders.isEmpty) {
            return const Center(child: Text("Tidak ada pesanan aktif"));
          }

          // Sort orders
          final sortedOrders = [...orders];
          // Simple sort by time for now
          sortedOrders.sort((a, b) => a.timestamp.compareTo(b.timestamp));

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: sortedOrders.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final order = sortedOrders[index];
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
                             "${order.timestamp.hour}:${order.timestamp.minute.toString().padLeft(2, '0')}", 
                             style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                           ),
                         ],
                       ),
                       const SizedBox(height: 16),
                       Text(
                         order.userName, // Using userName as table/identifier
                         style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                       ),
                       const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider()),
                       
                       // Items
                       ...order.items.map((item) {
                          String displayText = "${item.product.name} x ${item.quantity}";
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
                                 const Icon(Icons.circle, size: 8, color: AppColors.primary),
                                 const SizedBox(width: 8),
                                 Expanded(child: Text(displayText, style: const TextStyle(fontSize: 16))),
                               ],
                             ),
                           );
                       }),
                       
                       const SizedBox(height: 24),
                       
                       // Status Actions
                       Row(
                         children: [
                           // Display Status Flow
                           // 'Sedang Diproses' -> 'Sedang Dimasak' -> 'Siap Saji' -> 'Selesai'
                           _buildStatusButton(ref, order.id, 'Sedang Diproses', order.status == 'Sedang Diproses'),
                           _buildLine(true),
                           _buildStatusButton(ref, order.id, 'Sedang Dimasak', order.status == 'Sedang Dimasak'),
                           _buildLine(true),
                           _buildStatusButton(ref, order.id, 'Siap Saji', order.status == 'Siap Saji'),
                           _buildLine(true),
                           Expanded(child: ElevatedButton(
                             onPressed: () => ref.read(kitchenControllerProvider.notifier).updateStatus(order.id, 'Selesai'), 
                             style: ElevatedButton.styleFrom(backgroundColor: AppColors.success, foregroundColor: Colors.white),
                             child: const Text("Selesai"),
                           )),
                         ],
                       ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStatusButton(WidgetRef ref, String orderId, String status, bool isActive) {
     return InkWell(
        onTap: () => ref.read(kitchenControllerProvider.notifier).updateStatus(orderId, status),
        child: Container(
           padding: const EdgeInsets.all(8),
           decoration: BoxDecoration(
             color: isActive ? AppColors.primary : Colors.grey[200],
             shape: BoxShape.circle,
           ),
           child: Icon(
             isActive ? Icons.check : Icons.circle_outlined, 
             color: isActive ? Colors.white : Colors.grey,
             size: 20,
           ),
        ),
     );
  }

  Widget _buildLine(bool isActive) {
    return Expanded(
      child: Container(
        height: 2,
        color: isActive ? AppColors.primary : Colors.grey[300],
      ),
    );
  }
}
