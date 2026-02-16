import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:restaurant_order_system/features/cashier/presentation/widgets/payment_success_dialog.dart';
import 'cashier_walk_in_screen.dart';
import 'package:restaurant_order_system/core/input/toaster.dart';
import '../../../../core/theme/design_system.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../orders/domain/order_entity.dart';
import 'cashier_controller.dart';

class CashierDashboard extends ConsumerStatefulWidget {
  const CashierDashboard({super.key});

  @override
  ConsumerState<CashierDashboard> createState() => _CashierDashboardState();
}

class _CashierDashboardState extends ConsumerState<CashierDashboard> {
  final TextEditingController _cashController = TextEditingController();
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void dispose() {
    _cashController.dispose();
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
        title: Text('POS Kasir', style: AppTypography.heading3),
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
      body: Row(
        children: [
          // LEFT: Order List
          Expanded(
            flex: 2,
            child: Container(
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
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: orders.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final order = orders[index];
                              final isSelected =
                                  state.selectedOrder?.id == order.id;
                              return _OrderListTile(
                                order: order,
                                isSelected: isSelected,
                                onTap: () {
                                  controller.selectOrder(order);
                                  _cashController.clear();
                                },
                                currencyFormat: _currencyFormat,
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),

          // RIGHT: Payment Terminal
          Expanded(
            flex: 3,
            child: Container(
              color: AppColors.surface,
              padding: const EdgeInsets.all(24),
              child: state.selectedOrder == null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.point_of_sale,
                            size: 80,
                            color: Colors.grey[300],
                          ),
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
                        // Header info
                        Text(
                          'Pembayaran #${state.selectedOrder!.queueNumber}',
                          style: AppTypography.heading2,
                        ),
                        Text(
                          state.selectedOrder!.id,
                          style: AppTypography.bodySmall,
                        ),
                        const Divider(height: 32),

                        // Order Items Summary
                        Expanded(
                          child: ListView.builder(
                            itemCount: state.selectedOrder!.items.length,
                            itemBuilder: (context, index) {
                              final item = state.selectedOrder!.items[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                              : state.selectedOrder!.totalPrice /
                                    1.11, // Fallback
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

                        // Payment Method Tabs
                        DefaultTabController(
                          length: 3,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.all(4),
                                child: TabBar(
                                  labelColor: Colors.white,
                                  unselectedLabelColor: Colors.grey[600],
                                  indicator: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  indicatorSize: TabBarIndicatorSize.tab,
                                  dividerColor: Colors.transparent,
                                  onTap: (index) {
                                    final method = [
                                      'cash',
                                      'qris',
                                      'card',
                                    ][index];
                                    controller.selectPaymentMethod(method);
                                  },
                                  tabs: const [
                                    Tab(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.money, size: 18),
                                          SizedBox(width: 8),
                                          Text('Tunai'),
                                        ],
                                      ),
                                    ),
                                    Tab(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.qr_code, size: 18),
                                          SizedBox(width: 8),
                                          Text('QRIS'),
                                        ],
                                      ),
                                    ),
                                    Tab(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.credit_card, size: 18),
                                          SizedBox(width: 8),
                                          Text('Kartu'),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                height: 300, // Fixed height for content
                                child: TabBarView(
                                  children: [
                                    // 1. Tunai (Cash)
                                    _buildCashPayment(
                                      context,
                                      controller,
                                      state,
                                    ),
                                    // 2. QRIS
                                    _buildQrisPayment(
                                      context,
                                      controller,
                                      state,
                                    ),
                                    // 3. Debit/Credit
                                    _buildCardPayment(
                                      context,
                                      controller,
                                      state,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _updateCashInput(double value) {
    _cashController.text = value.toStringAsFixed(0);
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

  Widget _buildCashPayment(
    BuildContext context,
    CashierController controller,
    CashierState state,
  ) {
    return Column(
      children: [
        TextField(
          controller: _cashController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Uang Tunai (Cash)',
            prefixText: 'Rp ',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _cashController.clear();
                controller.updateCashTendered(0);
              },
            ),
          ),
          onChanged: (val) {
            final amount =
                double.tryParse(val.replaceAll('.', '').replaceAll(',', '')) ??
                0;
            controller.updateCashTendered(amount);
          },
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          children: [
            _QuickAmountChip(
              amount: state.selectedOrder!.totalPrice,
              label: 'Pas',
              onTap: (val) {
                _updateCashInput(val);
                controller.updateCashTendered(val);
              },
            ),
            _QuickAmountChip(
              amount: 50000,
              label: '50k',
              onTap: (val) {
                _updateCashInput(val);
                controller.updateCashTendered(val);
              },
            ),
            _QuickAmountChip(
              amount: 100000,
              label: '100k',
              onTap: (val) {
                _updateCashInput(val);
                controller.updateCashTendered(val);
              },
            ),
          ],
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: state.change >= 0
                ? AppColors.primaryLight
                : Colors.red.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Kembalian', style: AppTypography.heading3),
              Text(
                _currencyFormat.format(state.change),
                style: AppTypography.heading3.copyWith(
                  color: state.change >= 0 ? AppColors.primary : Colors.red,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        _buildPayButton(
          context,
          controller,
          state,
          label: 'Bayar Tunai',
          onPressed: () async {
            if (state.change >= 0) {
              return await controller.processPayment(paymentMethod: 'cash');
            }
            return false;
          },
        ),
      ],
    );
  }

  Widget _buildQrisPayment(
    BuildContext context,
    CashierController controller,
    CashierState state,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[200]!),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(Icons.qr_code_2, size: 150, color: Colors.black),
              const SizedBox(height: 8),
              const Text(
                'Nusantara Resto QRIS',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Scan QRIS untuk Pembayaran',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Text(
          'Total Tagihan: ${_currencyFormat.format(state.selectedOrder!.totalPrice)}',
          style: AppTypography.heading3.copyWith(color: AppColors.primary),
        ),
        const Spacer(),
        _buildPayButton(
          context,
          controller,
          state,
          label: 'Cek Status & Konfirmasi',
          onPressed: () async {
            return await controller.processPayment(
              paymentMethod: 'qris',
              reference: 'QRIS-${DateTime.now().millisecondsSinceEpoch}',
            );
          },
        ),
      ],
    );
  }

  Widget _buildCardPayment(
    BuildContext context,
    CashierController controller,
    CashierState state,
  ) {
    final TextEditingController refController = TextEditingController();

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue[100]!),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue[800]),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Silakan lakukan transaksi di mesin EDC terlebih dahulu. Masukkan Kode Approval setelah berhasil.',
                  style: TextStyle(color: Colors.blue[900], fontSize: 13),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: refController,
          decoration: InputDecoration(
            labelText: 'Kode Approval / Ref No.',
            hintText: 'Contoh: 123456',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: const Icon(Icons.receipt_long),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        // Simulation Button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              refController.text =
                  'EDC-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
            },
            icon: const Icon(Icons.settings_ethernet),
            label: const Text('Simulasi Baca Kartu (EDC)'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const Spacer(),
        _buildPayButton(
          context,
          controller,
          state,
          label: 'Konfirmasi Pembayaran Kartu',
          onPressed: () async {
            if (refController.text.isEmpty) {
              Toaster.showError(context, 'Masukkan nomor referensi');
              return false;
            }
            return await controller.processPayment(
              paymentMethod: 'card',
              reference: refController.text,
            );
          },
        ),
      ],
    );
  }

  Widget _buildPayButton(
    BuildContext context,
    CashierController controller,
    CashierState state, {
    required String label,
    required Future<bool> Function() onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () async {
          // Capture state values before they might be cleared by controller
          final orderToPay = state.selectedOrder;
          // Calculate change based on current state (before processing)
          final total = orderToPay?.totalPrice ?? 0;
          final tendered = state.cashTendered;
          final changeAmount = tendered > total ? tendered - total : 0.0;
          final method = state.selectedPaymentMethod;

          final success = await onPressed();

          if (success && context.mounted && orderToPay != null) {
            _cashController.clear();

            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => PaymentSuccessDialog(
                order: orderToPay.copyWith(
                  paymentStatus: 'paid',
                  paymentMethod: method,
                  paidAt: DateTime.now(),
                ),
                change: changeAmount,
              ),
            );
          } else if (state.error != null && context.mounted) {
            Toaster.showError(context, state.error!);
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: state.isProcessing
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}

class _OrderListTile extends StatelessWidget {
  final Order order;
  final bool isSelected;
  final VoidCallback onTap;
  final NumberFormat currencyFormat;

  const _OrderListTile({
    required this.order,
    required this.isSelected,
    required this.onTap,
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
                Text(
                  DateFormat('HH:mm').format(order.timestamp),
                  style: AppTypography.bodySmall,
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

class _QuickAmountChip extends StatelessWidget {
  final double amount;
  final String label;
  final Function(double) onTap;

  const _QuickAmountChip({
    required this.amount,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label),
      onPressed: () => onTap(amount),
      backgroundColor: Colors.grey[100],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}
