import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:restaurant_order_system/core/input/toaster.dart';
import 'package:restaurant_order_system/features/menu/domain/product_entity.dart';
import 'package:restaurant_order_system/features/menu/domain/category_entity.dart';
import '../../../../core/theme/design_system.dart';
import 'controllers/product_management_controller.dart';
import 'controllers/category_controller.dart';

class ProductManagementScreen extends ConsumerWidget {
  const ProductManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productState = ref.watch(productManagementControllerProvider);
    final categoryState = ref.watch(categoryControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Manajemen Menu & Stok', style: AppTypography.heading3),
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            _showProductDialog(context, ref, null, categoryState.value ?? []),
        label: const Text('Tambah Produk'),
        icon: const Icon(Icons.add),
        backgroundColor: AppColors.primary,
      ),
      body: productState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (products) {
          if (products.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.fastfood_outlined,
                    size: 64,
                    color: AppColors.textHint,
                  ),
                  const SizedBox(height: AppDimens.s16),
                  Text('Belum ada produk', style: AppTypography.bodyMedium),
                ],
              ),
            );
          }
          final currencyFormatter = NumberFormat.currency(
            locale: 'id_ID',
            symbol: 'Rp ',
            decimalDigits: 0,
          );

          return ListView.separated(
            padding: const EdgeInsets.all(AppDimens.s16),
            itemCount: products.length,
            separatorBuilder: (context, index) =>
                const SizedBox(height: AppDimens.s16),
            itemBuilder: (context, index) {
              final product = products[index];
              return _ProductCard(
                product: product,
                currencyFormatter: currencyFormatter,
                onEdit: () => _showProductDialog(
                  context,
                  ref,
                  product,
                  categoryState.value ?? [],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showProductDialog(
    BuildContext context,
    WidgetRef ref,
    Product? product,
    List<Category> categories,
  ) {
    if (categories.isEmpty) {
      Toaster.showInfo(context, 'Harap buat Kategori terlebih dahulu');
      return;
    }

    final nameController = TextEditingController(text: product?.name ?? '');
    final priceController = TextEditingController(
      text: product?.price.toString() ?? '',
    );
    final stockController = TextEditingController(
      text: product?.stock.toString() ?? '',
    );
    final descController = TextEditingController(
      text: product?.description ?? '',
    );
    final imageController = TextEditingController(
      text: product?.imageUrl ?? '',
    );

    int? selectedCategoryId = product?.categoryId;
    if (selectedCategoryId == null && categories.isNotEmpty) {
      if (product == null) selectedCategoryId = categories.first.id;
    }

    bool isAvailable = product?.isAvailable ?? true;
    final isEditing = product != null;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(
              isEditing ? 'Edit Produk' : 'Tambah Produk',
              style: AppTypography.heading3,
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (imageController.text.isNotEmpty)
                      Container(
                        height: 150,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                          image: DecorationImage(
                            image: NetworkImage(imageController.text),
                            fit: BoxFit.cover,
                            onError: (_, __) =>
                                const Icon(Icons.image_not_supported, size: 50),
                          ),
                        ),
                      ),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nama Produk',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.fastfood),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: priceController,
                            decoration: const InputDecoration(
                              labelText: 'Harga',
                              prefixText: 'Rp ',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            controller: stockController,
                            decoration: const InputDecoration(
                              labelText: 'Stok',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      value: selectedCategoryId,
                      decoration: const InputDecoration(
                        labelText: 'Kategori',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.category),
                      ),
                      items: categories
                          .map(
                            (c) => DropdownMenuItem(
                              value: c.id,
                              child: Text(c.name),
                            ),
                          )
                          .toList(),
                      onChanged: (val) {
                        setState(() => selectedCategoryId = val);
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descController,
                      decoration: const InputDecoration(
                        labelText: 'Deskripsi',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: imageController,
                      decoration: const InputDecoration(
                        labelText: 'Image URL',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.link),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: SwitchListTile(
                        title: const Text('Tersedia'),
                        subtitle: const Text(
                          'Tampilkan produk di menu pelanggan',
                        ),
                        value: isAvailable,
                        activeTrackColor: AppColors.success,
                        onChanged: (val) => setState(() => isAvailable = val),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              if (isEditing)
                TextButton(
                  style: TextButton.styleFrom(foregroundColor: AppColors.error),
                  onPressed: () async {
                    await ref
                        .read(productManagementControllerProvider.notifier)
                        .deleteProduct(product.id);
                    if (context.mounted) {
                      Navigator.pop(context);
                      Toaster.showSuccess(context, 'Produk dihapus');
                    }
                  },
                  child: const Text('Hapus'),
                ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  if (selectedCategoryId == null) {
                    Toaster.showError(context, 'Pilih Kategori');
                    return;
                  }
                  try {
                    final newProduct = Product(
                      id: product?.id ?? '',
                      name: nameController.text,
                      description: descController.text,
                      price: double.tryParse(priceController.text) ?? 0,
                      imageUrl: imageController.text,
                      category: categories
                          .firstWhere((c) => c.id == selectedCategoryId)
                          .name,
                      stock: int.tryParse(stockController.text) ?? 0,
                      categoryId: selectedCategoryId,
                      isAvailable: isAvailable,
                    );

                    if (isEditing) {
                      await ref
                          .read(productManagementControllerProvider.notifier)
                          .updateProduct(newProduct);
                      if (context.mounted) {
                        Toaster.showSuccess(context, 'Produk diperbarui');
                      }
                    } else {
                      await ref
                          .read(productManagementControllerProvider.notifier)
                          .addProduct(newProduct);
                      if (context.mounted) {
                        Toaster.showSuccess(context, 'Produk ditambahkan');
                      }
                    }
                    if (context.mounted) Navigator.pop(context);
                  } catch (e) {
                    if (context.mounted) {
                      Toaster.showError(context, 'Gagal menyimpan: $e');
                    }
                  }
                },
                child: const Text('Simpan'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  final NumberFormat currencyFormatter;
  final VoidCallback onEdit;

  const _ProductCard({
    required this.product,
    required this.currencyFormatter,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final isLowStock = product.stock < 10;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.r12),
        boxShadow: AppShadows.card,
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppDimens.r12),
          onTap: onEdit,
          child: Padding(
            padding: const EdgeInsets.all(AppDimens.s12),
            child: Row(
              children: [
                // Image
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppDimens.r8),
                    color: Colors.grey.shade100,
                    image: DecorationImage(
                      image: NetworkImage(product.imageUrl),
                      fit: BoxFit.cover,
                      onError: (_, __) => const Icon(
                        Icons.image_not_supported,
                        size: 32,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppDimens.s16),
                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              product.name,
                              style: AppTypography.heading3.copyWith(
                                fontSize: 16,
                              ),
                            ),
                          ),
                          _buildStatusBadge(product.isAvailable),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product.category,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            currencyFormatter.format(product.price),
                            style: AppTypography.bodyLarge.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          _buildStockBadge(product.stock, isLowStock),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(bool isAvailable) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isAvailable
            ? AppColors.success.withValues(alpha: 0.1)
            : AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimens.r100),
      ),
      child: Text(
        isAvailable ? 'Aktif' : 'Non-Aktif',
        style: AppTypography.bodySmall.copyWith(
          color: isAvailable ? AppColors.success : AppColors.error,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStockBadge(int stock, bool isLowStock) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isLowStock
            ? Colors.orange.withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(AppDimens.r4),
        border: Border.all(
          color: isLowStock ? Colors.orange : AppColors.border,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 14,
            color: isLowStock ? Colors.orange : AppColors.textSecondary,
          ),
          const SizedBox(width: 4),
          Text(
            '$stock Stok',
            style: AppTypography.bodySmall.copyWith(
              color: isLowStock ? Colors.orange : AppColors.textSecondary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
