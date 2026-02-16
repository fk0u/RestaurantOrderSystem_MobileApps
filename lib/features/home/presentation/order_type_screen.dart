import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/design_system.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../orders/presentation/order_type_provider.dart';

class OrderTypeScreen extends ConsumerWidget {
  const OrderTypeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Pilih Jenis Pesanan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authControllerProvider.notifier).logout();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppDimens.s24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Mau makan bagaimana hari ini?',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 48),

            // Dine In
            _buildOptionCard(
              context,
              icon: Icons.store_mall_directory,
              title: 'Makan di Tempat',
              subtitle: 'Pilih meja dan pesan menu',
              color: Colors.blue[100]!,
              onTap: () {
                ref.read(orderTypeProvider.notifier).state = OrderType.dineIn;
                context.go('/tables');
              },
            ),
            const SizedBox(height: 24),

            // Takeaway
            _buildOptionCard(
              context,
              icon: Icons.shopping_bag,
              title: 'Bawa Pulang',
              subtitle: 'Pesan dan ambil sendiri',
              color: Colors.orange[100]!,
              onTap: () {
                ref.read(orderTypeProvider.notifier).state = OrderType.takeaway;
                context.go('/menu');
              },
            ),
            const SizedBox(height: 24),

            // Delivery
            _buildOptionCard(
              context,
              icon: Icons.delivery_dining,
              title: 'Delivery',
              subtitle: 'Antar ke lokasi kamu',
              color: Colors.green[100]!,
              onTap: () {
                ref.read(orderTypeProvider.notifier).state = OrderType.delivery;
                context.go('/menu');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              child: Icon(icon, size: 32, color: Colors.black87),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
