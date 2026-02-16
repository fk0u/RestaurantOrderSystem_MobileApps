import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/design_system.dart';
import 'dashboard_controller.dart';
import 'widgets/admin_drawer.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsState = ref.watch(dashboardControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const AdminDrawer(),
      appBar: AppBar(
        title: Text('Dashboard', style: AppTypography.heading3),
        centerTitle: true,
        backgroundColor: AppColors.surface,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.read(dashboardControllerProvider.notifier).refresh(),
          ),
        ],
      ),
      body: statsState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (stats) {
          final revenue = stats['revenue'] as double? ?? 0.0;
          final count = stats['count'] as int? ?? 0;
          final active = stats['active_orders'] as int? ?? 0;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimens.s24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWelcomeSection(),
                const SizedBox(height: AppDimens.s24),
                Text('Overview Hari Ini', style: AppTypography.heading3),
                const SizedBox(height: AppDimens.s16),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: 'Pendapatan',
                        value: NumberFormat.currency(
                          locale: 'id_ID',
                          symbol: 'Rp ',
                          decimalDigits: 0,
                        ).format(revenue),
                        icon: Icons.monetization_on_outlined,
                        color: Colors.green,
                        trend: '+12% dari kemarin', // Placeholder
                      ),
                    ),
                    const SizedBox(width: AppDimens.s16),
                    Expanded(
                      child: _StatCard(
                        title: 'Total Pesanan',
                        value: count.toString(),
                        icon: Icons.shopping_bag_outlined,
                        color: Colors.blue,
                        trend: '+5 pesanan baru', // Placeholder
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimens.s16),
                _StatCard(
                  title: 'Pesanan Aktif',
                  value: active.toString(),
                  icon: Icons.timer_outlined,
                  color: Colors.orange,
                  subtitle: 'Segera proses pesanan yang masuk',
                ),
                const SizedBox(height: AppDimens.s32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Menu Terlaris', style: AppTypography.heading3),
                    TextButton(
                      onPressed: () {},
                      child: const Text('Lihat Semua'),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimens.s16),
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppDimens.r16),
                    boxShadow: AppShadows.card,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.bar_chart,
                          size: 48,
                          color: AppColors.textHint,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Chart Statistik Penjualan',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          '(Akan segera hadir)',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textHint,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppDimens.s32),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: () => context.go('/kitchen'),
                    icon: const Icon(Icons.kitchen),
                    label: const Text('Buka Tampilan Dapur'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppDimens.r12),
                      ),
                      textStyle: AppTypography.button,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWelcomeSection() {
    final now = DateTime.now();
    final formatter = DateFormat('EEEE, d MMMM yyyy', 'id_ID');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Halo, Admin 👋', style: AppTypography.heading2),
        const SizedBox(height: 4),
        Text(
          formatter.format(now),
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String? trend;
  final String? subtitle;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.trend,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimens.s16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.r16),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppDimens.r8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              // Optional: Add more options or badges here
            ],
          ),
          const SizedBox(height: AppDimens.s16),
          Text(
            value,
            style: AppTypography.heading2.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          if (trend != null) ...[
            const SizedBox(height: AppDimens.s8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppDimens.r4),
              ),
              child: Text(
                trend!,
                style: AppTypography.bodySmall.copyWith(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ),
          ],
          if (subtitle != null) ...[
            const SizedBox(height: AppDimens.s8),
            Text(
              subtitle!,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textHint,
                fontSize: 10,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
