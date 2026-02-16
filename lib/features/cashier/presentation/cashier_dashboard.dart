import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'cashier_walk_in_screen.dart';

import '../../../../core/theme/design_system.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../orders/domain/order_entity.dart';
import 'cashier_controller.dart';
import 'pages/payment_screen.dart';

class CashierDashboard extends ConsumerStatefulWidget {
  const CashierDashboard({super.key});

  @override
  ConsumerState<CashierDashboard> createState() => _CashierDashboardState();
}

class _CashierDashboardState extends ConsumerState<CashierDashboard> {
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  final PageController _pageController = PageController();
  late Timer _clockTimer;
  DateTime _currentTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _currentTime = DateTime.now());
    });
  }

  @override
  void dispose() {
    _clockTimer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(cashierControllerProvider);
    final controller = ref.read(cashierControllerProvider.notifier);

    // Filter orders if needed (e.g. search)
    // For now, use all orders from state
    final orders = state.orders.value ?? [];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            Text('POS Kasir', style: AppTypography.heading3),
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.access_time, size: 16, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Text(
                    DateFormat('HH:mm:ss').format(_currentTime),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.textPrimary),
            onPressed: () => controller.loadOrders(),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.error),
            onPressed: () => ref.read(authControllerProvider.notifier).logout(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CashierWalkInScreen()),
          );
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Buat Pesanan',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 900) {
            return _buildMobileLayout(context, controller, state, orders);
          }
          return _buildTabletLayout(context, controller, state, orders);
        },
      ),
    );
  }

  Widget _buildMobileLayout(
    BuildContext context,
    CashierController controller,
    CashierState state,
    List<Order> orders,
  ) {
    return PageView(
      controller: _pageController,
      physics: const NeverScrollableScrollPhysics(), // Prevent manual swiping
      children: [
        _buildOrderList(context, controller, state, orders, isMobile: true),
        _buildPaymentSection(context, controller, state, isMobile: true),
      ],
    );
  }

  Widget _buildTabletLayout(
    BuildContext context,
    CashierController controller,
    CashierState state,
    List<Order> orders,
  ) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: _buildOrderList(context, controller, state, orders),
        ),
        Expanded(
          flex: 3,
          child: _buildPaymentSection(context, controller, state),
        ),
      ],
    );
  }

  Widget _buildOrderList(
    BuildContext context,
    CashierController controller,
    CashierState state,
    List<Order> orders, {
    bool isMobile = false,
  }) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(right: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cari Order ID / Meja...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (val) {
                // Implement local filtering if needed
              },
            ),
          ),
          Expanded(
            child: orders.isEmpty
                ? const Center(child: Text('Tidak ada order aktif'))
                : ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: orders.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      final isSelected = state.selectedOrder?.id == order.id;
                      return _OrderListTile(
                        order: order,
                        isSelected: isSelected,
                        onTap: () {
                          controller.selectOrder(order);

                          if (isMobile) {
                            _pageController.animateToPage(
                              1,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                        onDelete: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Hapus Pesanan?'),
                              content: Text(
                                'Pesanan #${order.queueNumber} akan dibatalkan. Tindakan ini tidak dapat dibatalkan.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('Batal'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  style: TextButton.styleFrom(
                                    foregroundColor: AppColors.error,
                                  ),
                                  child: const Text('Hapus'),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            await controller.cancelOrder(order.id);
                          }
                        },
                        currencyFormat: _currencyFormat,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSection(
    BuildContext context,
    CashierController controller,
    CashierState state, {
    bool isMobile = false,
  }) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.all(24),
      child: state.selectedOrder == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.point_of_sale, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Pilih pesanan untuk pembayaran',
                    style: AppTypography.heading3.copyWith(
                      color: AppColors.textHint,
                    ),
                  ),
                ],
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (isMobile)
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () {
                          _pageController.animateToPage(
                            0,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                      ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pembayaran #${state.selectedOrder!.queueNumber}',
                            style: AppTypography.heading2,
                          ),
                          Text(
                            state.selectedOrder!.id,
                            style: AppTypography.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 32),

                // Order Items Summary
                Expanded(
                  flex: 3,
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: state.selectedOrder!.items.length,
                    itemBuilder: (context, index) {
                      final item = state.selectedOrder!.items[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${item.quantity}x ${item.product.name}',
                                  style: AppTypography.bodyLarge,
                                ),
                                if (item.modifiers.isNotEmpty)
                                  Text(
                                    item.modifiers.join(', '),
                                    style: AppTypography.bodySmall,
                                  ),
                              ],
                            ),
                            Text(
                              _currencyFormat.format(
                                item.product.price * item.quantity,
                              ),
                              style: AppTypography.bodyLarge,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                const Divider(),

                // Totals
                const Divider(),

                // Subtotal & Tax
                _buildTotalRow(
                  'Subtotal',
                  state.selectedOrder!.subtotal > 0
                      ? state.selectedOrder!.subtotal
                      : state.selectedOrder!.totalPrice / 1.11, // Fallback
                  fontSize: 14,
                ),
                const SizedBox(height: 8),
                _buildTotalRow(
                  'Pajak (11%)',
                  state.selectedOrder!.tax > 0
                      ? state.selectedOrder!.tax
                      : state.selectedOrder!.totalPrice -
                            (state.selectedOrder!.totalPrice /
                                1.11), // Fallback
                  fontSize: 14,
                ),
                const SizedBox(height: 16),

                // Totals
                _buildTotalRow(
                  'Total',
                  state.selectedOrder!.totalPrice,
                  isBold: true,
                  fontSize: 24,
                ),
                const SizedBox(height: 24),

                // Payment Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              PaymentScreen(order: state.selectedOrder!),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Bayar ${_currencyFormat.format(state.selectedOrder!.totalPrice)}',
                      style: AppTypography.heading3.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildTotalRow(
    String label,
    double amount, {
    bool isBold = false,
    double fontSize = 16,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.bodyLarge.copyWith(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: fontSize,
          ),
        ),
        Text(
          _currencyFormat.format(amount),
          style: AppTypography.bodyLarge.copyWith(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: fontSize,
            color: isBold ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _OrderListTile extends StatelessWidget {
  final Order order;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final NumberFormat currencyFormat;

  const _OrderListTile({
    required this.order,
    required this.isSelected,
    required this.onTap,
    this.onDelete,
    required this.currencyFormat,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
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
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.textPrimary,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      DateFormat('HH:mm').format(order.timestamp),
                      style: AppTypography.bodySmall,
                    ),
                    if (onDelete != null) ...[
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: onDelete,
                        child: const Icon(
                          Icons.delete_outline,
                          color: AppColors.error,
                          size: 20,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              order.orderType == 'dine_in'
                  ? 'Meja ${order.tableNumber}'
                  : 'Takeaway - ${order.userName}',
              style: AppTypography.bodyMedium,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Chip(
                  label: Text(
                    order.status,
                    style: TextStyle(
                      fontSize: 10,
                      color: isSelected ? AppColors.primary : Colors.grey[700],
                    ),
                  ),
                  backgroundColor: isSelected ? Colors.white : Colors.grey[100],
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                ),
                Text(
                  currencyFormat.format(order.totalPrice),
                  style: AppTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
