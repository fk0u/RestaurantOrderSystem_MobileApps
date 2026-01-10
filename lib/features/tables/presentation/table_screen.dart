import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../auth/presentation/auth_controller.dart';
import 'table_controller.dart';
import '../domain/table_entity.dart';

class TableScreen extends ConsumerWidget {
  const TableScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tableState = ref.watch(tableControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Denah Meja', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(tableControllerProvider),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authControllerProvider.notifier).logout(),
          ),
        ],
      ),
      body: tableState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (tables) {
          return GridView.builder(
            padding: const EdgeInsets.all(24),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 24,
              mainAxisSpacing: 24,
              childAspectRatio: 1.2,
            ),
            itemCount: tables.length,
            itemBuilder: (context, index) {
              final table = tables[index];
              return _buildTableCard(context, ref, table);
            },
          );
        },
      ),
    );
  }

  Widget _buildTableCard(BuildContext context, WidgetRef ref, RestaurantTable table) {
    Color color;
    IconData icon;
    String statusText;

    // Determine Color and Icon based on status
    if (table.status == 'occupied') {
      color = Colors.red[100]!;
      icon = Icons.people;
      statusText = 'Terisi';
    } else if (table.status == 'reserved') {
      color = Colors.orange[100]!;
      icon = Icons.lock_clock;
      statusText = 'Reservasi';
    } else {
      color = Colors.green[100]!;
      icon = Icons.table_restaurant;
      statusText = 'Kosong';
    }

    final isAvailable = table.status == 'available';

    return InkWell(
      onTap: () {
        if (isAvailable) {
          // Select table and go to menu
          // In real app, store selected tableId in a provider/global state
          // For now, simple Alert or Navigate
          _showActionDialog(context, ref, table);
        } else {
           // View order details for this table?
           _showActionDialog(context, ref, table);
        }
      },
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: table.status == 'available' ? AppColors.success : Colors.grey[300]!,
            width: 2,
          ),
          boxShadow: [
             BoxShadow(
               color: color.withValues(alpha: 0.5),
               blurRadius: 20,
               offset: const Offset(0, 10),
             ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: Colors.black54),
            ),
            const SizedBox(height: 16),
            Text(
              table.number,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              'Kapasitas: ${table.capacity}',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                statusText,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showActionDialog(BuildContext context, WidgetRef ref, RestaurantTable table) {
     showModalBottomSheet(
       context: context,
       shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
       builder: (ctx) {
         return Container(
           padding: const EdgeInsets.all(24),
           child: Column(
             mainAxisSize: MainAxisSize.min,
             children: [
               Text('Meja ${table.number}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
               const SizedBox(height: 24),
               if (table.status == 'available') ...[
                 ListTile(
                   leading: const Icon(Icons.add_shopping_cart, color: AppColors.primary),
                   title: const Text('Buat Pesanan Baru'),
                   onTap: () {
                     // Mark occupied
                     ref.read(tableControllerProvider.notifier).updateStatus(table.id, 'occupied');
                     context.pop();
                     context.go('/menu'); // Go to menu
                   },
                 ),
                 ListTile(
                   leading: const Icon(Icons.bookmark_border, color: Colors.orange),
                   title: const Text('Tandai Reservasi'),
                   onTap: () {
                     ref.read(tableControllerProvider.notifier).updateStatus(table.id, 'reserved');
                     context.pop();
                   },
                 ),
               ] else ...[
                 ListTile(
                   leading: const Icon(Icons.receipt_long, color: AppColors.primary),
                   title: const Text('Lihat Pesanan'),
                   onTap: () {
                     context.pop();
                     context.go('/menu'); // Or specific table order view
                   },
                 ),
                 ListTile(
                   leading: const Icon(Icons.done_all, color: AppColors.success),
                   title: const Text('Kosongkan Meja (Selesai)'),
                   onTap: () {
                     ref.read(tableControllerProvider.notifier).updateStatus(table.id, 'available');
                     context.pop();
                   },
                 ),
               ]
             ],
           ),
         );
       }
     );
  }
}
