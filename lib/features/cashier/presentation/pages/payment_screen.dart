import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:restaurant_order_system/core/input/toaster.dart';
import '../../../../core/theme/design_system.dart';
import '../../../../features/orders/domain/order_entity.dart';
import 'package:restaurant_order_system/features/cashier/presentation/widgets/payment_success_dialog.dart';
import '../cashier_controller.dart';
import '../widgets/custom_numpad.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  final Order order;

  const PaymentScreen({super.key, required this.order});

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _cashController = TextEditingController();
  final TextEditingController _cardRefController = TextEditingController();

  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Set initial payment method in controller
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(cashierControllerProvider.notifier).selectPaymentMethod('cash');
    });

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        final method = ['cash', 'qris', 'card'][_tabController.index];
        ref
            .read(cashierControllerProvider.notifier)
            .selectPaymentMethod(method);
      }
    });

    _cashController.addListener(() {
      final text = _cashController.text.replaceAll(RegExp(r'[^0-9]'), '');
      final amount = double.tryParse(text) ?? 0;
      ref.read(cashierControllerProvider.notifier).updateCashTendered(amount);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _cashController.dispose();
    _cardRefController.dispose();
    super.dispose();
  }

  void _onNumpadChange(String value) {
    String currentText = _cashController.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (value == 'BACKSPACE') {
      if (currentText.isNotEmpty) {
        currentText = currentText.substring(0, currentText.length - 1);
      }
    } else if (value == '00') {
      currentText += '00';
    } else {
      currentText += value;
    }

    // Format with currency
    if (currentText.isEmpty) {
      _cashController.clear();
      return;
    }

    final number = int.tryParse(currentText) ?? 0;
    _cashController.value = TextEditingValue(
      text: NumberFormat.currency(
        locale: 'id_ID',
        symbol: '',
        decimalDigits: 0,
      ).format(number).trim(),
      selection: TextSelection.collapsed(offset: _cashController.text.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(cashierControllerProvider);
    final controller = ref.read(cashierControllerProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Pembayaran #${widget.order.queueNumber}',
          style: AppTypography.heading3,
        ),
        backgroundColor: AppColors.surface,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Order Summary Header
          Container(
            padding: const EdgeInsets.all(24),
            color: AppColors.primary,
            child: Column(
              children: [
                Text(
                  'Total Tagihan',
                  style: AppTypography.bodyLarge.copyWith(
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _currencyFormat.format(widget.order.totalPrice),
                  style: AppTypography.heading1.copyWith(
                    color: Colors.white,
                    fontSize: 40,
                  ),
                ),
              ],
            ),
          ),

          // Payment Methods
          Container(
            color: AppColors.surface,
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: Colors.grey,
              indicatorColor: AppColors.primary,
              tabs: const [
                Tab(text: 'Tunai', icon: Icon(Icons.money)),
                Tab(text: 'QRIS', icon: Icon(Icons.qr_code)),
                Tab(text: 'Kartu', icon: Icon(Icons.credit_card)),
              ],
            ),
          ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildCashTab(state),
                _buildQrisTab(state),
                _buildCardTab(state),
              ],
            ),
          ),

          // Bottom Action Button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  offset: const Offset(0, -4),
                  blurRadius: 16,
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () async {
                  final success = await _processPayment(controller, state);

                  if (!context.mounted) return;

                  if (success) {
                    Navigator.pop(context); // Close payment screen on success
                  } else {
                    final currentState = ref.read(cashierControllerProvider);
                    if (currentState.error != null) {
                      Toaster.showError(context, currentState.error!);
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Bayar Sekarang',
                  style: AppTypography.heading3.copyWith(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCashTab(CashierState state) {
    return Row(
      children: [
        // Left: Amount & Change
        Expanded(
          flex: 4,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Uang Diterima', style: AppTypography.bodySmall),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _cashController,
                      readOnly: true, // Use numpad only
                      style: AppTypography.heading1.copyWith(
                        color: AppColors.primary,
                      ),
                      decoration: const InputDecoration(
                        prefixText: 'Rp ',
                        border: InputBorder.none,
                        hintText: '0',
                      ),
                    ),
                    const Divider(height: 32),
                    Text('Kembalian', style: AppTypography.bodySmall),
                    const SizedBox(height: 8),
                    Text(
                      _currencyFormat.format(state.change),
                      style: AppTypography.heading2.copyWith(
                        color: state.change >= 0 ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
                // Quick Amounts
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _QuickAmountButton(
                      amount: widget.order.totalPrice,
                      label: 'Uang Pas',
                      onTap: () => _setExactAmount(widget.order.totalPrice),
                    ),
                    _QuickAmountButton(
                      amount: 50000,
                      label: '50k',
                      onTap: () => _setExactAmount(50000),
                    ),
                    _QuickAmountButton(
                      amount: 100000,
                      label: '100k',
                      onTap: () => _setExactAmount(100000),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        // Right: Numpad
        Expanded(
          flex: 3,
          child: Container(
            decoration: BoxDecoration(
              border: Border(left: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Center(
              child: SizedBox(
                width: 300,
                child: CustomNumpad(
                  onValueChanged: _onNumpadChange,
                  onClear: () {
                    _cashController.clear();
                    ref
                        .read(cashierControllerProvider.notifier)
                        .updateCashTendered(0);
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQrisTab(CashierState state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.qr_code_2, size: 200),
          const SizedBox(height: 24),
          Text('Scan QRIS untuk membayar', style: AppTypography.heading3),
        ],
      ),
    );
  }

  Widget _buildCardTab(CashierState state) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.credit_card, size: 80, color: Colors.grey),
          const SizedBox(height: 24),
          TextField(
            controller: _cardRefController,
            decoration: InputDecoration(
              labelText: 'Nomor Referensi Kartu / EDC',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.receipt_long),
            ),
          ),
        ],
      ),
    );
  }

  void _setExactAmount(double amount) {
    _cashController.text = NumberFormat.currency(
      locale: 'id_ID',
      symbol: '',
      decimalDigits: 0,
    ).format(amount).trim();
    ref.read(cashierControllerProvider.notifier).updateCashTendered(amount);
  }

  Future<bool> _processPayment(
    CashierController controller,
    CashierState state,
  ) async {
    final method = ['cash', 'qris', 'card'][_tabController.index];

    if (method == 'cash') {
      if (state.change < 0) {
        Toaster.showError(context, 'Uang tunai kurang!');
        return false;
      }
      return await controller.processPayment(paymentMethod: 'cash');
    } else if (method == 'card') {
      if (_cardRefController.text.isEmpty) {
        Toaster.showError(context, 'Masukkan nomor referensi kartu');
        return false;
      }
      return await controller.processPayment(
        paymentMethod: 'card',
        reference: _cardRefController.text,
      );
    } else {
      return await controller.processPayment(
        paymentMethod: 'qris',
        reference: 'QRIS-${DateTime.now().millisecondsSinceEpoch}',
      );
    }
  }
}

class _QuickAmountButton extends StatelessWidget {
  final double amount;
  final String label;
  final VoidCallback onTap;

  const _QuickAmountButton({
    required this.amount,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.primary.withOpacity(0.3)),
        ),
        child: Text(
          label,
          style: AppTypography.heading3.copyWith(color: AppColors.primary),
        ),
      ),
    );
  }
}
