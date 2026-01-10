import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/design_system.dart';

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
              child: TabBarView(
                controller: _tabController,
                children: [
                   // Active Orders
                   ListView(
                     padding: const EdgeInsets.fromLTRB(AppDimens.s21, AppDimens.s21, AppDimens.s21, 100),
                     children: [
                       _buildOrderCard(
                         context, 
                         'ORD-9281', 
                         'Sedang Dimasak', 
                         AppColors.warning,
                         ['Burger Sapi Klasik x1', 'Kentang Goreng x1'],
                         '2 Item',
                         'Rp 65.000',
                         0.5
                       ),
                     ],
                   ),
                   // History
                   ListView(
                     padding: const EdgeInsets.fromLTRB(AppDimens.s21, AppDimens.s21, AppDimens.s21, 100),
                     children: [
                        _buildOrderCard(
                         context, 
                         'ORD-1002', 
                         'Selesai', 
                         AppColors.success,
                         ['Pasta Carbonara x1', 'Es Teh Lemon x2'],
                         '3 Item',
                         'Rp 85.000',
                         1.0
                       ),
                       const SizedBox(height: AppDimens.s13),
                       _buildOrderCard(
                         context, 
                         'ORD-0991', 
                         'Selesai', 
                         AppColors.success,
                         ['Ayam Goreng Krispi x2'],
                         '2 Item',
                         'Rp 70.000',
                         1.0
                       ),
                     ],
                   ),
                ],
              ),
            ),
            // Spacer for Dock
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(
    BuildContext context, 
    String id, 
    String status, 
    Color statusColor,
    List<String> items,
    String itemCount,
    String total,
    double progress,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppDimens.s21),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimens.r24),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(id, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(status, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.s13),
          const Divider(),
          const SizedBox(height: AppDimens.s13),
          
          ...items.map((i) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(i, style: const TextStyle(fontSize: 15)),
          )),
          
          const SizedBox(height: AppDimens.s21),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(itemCount, style: const TextStyle(color: AppColors.textSecondary)),
              Text(total, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          
          if (progress < 1.0) ...[
             const SizedBox(height: AppDimens.s21),
             ClipRRect(
               borderRadius: BorderRadius.circular(4),
               child: LinearProgressIndicator(value: progress, backgroundColor: Colors.grey[100], color: AppColors.primary),
             ),
          ]
        ],
      ),
    );
  }
}
