import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/design_system.dart';
import '../../menu/domain/product_entity.dart';
import '../../cart/presentation/cart_controller.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  int _quantity = 1;
  final List<String> _selectedModifiers = [];
  final TextEditingController _noteController = TextEditingController();

  // Mock Modifiers (In real app, these would come from the product model)
  final List<String> _availableModifiers = [
    'Extra Pedas',
    'Tanpa Es',
    'Extra Keju (+Rp 2.000)',
    'Bungkus Terpisah',
    'Sedikit Gula',
    'Hangat'
  ];

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _toggleModifier(String modifier) {
    setState(() {
      if (_selectedModifiers.contains(modifier)) {
        _selectedModifiers.remove(modifier);
      } else {
        _selectedModifiers.add(modifier);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    
    // Calculate total including modifiers (mock pricing)
    // Assuming 'Extra Keju' adds cost for logic demo, but simplistic for now
    double totalPrice = widget.product.price * _quantity;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background Image
          Positioned(
            top: 0, left: 0, right: 0,
            height: 300,
            child: Image.network(
              widget.product.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (c, e, s) => Container(color: Colors.grey[300]),
            ),
          ),
          // Back Button & Favorite
          Positioned(
            top: 40, left: 20, right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white,
                  child: BackButton(color: Colors.black, onPressed: () => context.pop()),
                ),
                const CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.favorite_border, color: Colors.red),
                ),
              ],
            ),
          ),
          
          // Content
          Positioned.fill(
            top: 250,
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Column(
                children: [
                   Expanded(
                     child: ListView(
                       padding: const EdgeInsets.all(AppDimens.s21),
                       children: [
                         // Handle
                         Center(
                           child: Container(
                             width: 40, height: 4,
                             margin: const EdgeInsets.only(bottom: 20),
                             decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                           ),
                         ),
                         // Title & Price
                         Row(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                             Expanded(
                               child: Text(
                                 widget.product.name,
                                 style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                               ),
                             ),
                             Text(
                               currencyFormatter.format(widget.product.price),
                               style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary),
                             ),
                           ],
                         ),
                         const SizedBox(height: 8),
                         Row(
                           children: [
                             const Icon(Icons.local_fire_department, size: 16, color: Colors.orange),
                             const SizedBox(width: 4),
                             Text('${widget.product.calories} kkal', style: TextStyle(color: Colors.grey[600])),
                             const SizedBox(width: 16),
                             const Icon(Icons.star, size: 16, color: Colors.amber),
                             const SizedBox(width: 4),
                             Text('4.8 (120+)', style: TextStyle(color: Colors.grey[600])),
                           ],
                         ),
                         const SizedBox(height: 24),
                         
                         // Description
                         const Text('Deskripsi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                         const SizedBox(height: 8),
                         Text(
                           widget.product.description,
                           style: TextStyle(color: Colors.grey[600], height: 1.5),
                         ),
                         
                         const SizedBox(height: 24),
                         const Divider(),
                         const SizedBox(height: 16),

                         // Modifiers
                         const Text('Kustomisasi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                         const SizedBox(height: 8),
                         Wrap(
                           spacing: 8,
                           runSpacing: 8,
                           children: _availableModifiers.map((mod) {
                             final isSelected = _selectedModifiers.contains(mod);
                             return ChoiceChip(
                               label: Text(mod),
                               selected: isSelected,
                               selectedColor: AppColors.primary.withValues(alpha: 0.2),
                               onSelected: (_) => _toggleModifier(mod),
                               labelStyle: TextStyle(
                                 color: isSelected ? AppColors.primary : Colors.black87,
                                 fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
                               ),
                               backgroundColor: Colors.white,
                               side: isSelected ? const BorderSide(color: AppColors.primary) : BorderSide.none,
                               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                             );
                           }).toList(),
                         ),

                         const SizedBox(height: 24),
                         
                         // Note
                         const Text('Catatan Pesanan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                         const SizedBox(height: 8),
                         TextField(
                           controller: _noteController,
                           decoration: InputDecoration(
                             hintText: 'Tulis catatan disini (opsional)...',
                             filled: true,
                             fillColor: Colors.white,
                             border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                             prefixIcon: const Icon(Icons.edit_note, color: Colors.grey),
                           ),
                           maxLines: 2,
                         ),
                         
                         const SizedBox(height: 16),
                         
                         // Stock Indicator
                         Row(
                           children: [
                              Icon(
                                widget.product.stock > 0 ? Icons.check_circle : Icons.cancel,
                                color: widget.product.stock > 0 ? AppColors.success : Colors.red,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                widget.product.stock > 0 ? 'Stok Tersedia: ${widget.product.stock}' : 'Stok Habis',
                                style: TextStyle(
                                  color: widget.product.stock > 0 ? AppColors.success : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                           ],
                         ),

                         const SizedBox(height: 100), // Space for bottom bar
                       ],
                     ),
                   ),
                ],
              ),
            ),
          ),
          
          // Bottom Bar
          Positioned(
            left: 0, right: 0, bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, -5))],
              ),
              child: Row(
                children: [
                  // Qty Selector
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                          icon: const Icon(Icons.remove),
                          iconSize: 18,
                        ),
                        Text('$_quantity', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        IconButton(
                          onPressed: _quantity < widget.product.stock ? () => setState(() => _quantity++) : null,
                          icon: const Icon(Icons.add),
                          iconSize: 18,
                          color: _quantity >= widget.product.stock ? Colors.grey : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Add Button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: widget.product.stock > 0 
                        ? () {
                           ref.read(cartControllerProvider.notifier).addItem(
                             widget.product,
                             quantity: _quantity,
                             note: _noteController.text.isNotEmpty ? _noteController.text : null,
                             modifiers: List.from(_selectedModifiers),
                           );
                           context.pop(); // Close sheet/screen
                           ScaffoldMessenger.of(context).showSnackBar(
                             SnackBar(content: Text('${widget.product.name} ditambahkan'), duration: const Duration(milliseconds: 800))
                           );
                        }
                        : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                        disabledBackgroundColor: Colors.grey[300],
                      ),
                      child: Text(
                        widget.product.stock > 0 ? 'Tambah - ${currencyFormatter.format(totalPrice)}' : 'Stok Habis',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
