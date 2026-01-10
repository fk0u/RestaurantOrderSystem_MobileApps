import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../cart/presentation/cart_controller.dart';
import '../../../../core/constants/app_colors.dart';
import 'menu_controller.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/design_system.dart';

class MenuScreen extends ConsumerWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final menuState = ref.watch(menuControllerProvider);
    final cartItems = ref.watch(cartControllerProvider);
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    // Filter Logic
    final selectedCategory = ref.watch(selectedCategoryProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                   Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                   ),
                   const SizedBox(width: 16),
                   Expanded(
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Text(
                           'Daftar Menu',
                           style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                         ),
                         const Text(
                           'Pesanan #34619', // Mock Order ID
                           style: TextStyle(color: AppColors.textSecondary),
                         ),
                       ],
                     ),
                   ),
                   const SizedBox(width: 8),
                   // Status Badge (Mock)
                   Container(
                     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                     decoration: BoxDecoration(
                       color: AppColors.primary,
                       borderRadius: BorderRadius.circular(20),
                     ),
                     child: const Text(
                       'Meja 1',
                       style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                     ),
                   ),
                ],
              ),
            ),

            // Search Bar (Mock)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Cari makanan atau minuman...',
                  prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Categories
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  _buildCategoryChip(ref, 'Semua', 'all', selectedCategory),
                  const SizedBox(width: 12),
                  _buildCategoryChip(ref, 'Makanan Utama', 'makanan_utama', selectedCategory),
                  const SizedBox(width: 12),
                  _buildCategoryChip(ref, 'Minuman', 'minuman', selectedCategory),
                  const SizedBox(width: 12),
                  _buildCategoryChip(ref, 'Camilan', 'camilan', selectedCategory),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Product Grid
            Expanded(
              child: menuState.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('Terjadi kesalahan: $err')),
                data: (products) {
                  if (products.isEmpty) {
                    return const Center(child: Text('Tidak ada menu tersedia'));
                  }
                  return GridView.builder(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75, // Taller card
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      // Safe Quantity Check
                      int qty = 0;
                      try {
                        final found = cartItems.where((item) => item.product.id == product.id);
                        if (found.isNotEmpty) {
                          qty = found.first.quantity;
                        }
                      } catch (e) {
                        qty = 0;
                      }

                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(AppDimens.r24),
                          boxShadow: AppShadows.card,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Image
                            Expanded(
                              flex: 5,
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(AppDimens.r24)),
                                    child: Image.network(
                                      product.imageUrl,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder: (c, e, s) => Container(color: Colors.grey[200]),
                                    ),
                                  ),
                                  Positioned(
                                    top: 10, left: 10,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.6),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(children: [const Icon(Icons.local_fire_department, color: Colors.orange, size: 14), const SizedBox(width: 4), Text('${product.calories} kkal', style: const TextStyle(color: Colors.white, fontSize: 10))]),
                                    ),
                                  )
                                ],
                              ),
                            ),
                                  // Fav Button
                                  Positioned(
                                    top: 10,
                                    right: 10,
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.favorite_border, color: Colors.red, size: 18),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Info Section
                            Expanded(
                              flex: 4,
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      currencyFormatter.format(product.price),
                                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppColors.textPrimary),
                                    ),
                                    const Spacer(),
                                    // Add Button
                                    SizedBox(
                                      width: double.infinity,
                                      height: 36,
                                      child: qty > 0 
                                      ? Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            _buildQtyBtn(() => ref.read(cartControllerProvider.notifier).updateQuantity(product.id, qty - 1), Icons.remove),
                                            Text('$qty', style: const TextStyle(fontWeight: FontWeight.bold)),
                                            _buildQtyBtn(() => ref.read(cartControllerProvider.notifier).updateQuantity(product.id, qty + 1), Icons.add),
                                          ],
                                        )
                                      : ElevatedButton(
                                        onPressed: () {
                                           ref.read(cartControllerProvider.notifier).addItem(product);
                                           ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                           ScaffoldMessenger.of(context).showSnackBar(
                                             SnackBar(
                                               content: Text('${product.name} ditambahkan'),
                                               duration: const Duration(milliseconds: 500),
                                            )
                                           );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.background,
                                          foregroundColor: AppColors.textPrimary,
                                          elevation: 0,
                                          padding: EdgeInsets.zero,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        ),
                                        child: const Text('Tambah', style: TextStyle(fontSize: 12)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: cartItems.isNotEmpty ? FloatingActionButton.extended(
        onPressed: () => context.push('/cart'),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.shopping_bag_outlined, color: Colors.white),
        label: Text('${cartItems.length} Item  |  Lihat', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ) : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildCategoryChip(WidgetRef ref, String label, String id, String selectedId) {
    final isSelected = id == selectedId;
    return GestureDetector(
      onTap: () => ref.read(selectedCategoryProvider.notifier).state = id,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? Colors.transparent : Colors.grey[300]!),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildQtyBtn(VoidCallback onTap, IconData icon) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(color: AppColors.surfaceLight, borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, size: 16, color: AppColors.primary),
      ),
    );
  }
}

final selectedCategoryProvider = StateProvider<String>((ref) => 'all');
