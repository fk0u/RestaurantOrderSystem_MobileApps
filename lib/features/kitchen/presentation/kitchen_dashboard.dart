import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:restaurant_order_system/core/input/toaster.dart';
import '../../../../core/theme/design_system.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../orders/domain/order_entity.dart';
import 'kitchen_controller.dart';

class KitchenDashboard extends ConsumerStatefulWidget {
  const KitchenDashboard({super.key});

  @override
  ConsumerState<KitchenDashboard> createState() => _KitchenDashboardState();
}

class _KitchenDashboardState extends ConsumerState<KitchenDashboard> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Refresh UI every minute to update "Duration"
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(kitchenControllerProvider);

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text('Kitchen Display System', style: AppTypography.heading3),
          backgroundColor: AppColors.surface,
          elevation: 0,
          centerTitle: true,
          bottom: TabBar(
            labelStyle: AppTypography.button.copyWith(color: AppColors.primary),
            unselectedLabelStyle: AppTypography.bodyMedium,
            indicatorColor: AppColors.primary,
            tabs: const [
              Tab(text: 'Semua'),
              Tab(text: 'Proses'),
              Tab(text: 'Masak'),
              Tab(text: 'Siap'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: AppColors.textPrimary),
              onPressed: () => ref.refresh(kitchenControllerProvider),
            ),
            IconButton(
              icon: const Icon(Icons.logout, color: AppColors.error),
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
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.kitchen,
                      size: 64,
                      color: AppColors.textHint,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Tidak ada pesanan aktif',
                      style: AppTypography.heading3.copyWith(
                        color: AppColors.textHint,
                      ),
                    ),
                  ],
                ),
              );
            }

            final sortedOrders = [...orders]
              ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

            List<Order> filtered(String status) {
              if (status == 'all') return sortedOrders;
              return sortedOrders.where((o) => o.status == status).toList();
            }

            return TabBarView(
              children: [
                _buildOrderGrid(filtered('all')),
                _buildOrderGrid(filtered('Sedang Diproses')),
                _buildOrderGrid(filtered('Sedang Dimasak')),
                _buildOrderGrid(filtered('Siap Saji')),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildOrderGrid(List<Order> orders) {
    if (orders.isEmpty) {
      return Center(
        child: Text(
          'Kosong',
          style: AppTypography.heading3.copyWith(color: AppColors.textHint),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive Grid Count
        int crossAxisCount = 1;
        if (constraints.maxWidth > 1200) {
          crossAxisCount = 4;
        } else if (constraints.maxWidth > 800) {
          crossAxisCount = 3;
        } else if (constraints.maxWidth > 600) {
          crossAxisCount = 2;
        }

        return GridView.builder(
          padding: const EdgeInsets.all(AppDimens.s16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 0.75, // Taller cards for content
            crossAxisSpacing: AppDimens.s16,
            mainAxisSpacing: AppDimens.s16,
          ),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            return _KitchenOrderCard(
              order: orders[index],
              onStatusUpdate: (id, status) {
                ref
                    .read(kitchenControllerProvider.notifier)
                    .updateStatus(id, status);
                Toaster.showSuccess(context, 'Order updated to $status');
              },
            );
          },
        );
      },
    );
  }
}

class _KitchenOrderCard extends StatefulWidget {
  final Order order;
  final Function(String, String) onStatusUpdate;

  const _KitchenOrderCard({required this.order, required this.onStatusUpdate});

  @override
  State<_KitchenOrderCard> createState() => _KitchenOrderCardState();
}

class _KitchenOrderCardState extends State<_KitchenOrderCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final duration = DateTime.now().difference(order.timestamp);
    final minutes = duration.inMinutes;

    // Color Coding based on wait time
    Color headerColor;
    Color textColor = Colors.white;

    if (minutes < 15) {
      headerColor = Colors.green; // Fresh
    } else if (minutes < 30) {
      headerColor = Colors.orange; // Warning
    } else {
      headerColor = Colors.red; // Critical
    }

    if (order.status == 'Siap Saji') {
      headerColor = AppColors.primary; // Ready state overrides time warning
    }

    return ScaleTransition(
      scale: _scaleAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppDimens.r12),
            boxShadow: AppShadows.card,
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(AppDimens.s12),
                decoration: BoxDecoration(
                  color: headerColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppDimens.r12),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '#${order.queueNumber}',
                          style: AppTypography.heading3.copyWith(
                            color: textColor,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(51), // 0.2 alpha
                            borderRadius: BorderRadius.circular(AppDimens.r4),
                          ),
                          child: Text(
                            '${minutes}m',
                            style: AppTypography.bodySmall.copyWith(
                              color: textColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      order.orderType == 'dine_in'
                          ? 'Meja ${order.tableNumber ?? "?"}'
                          : 'Takeaway',
                      style: AppTypography.bodyMedium.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              // Items List
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(AppDimens.s12),
                  itemCount: order.items.length,
                  separatorBuilder: (context, index) =>
                      const Divider(color: AppColors.border),
                  itemBuilder: (context, index) {
                    final item = order.items[index];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${item.quantity}x',
                              style: AppTypography.heading3.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: AppDimens.s8),
                            Expanded(
                              child: Text(
                                item.product.name,
                                style: AppTypography.bodyLarge.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (item.modifiers.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(left: 32, top: 2),
                            child: Text(
                              item.modifiers.join(', '),
                              style: AppTypography.bodySmall.copyWith(
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        if (item.note != null && item.note!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(left: 32, top: 4),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.yellow.withAlpha(25), // 0.1 alpha
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Note: ${item.note}',
                                style: AppTypography.bodySmall.copyWith(
                                  color: Colors.orange[800],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),

              // Actions
              Padding(
                padding: const EdgeInsets.all(AppDimens.s12),
                child: Column(
                  children: [
                    if (order.status != 'Siap Saji')
                      Row(
                        children: [
                          Expanded(
                            child: _ActionButton(
                              label: 'Masak',
                              color: Colors.orange,
                              isActive: order.status == 'Sedang Dimasak',
                              onTap: () => widget.onStatusUpdate(
                                order.id,
                                'Sedang Dimasak',
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _ActionButton(
                              label: 'Siap',
                              color: Colors.green,
                              isActive: order.status == 'Siap Saji',
                              onTap: () =>
                                  widget.onStatusUpdate(order.id, 'Siap Saji'),
                            ),
                          ),
                        ],
                      ),
                    if (order.status == 'Siap Saji')
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () =>
                              widget.onStatusUpdate(order.id, 'Selesai'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppDimens.r8),
                            ),
                          ),
                          child: const Text('Selesaikan Order'),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final bool isActive;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.color,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: isActive ? color : Colors.white,
        foregroundColor: isActive ? Colors.white : color,
        elevation: 0,
        side: BorderSide(color: color),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.r8),
        ),
      ),
      child: Text(label),
    );
  }
}
