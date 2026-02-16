import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:intl/intl.dart';
import 'package:restaurant_order_system/core/theme/design_system.dart';
import 'package:uuid/uuid.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../cart/presentation/bloc/cart_bloc.dart';
import '../../cart/presentation/bloc/cart_event.dart';
import '../../cart/presentation/bloc/cart_state.dart';
import '../../orders/presentation/bloc/order_bloc.dart';
import '../../orders/presentation/bloc/order_event.dart';
import '../../orders/presentation/bloc/order_state.dart';
import '../../orders/domain/order_entity.dart';
import '../../tables/data/table_repository.dart';
import '../../tables/domain/table_entity.dart';
import '../../promotions/data/promotion_repository.dart';
import '../../promotions/data/promotion_model.dart';
import '../../orders/presentation/order_type_provider.dart';
import '../../tables/presentation/table_controller.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  const PaymentScreen({super.key});

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  String _selectedMethod = 'qris'; // 'qris' or 'cash'
  bool _isProcessing = false;
  final TextEditingController _promoController = TextEditingController();
  Promotion? _promo;
  double _discountValue = 0;
  String? _promoError;
  bool _isApplyingPromo = false;

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  Future<void> _applyPromo(double subtotal) async {
    final code = _promoController.text.trim();
    if (code.isEmpty) return;

    setState(() {
      _isApplyingPromo = true;
      _promoError = null;
    });

    try {
      final promo = await PromotionRepository().getByCode(code);
      if (promo == null) {
        setState(() {
          _promoError = 'Kode promo tidak ditemukan';
          _promo = null;
          _discountValue = 0;
        });
        return;
      }

      if (promo.minOrder > 0 && subtotal < promo.minOrder) {
        setState(() {
          _promoError = 'Minimum order belum terpenuhi';
          _promo = null;
          _discountValue = 0;
        });
        return;
      }

      final now = DateTime.now();
      if (promo.startsAt != null && now.isBefore(promo.startsAt!)) {
        setState(() {
          _promoError = 'Promo belum berlaku';
          _promo = null;
          _discountValue = 0;
        });
        return;
      }
      if (promo.endsAt != null && now.isAfter(promo.endsAt!)) {
        setState(() {
          _promoError = 'Promo sudah berakhir';
          _promo = null;
          _discountValue = 0;
        });
        return;
      }

      double discount = 0;
      if (promo.type == 'percent') {
        discount = subtotal * (promo.value / 100);
      } else {
        discount = promo.value;
      }
      if (promo.maxDiscount != null && discount > promo.maxDiscount!) {
        discount = promo.maxDiscount!;
      }

      setState(() {
        _promo = promo;
        _discountValue = discount;
        _promoError = null;
      });
    } finally {
      if (mounted) {
        setState(() => _isApplyingPromo = false);
      }
    }
  }

  void _clearPromo() {
    setState(() {
      _promo = null;
      _discountValue = 0;
      _promoError = null;
      _promoController.clear();
    });
  }

  void _processPayment() async {
    final details = await _collectOrderDetails();
    if (details == null) return;
    if (!mounted) return;

    // Get current cart state
    final cartState = context.read<CartBloc>().state;
    if (cartState is! CartLoaded || cartState.items.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Keranjang kosong')));
      }
      return;
    }

    // No setState _isProcessing = true here, handled by BlocListener/State
    // But for UI feedback, BlocListener is better.

    final user = ref.read(authControllerProvider).value;

    final cartItems = cartState.items;
    final subtotal = cartState.subtotal;
    final tax = cartState.tax;
    final service = cartState.serviceFee;

    final total = (subtotal + tax + service - _discountValue)
        .clamp(0, double.infinity)
        .toDouble();
    final orderId = 'ORD-${const Uuid().v4().substring(0, 8).toUpperCase()}';

    // Create Order Object
    final order = Order(
      id: orderId,
      userId: user?.id ?? 'guest',
      userName: details.customerName,
      totalPrice: total,
      status: 'Menunggu Pembayaran', // Wait for payment before processing
      promoCode: _promo?.code,
      discount: _discountValue,
      timestamp: DateTime.now(),
      orderType: details.orderType,
      tableId: details.table?.id,
      tableNumber: details.table?.number,
      tableCapacity: details.table?.capacity,
      queueNumber: 0,
      readyAt: null,
      items: cartItems,
    );

    context.read<OrderBloc>().add(
      PlaceOrder(order: order, paymentMethod: _selectedMethod),
    );
  }

  Future<_OrderDetails?> _collectOrderDetails() async {
    final user = ref.read(authControllerProvider).value;
    final nameController = TextEditingController(text: user?.name ?? '');

    // Pre-fill from providers
    final initialOrderType = ref.read(orderTypeProvider);
    String orderType = initialOrderType.value; // 'dine_in', 'takeaway', etc.

    final initialTable = ref.read(selectedTableProvider);
    RestaurantTable? selectedTable = initialTable;

    // Reset table if not dine_in
    if (initialOrderType != OrderType.dineIn) {
      selectedTable = null;
    }

    final tablesFuture = ref.read(tableRepositoryProvider).getTables();

    return showModalBottomSheet<_OrderDetails>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final isNameValid = nameController.text.trim().isNotEmpty;
            final isTableValid =
                orderType == 'takeaway' ||
                orderType == 'delivery' ||
                selectedTable !=
                    null; // delivery treated as takeaway logic for now
            // Or if delivery, we might need address. For now treat as 'takeaway' (no table)

            final canSubmit = isNameValid && isTableValid;

            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Detail Transaksi',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nama Pemesan',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (_) => setModalState(() {}),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Tipe Pesanan',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  RadioListTile<String>(
                    value: 'dine_in',
                    groupValue: orderType,
                    title: const Text('Makan di Tempat'),
                    onChanged: (value) {
                      setModalState(() {
                        orderType = value!;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    value: 'takeaway',
                    groupValue: orderType,
                    title: const Text('Bawa Pulang'),
                    onChanged: (value) {
                      setModalState(() {
                        orderType = value!;
                        selectedTable = null;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    value: 'delivery',
                    groupValue: orderType,
                    title: const Text('Delivery'),
                    onChanged: (value) {
                      setModalState(() {
                        orderType = value!;
                        selectedTable = null;
                      });
                    },
                  ),
                  if (orderType == 'dine_in') ...[
                    const SizedBox(height: 8),
                    FutureBuilder<List<RestaurantTable>>(
                      future: tablesFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: LinearProgressIndicator(),
                          );
                        }
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Text('Tidak ada data meja.');
                        }

                        final availableTables = snapshot.data!
                            .where((t) => t.status == 'available')
                            .toList();

                        if (availableTables.isEmpty) {
                          return const Text(
                            'Tidak ada meja tersedia saat ini.',
                          );
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            DropdownButtonFormField<RestaurantTable>(
                              value: selectedTable,
                              items: availableTables
                                  .map(
                                    (t) => DropdownMenuItem(
                                      value: t,
                                      child: Text(
                                        '${t.number} • ${t.capacity} orang',
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                setModalState(() => selectedTable = value);
                              },
                              decoration: const InputDecoration(
                                labelText: 'Pilih Meja',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            if (selectedTable != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                'Kapasitas meja: ${selectedTable!.capacity} orang',
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ],
                        );
                      },
                    ),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => context.pop(),
                          child: const Text('Batal'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: canSubmit
                              ? () {
                                  context.pop(
                                    _OrderDetails(
                                      customerName: nameController.text.trim(),
                                      orderType: orderType,
                                      table: selectedTable,
                                    ),
                                  );
                                }
                              : null,
                          child: const Text('Lanjutkan'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showReceiptDialog(BuildContext context, Order order) {
    showDialog(
      context: context,
      barrierDismissible: false, // Must tap button to close
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0),
        ), // Thermal print style (boxy)
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 24),
              const Icon(Icons.receipt_long, size: 48, color: Colors.black87),
              const SizedBox(height: 16),
              const Text(
                'RESTO NUSANTARA',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const Text(
                'Jl. Sudirman No. 1, Jakarta',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                child: Column(
                  children: [
                    _buildReceiptRow('Order ID', order.id),
                    _buildReceiptRow('Nama', order.userName),
                    _buildReceiptRow(
                      'Tipe',
                      order.orderType == 'dine_in' ? 'Dine In' : 'Takeaway',
                    ),
                    if (order.orderType == 'dine_in' &&
                        order.tableNumber != null)
                      _buildReceiptRow('Meja', order.tableNumber!),
                    if (order.orderType == 'dine_in' &&
                        order.tableCapacity != null)
                      _buildReceiptRow(
                        'Kapasitas',
                        '${order.tableCapacity} orang',
                      ),
                    if (order.promoCode != null)
                      _buildReceiptRow('Promo', order.promoCode!),
                    if (order.discount > 0)
                      _buildReceiptRow(
                        'Diskon',
                        '-${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(order.discount)}',
                      ),
                    _buildReceiptRow('No. Antrian', '#${order.queueNumber}'),
                    _buildReceiptRow(
                      'Perkiraan Siap',
                      DateFormat(
                        'HH:mm',
                      ).format(order.readyAt ?? DateTime.now()),
                    ),
                    _buildReceiptRow(
                      'Tanggal',
                      DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now()),
                    ),
                  ],
                ),
              ),
              const Divider(), // Dashed line simulation ideally
              const SizedBox(height: 8),
              // We need to look up the order or just use current cart state (since we cleared cart, we rely on context or pass data)
              // However, we just cleared the cart in _processPayment.
              // For this demo, simply show the Success state. Real receipt needs data passed.
              const Text(
                'PEMBAYARAN BERHASIL',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 16),

              Padding(
                padding: const EdgeInsets.all(24.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      context.pop();
                      context.go('/menu');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Tutup'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12)),
          Text(
            value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OrderBloc, OrderState>(
      listener: (context, state) {
        if (state is OrderLoading) {
          setState(() => _isProcessing = true);
        } else if (state is OrderOperationSuccess) {
          setState(() => _isProcessing = false);
          // Clear Cart
          context.read<CartBloc>().add(ClearCart());
          // Show Receipt
          _showReceiptDialog(context, state.order);
        } else if (state is OrderError) {
          setState(() => _isProcessing = false);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: ${state.message}')));
        }
      },
      child: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          double subtotal = 0;
          double tax = 0;
          double service = 0;
          double total = 0;

          if (state is CartLoaded) {
            subtotal = state.subtotal;
            tax = state.tax;
            service = state.serviceFee;
          }

          total = (subtotal + tax + service - _discountValue)
              .clamp(0, double.infinity)
              .toDouble();

          final currencyFormatter = NumberFormat.currency(
            locale: 'id_ID',
            symbol: 'Rp ',
            decimalDigits: 0,
          );

          // Mock QRIS String
          final qrisData =
              "00020101021126570014ID.GO.GOPAY.SHORT123456789${const Uuid().v4()}";

          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              title: const Text(
                'Pembayaran',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              backgroundColor: Colors.white,
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Total Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Total Tagihan',
                          style: TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          currencyFormatter.format(total),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Promo Code
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Gunakan Promo',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _promoController,
                                decoration: InputDecoration(
                                  hintText: 'Masukkan kode promo',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton(
                              onPressed: _isApplyingPromo
                                  ? null
                                  : () => _applyPromo(subtotal),
                              child: _isApplyingPromo
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text('Pakai'),
                            ),
                          ],
                        ),
                        if (_promoError != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            _promoError!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        ],
                        if (_promo != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Promo: ${_promo!.title}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.green,
                                ),
                              ),
                              TextButton(
                                onPressed: _clearPromo,
                                child: const Text('Hapus'),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Payment Breakdown
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        _buildSummaryRow(
                          'Subtotal',
                          subtotal,
                          currencyFormatter,
                        ),
                        _buildSummaryRow('Pajak (11%)', tax, currencyFormatter),
                        _buildSummaryRow(
                          'Service Charge (5%)',
                          service,
                          currencyFormatter,
                        ),
                        if (_discountValue > 0)
                          _buildSummaryRow(
                            'Diskon',
                            -_discountValue,
                            currencyFormatter,
                          ),
                        const Divider(height: 24),
                        _buildSummaryRow(
                          'Total',
                          total,
                          currencyFormatter,
                          isTotal: true,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Payment Methods
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Pilih Metode Pembayaran',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildMethodCard(
                    id: 'qris',
                    title: 'QRIS',
                    subtitle: 'Scan dengan GoPay, OVO, Dana',
                    icon: Icons.qr_code_scanner,
                  ),
                  const SizedBox(height: 16),
                  _buildMethodCard(
                    id: 'cash',
                    title: 'Tunai / Kasir',
                    subtitle: 'Bayar langsung di kasir',
                    icon: Icons.money,
                  ),

                  const SizedBox(height: 32),

                  // QR Display or Info
                  if (_selectedMethod == 'qris')
                    Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: QrImageView(
                            data: qrisData,
                            version: QrVersions.auto,
                            size: 200.0,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Pindai kode QR di atas untuk membayar',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),

                  if (_selectedMethod == 'cash')
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline, color: AppColors.warning),
                          SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              'Silakan menuju kasir untuk melakukan pembayaran tunai.',
                              style: TextStyle(color: AppColors.warning),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            bottomNavigationBar: Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(color: Colors.white),
              child: SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _processPayment,
                  child: _isProcessing
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          _selectedMethod == 'qris'
                              ? 'Saya Sudah Membayar'
                              : 'Konfirmasi Pesanan',
                        ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMethodCard({
    required String id,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final isSelected = _selectedMethod == id;

    return InkWell(
      onTap: () => setState(() => _selectedMethod = id),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    blurRadius: 10,
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : Colors.grey,
              size: 32,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isSelected ? AppColors.textPrimary : Colors.grey,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppColors.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    double value,
    NumberFormat formatter, {
    bool isTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.black : Colors.grey[600],
            ),
          ),
          Text(
            formatter.format(value),
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? AppColors.primary : Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderDetails {
  final String customerName;
  final String orderType;
  final RestaurantTable? table;

  _OrderDetails({
    required this.customerName,
    required this.orderType,
    required this.table,
  });
}
