import 'package:flutter/material.dart';
import '../../../../core/theme/design_system.dart';
import '../../../orders/domain/order_entity.dart';
import 'package:intl/intl.dart';

class PaymentSuccessDialog extends StatefulWidget {
  final Order order;
  final double change;

  const PaymentSuccessDialog({
    super.key,
    required this.order,
    required this.change,
  });

  @override
  State<PaymentSuccessDialog> createState() => _PaymentSuccessDialogState();
}

class _PaymentSuccessDialogState extends State<PaymentSuccessDialog> {
  bool _isPrinting = true;

  @override
  void initState() {
    super.initState();
    // Simulate printing delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isPrinting = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isPrinting) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text('Mencetak Struk...', style: AppTypography.bodyMedium),
            ],
          ),
        ),
      );
    }

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0),
      ), // Sharp edges for receipt look
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Success Header
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.green,
                        size: 32,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Center(
                    child: Text(
                      'Pembayaran Berhasil',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.green,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Receipt Content
                  Center(
                    child: Image.asset(
                      'assets/images/logo.png',
                      height: 40,
                      errorBuilder: (c, e, s) =>
                          const Icon(Icons.restaurant, size: 40),
                    ),
                  ), // Placeholder logo
                  const SizedBox(height: 8),
                  const Center(
                    child: Text(
                      'NUSANTARA RESTO',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const Center(
                    child: Text(
                      'Jl. Merdeka No. 45, Jakarta',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildLine(),
                  const SizedBox(height: 12),
                  _buildRow('No. Order', '#${widget.order.queueNumber}'),
                  _buildRow(
                    'Tanggal',
                    DateFormat(
                      'dd/MM/yyyy HH:mm',
                    ).format(widget.order.paidAt ?? DateTime.now()),
                  ),
                  _buildRow(
                    'Kasir',
                    'Admin',
                  ), // In a real app, get from auth state
                  _buildRow(
                    'Metode',
                    _formatPaymentMethod(widget.order.paymentMethod),
                  ),
                  const SizedBox(height: 12),
                  _buildLine(),
                  const SizedBox(height: 12),

                  // Items
                  ...widget.order.items
                      .map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${item.quantity}x',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(child: Text(item.product.name)),
                              Text(
                                NumberFormat.currency(
                                  locale: 'id_ID',
                                  symbol: '',
                                  decimalDigits: 0,
                                ).format(item.product.price * item.quantity),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),

                  const SizedBox(height: 12),
                  _buildLine(),
                  const SizedBox(height: 12),
                  _buildRow('Subtotal', _formatCurrency(widget.order.subtotal)),
                  _buildRow('Pajak (11%)', _formatCurrency(widget.order.tax)),
                  const SizedBox(height: 8),
                  _buildLine(isDashed: false),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'TOTAL',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        _formatCurrency(widget.order.totalPrice),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildRow(
                    'Bayar',
                    _formatCurrency(widget.order.totalPrice + widget.change),
                  ),
                  _buildRow('Kembali', _formatCurrency(widget.change)),
                  const SizedBox(height: 24),
                  const Center(
                    child: Text(
                      'Terima Kasih!',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Center(
                    child: Text(
                      'Simpan struk ini sebagai bukti pembayaran',
                      style: TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
            // Jagged Edge Effect
            Container(
              height: 10,
              color: Colors.transparent,
              child: CustomPaint(
                painter: JaggedEdgePainter(color: Colors.white),
                size: const Size(double.infinity, 10),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Mencetak ulang struk...')),
                    );
                  },
                  icon: const Icon(Icons.print),
                  label: const Text('Cetak'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Tutup'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLine({bool isDashed = true}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final dashWidth = 5.0;
        final dashCount = (constraints.maxWidth / (2 * dashWidth)).floor();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(color: Colors.grey[300]),
              ),
            );
          }),
        );
      },
    );
  }

  String _formatCurrency(double value) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(value);
  }

  String _formatPaymentMethod(String? method) {
    switch (method) {
      case 'cash':
        return 'TUNAI';
      case 'qris':
        return 'QRIS';
      case 'card':
        return 'KARTU';
      default:
        return 'LAINNYA';
    }
  }
}

class JaggedEdgePainter extends CustomPainter {
  final Color color;

  JaggedEdgePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path();

    path.moveTo(0, 0);

    final count = 20;
    final w = size.width / count;

    for (int i = 0; i < count; i++) {
      path.lineTo((i * w) + w / 2, size.height);
      path.lineTo((i + 1) * w, 0);
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
