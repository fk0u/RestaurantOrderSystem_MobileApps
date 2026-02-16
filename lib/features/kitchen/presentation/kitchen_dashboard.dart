import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
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

        return MasonryGridView.count(
          padding: const EdgeInsets.all(AppDimens.s16),
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: AppDimens.s16,
          crossAxisSpacing: AppDimens.s16,
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

class _KitchenOrderCard extends StatelessWidget {
  final Order order;
  final Function(String, String) onStatusUpdate;

  const _KitchenOrderCard({required this.order, required this.onStatusUpdate});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.r12),
        boxShadow: AppShadows.card,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min, // Important for Masonry
        children: [
          // Header with Timer
          _KitchenTimer(
            timestamp: order.timestamp,
            status: order.status,
            orderNumber: order.queueNumber.toString(),
            orderType: order.orderType,
            tableNumber: order.tableNumber,
          ),

          // Items List
          Padding(
            padding: const EdgeInsets.all(AppDimens.s12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...order.items.map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${item.quantity}x',
                              style: AppTypography.heading3.copyWith(
                                color: AppColors.primary,
                                fontSize: 18,
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
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        if (item.note != null && item.note!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(left: 32, top: 4),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.yellow[100],
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: Colors.orange[200]!),
                              ),
                              child: Text(
                                'Note: ${item.note}',
                                style: AppTypography.bodySmall.copyWith(
                                  color: Colors.orange[900],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),

          const Divider(height: 1),

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
                          onTap: () =>
                              onStatusUpdate(order.id, 'Sedang Dimasak'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _ActionButton(
                          label: 'Siap',
                          color: Colors.green,
                          isActive: order.status == 'Siap Saji',
                          onTap: () => onStatusUpdate(order.id, 'Siap Saji'),
                        ),
                      ),
                    ],
                  ),
                if (order.status == 'Siap Saji')
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => onStatusUpdate(order.id, 'Selesai'),
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
    );
  }
}

class _KitchenTimer extends StatefulWidget {
  final DateTime timestamp;
  final String status;
  final String orderNumber;
  final String orderType;
  final String? tableNumber;

  const _KitchenTimer({
    required this.timestamp,
    required this.status,
    required this.orderNumber,
    required this.orderType,
    this.tableNumber,
  });

  @override
  State<_KitchenTimer> createState() => _KitchenTimerState();
}

class _KitchenTimerState extends State<_KitchenTimer>
    with SingleTickerProviderStateMixin {
  late Timer _timer;
  Duration _duration = Duration.zero;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _updateDuration();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) _updateDuration();
    });

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  void _updateDuration() {
    setState(() {
      _duration = DateTime.now().difference(widget.timestamp);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  Color get _statusColor {
    if (widget.status == 'Siap Saji') return AppColors.primary;
    if (_duration.inMinutes < 15) return Colors.green;
    if (_duration.inMinutes < 30) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final isCritical =
        _duration.inMinutes >= 30 && widget.status != 'Siap Saji';

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: isCritical ? _pulseAnimation.value : 1.0,
          child: Container(
            padding: const EdgeInsets.all(AppDimens.s12),
            decoration: BoxDecoration(
              color: _statusColor,
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
                      '#${widget.orderNumber}',
                      style: AppTypography.heading3.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(AppDimens.r4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.timer_outlined,
                            size: 14,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatDuration(_duration),
                            style: AppTypography.bodySmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontFeatures: [
                                const FontFeature.tabularFigures(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  widget.orderType == 'dine_in'
                      ? 'Meja ${widget.tableNumber ?? "?"}'
                      : 'Takeaway',
                  style: AppTypography.bodyMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(d.inHours);
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return d.inHours > 0 ? '$hours:$minutes:$seconds' : '$minutes:$seconds';
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
