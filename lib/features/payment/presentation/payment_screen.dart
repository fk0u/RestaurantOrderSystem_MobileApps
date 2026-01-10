import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../cart/presentation/cart_controller.dart';
import 'package:uuid/uuid.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../orders/data/order_repository.dart';
import '../../orders/domain/order_entity.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  const PaymentScreen({super.key});

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  String _selectedMethod = 'qris'; // 'qris' or 'cash'
  bool _isProcessing = false;

  void _processPayment() async {
    setState(() => _isProcessing = true);
    
    // Simulate Network/Processing
    await Future.delayed(const Duration(seconds: 2)); 
    
    if (!mounted) return;

    final user = ref.read(authControllerProvider).value;
    final cartItems = ref.read(cartControllerProvider);
    final total = ref.read(cartTotalProvider);
    final orderId = 'ORD-${const Uuid().v4().substring(0, 8).toUpperCase()}';

    // Create Order Object
    final order = Order(
      id: orderId,
      userId: user?.id ?? 'guest',
      userName: user?.name ?? 'Guest',
      totalPrice: total,
      status: 'Sedang Diproses', // Initial Status
      timestamp: DateTime.now(),
      items: cartItems,
    );

    // Save to SQLite
    try {
      await ref.read(orderRepositoryProvider).createOrder(order);
      
      // Clear Cart
      ref.read(cartControllerProvider.notifier).clearCart();
      
      // Show Receipt Dialog
      if (!mounted) return;
      _showReceiptDialog(context, orderId);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _showReceiptDialog(BuildContext context, String orderId) {
    showDialog(
      context: context,
      barrierDismissible: false, // Must tap button to close
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)), // Thermal print style (boxy)
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
               const SizedBox(height: 24),
               const Icon(Icons.receipt_long, size: 48, color: Colors.black87),
               const SizedBox(height: 16),
               const Text('RESTO NUSANTARA', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
               const Text('Jl. Sudirman No. 1, Jakarta', style: TextStyle(fontSize: 12, color: Colors.grey)),
               const Divider(),
               Padding(
                 padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                 child: Column(
                   children: [
                     _buildReceiptRow('Order ID', orderId),
                     _buildReceiptRow('Tanggal', DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())),
                   ],
                 ),
               ),
               const Divider(), // Dashed line simulation ideally
               const SizedBox(height: 8),
               // We need to look up the order or just use current cart state (since we cleared cart, we rely on context or pass data)
               // However, we just cleared the cart in _processPayment. 
               // For this demo, simply show the Success state. Real receipt needs data passed.
               const Text('PEMBAYARAN BERHASIL', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
                     style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white),
                     child: const Text('Tutup'),
                   ),
                 ),
               )
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
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = ref.watch(cartTotalProvider);
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    // Mock QRIS String
    final qrisData = "00020101021126570014ID.GO.GOPAY.SHORT123456789${const Uuid().v4()}";

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Pembayaran', style: TextStyle(fontWeight: FontWeight.bold)),
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
                 boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10))],
               ),
               child: Column(
                 children: [
                   const Text('Total Tagihan', style: TextStyle(color: Colors.white70)),
                   const SizedBox(height: 8),
                   Text(
                     currencyFormatter.format(total),
                     style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                   ),
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
                    _buildSummaryRow('Subtotal', ref.watch(cartSubtotalProvider), currencyFormatter),
                    _buildSummaryRow('Pajak (11%)', ref.watch(cartTaxProvider), currencyFormatter),
                    _buildSummaryRow('Service Charge (5%)', ref.watch(cartServiceFeeProvider), currencyFormatter),
                    const Divider(height: 24),
                    _buildSummaryRow('Total', total, currencyFormatter, isTotal: true),
                  ],
               ),
             ),

             const SizedBox(height: 32),
             
             // Payment Methods
             const Align(alignment: Alignment.centerLeft, child: Text('Pilih Metode Pembayaran', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
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
                     decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                     child: QrImageView(
                       data: qrisData,
                       version: QrVersions.auto,
                       size: 200.0,
                     ),
                   ),
                   const SizedBox(height: 16),
                   const Text('Pindai kode QR di atas untuk membayar', style: TextStyle(color: Colors.grey)),
                 ],
               ),

              if (_selectedMethod == 'cash')
                Container(
                   padding: const EdgeInsets.all(24),
                   decoration: BoxDecoration(color: AppColors.warning.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
                   child: const Row(
                     children: [
                       Icon(Icons.info_outline, color: AppColors.warning),
                       SizedBox(width: 16),
                       Expanded(child: Text('Silakan menuju kasir untuk melakukan pembayaran tunai.', style: TextStyle(color: AppColors.warning))),
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
              : Text(_selectedMethod == 'qris' ? 'Saya Sudah Membayar' : 'Konfirmasi Pesanan'),
          ),
        ),
      ),
    );
  }

  Widget _buildMethodCard({required String id, required String title, required String subtitle, required IconData icon}) {
    final isSelected = _selectedMethod == id;
    
    return InkWell(
      onTap: () => setState(() => _selectedMethod = id),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? AppColors.primary : Colors.transparent, width: 2),
          boxShadow: isSelected ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.1), blurRadius: 10)] : [],
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? AppColors.primary : Colors.grey, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isSelected ? AppColors.textPrimary : Colors.grey)),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
            if (isSelected) const Icon(Icons.check_circle, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
  Widget _buildSummaryRow(String label, double value, NumberFormat formatter, {bool isTotal = false}) {
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
              color: isTotal ? Colors.black : Colors.grey[600]
            ),
          ),
          Text(
            formatter.format(value),
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
               color: isTotal ? AppColors.primary : Colors.grey[800]
            ),
          ),
        ],
      ),
    );
  }
}
