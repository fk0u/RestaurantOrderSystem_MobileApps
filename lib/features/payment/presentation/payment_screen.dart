import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../cart/presentation/cart_controller.dart';
import 'package:uuid/uuid.dart';

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
    await Future.delayed(const Duration(seconds: 2)); // Mock API
    
    if (!mounted) return;
    ref.read(cartControllerProvider.notifier).clearCart();
    
    // Show Success Dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle),
              child: const Icon(Icons.check, color: Colors.white, size: 40),
            ),
            const SizedBox(height: 24),
            const Text('Pembayaran Berhasil!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Pesanan Anda sedang disiapkan dapur.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              context.pop(); // Close dialog
              context.go('/onboarding'); // Reset flow for demo
            },
            child: const Text('Selesai', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
          ),
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

             // QR Display
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
}
