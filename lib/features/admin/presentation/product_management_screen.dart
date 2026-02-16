import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:restaurant_order_system/core/input/toaster.dart';
import 'package:restaurant_order_system/features/menu/domain/product_entity.dart';
import 'package:restaurant_order_system/features/menu/domain/category_entity.dart';
import 'controllers/product_management_controller.dart';
import 'controllers/category_controller.dart';

class ProductManagementScreen extends ConsumerWidget {
  const ProductManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productState = ref.watch(productManagementControllerProvider);
    final categoryState = ref.watch(
      categoryControllerProvider,
    ); // Fetch categories for dropdown

    return Scaffold(
      appBar: AppBar(title: const Text('Manajemen Produk & Stok')),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            _showProductDialog(context, ref, null, categoryState.value ?? []),
        child: const Icon(Icons.add),
      ),
      body: productState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (products) {
          if (products.isEmpty) {
            return const Center(child: Text('Belum ada produk'));
          }
          final currencyFormatter = NumberFormat.currency(
            locale: 'id_ID',
            symbol: 'Rp ',
            decimalDigits: 0,
          );

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: products.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final product = products[index];
              final isLowStock = product.stock < 10;

              return ListTile(
                tileColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                leading: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: NetworkImage(product.imageUrl),
                      fit: BoxFit.cover,
                      onError: (_, __) => const Icon(Icons.image_not_supported),
                    ),
                  ),
                ),
                title: Text(
                  product.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(currencyFormatter.format(product.price)),
                    Text(product.category),
                    Row(
                      children: [
                        Text(
                          'Stok: ${product.stock}',
                          style: TextStyle(
                            color: isLowStock ? Colors.red : Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (!product.isAvailable)
                          const Chip(
                            label: Text(
                              'Tidak Tersedia',
                              style: TextStyle(fontSize: 10),
                            ),
                            backgroundColor: Colors.grey,
                            visualDensity: VisualDensity.compact,
                          ),
                      ],
                    ),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => _showProductDialog(
                    context,
                    ref,
                    product,
                    categoryState.value ?? [],
                  ),
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

    // Dropdown selection
    int? selectedCategoryId = product?.categoryId;
    if (selectedCategoryId == null && categories.isNotEmpty) {
      // If editing old product without categoryId, try to match by name or default to first
      // Ideally should be null check. We default to first for new products.
      if (product == null) selectedCategoryId = categories.first.id;
    }

    bool isAvailable = product?.isAvailable ?? true;
    final isEditing = product != null;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(isEditing ? 'Edit Produk' : 'Tambah Produk'),
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
                        activeTrackColor: Colors.green,
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
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  onPressed: () async {
                    // Confirm delete
                    await ref
                        .read(productManagementControllerProvider.notifier)
                        .deleteProduct(product.id);
                    if (context.mounted) {
                      Navigator.pop(context); // Close dialog
                      Toaster.showSuccess(context, 'Produk dihapus');
                    }
                  },
                  child: const Text('Hapus'),
                ),
              ElevatedButton(
                onPressed: () async {
                  if (selectedCategoryId == null) {
                    Toaster.showError(context, 'Pilih Kategori');
                    return;
                  }
                  try {
                    final newProduct = Product(
                      id:
                          product?.id ??
                          '', // ID handled by DB on create, but entity needs non-null.
                      // Actually for create, ID is ignored by Repo/API usually.
                      // But standard Entity is immutable.
                      name: nameController.text,
                      description: descController.text,
                      price: double.tryParse(priceController.text) ?? 0,
                      imageUrl: imageController.text,
                      category: categories
                          .firstWhere((c) => c.id == selectedCategoryId)
                          .name, // Fallback name
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
