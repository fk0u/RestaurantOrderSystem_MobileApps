import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:restaurant_order_system/core/input/toaster.dart';
import 'package:restaurant_order_system/features/menu/domain/category_entity.dart';
import 'controllers/category_controller.dart';

class CategoryManagementScreen extends ConsumerWidget {
  const CategoryManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryState = ref.watch(categoryControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Manajemen Kategori')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCategoryDialog(context, ref),
        child: const Icon(Icons.add),
      ),
      body: categoryState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (categories) {
          if (categories.isEmpty) {
            return const Center(child: Text('Belum ada kategori'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: categories.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final category = categories[index];
              return ListTile(
                tileColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                title: Text(
                  category.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(category.description),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () =>
                          _showCategoryDialog(context, ref, category: category),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _confirmDelete(context, ref, category),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showCategoryDialog(
    BuildContext context,
    WidgetRef ref, {
    Category? category,
  }) {
    final nameController = TextEditingController(text: category?.name ?? '');
    final descController = TextEditingController(
      text: category?.description ?? '',
    );
    final isEditing = category != null;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Edit Kategori' : 'Tambah Kategori'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nama Kategori',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.label),
              ),
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
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                if (isEditing) {
                  await ref
                      .read(categoryControllerProvider.notifier)
                      .updateCategory(
                        category.id,
                        nameController.text,
                        descController.text,
                      );
                  if (context.mounted) {
                    Toaster.showSuccess(
                      context,
                      'Kategori berhasil diperbarui',
                    );
                  }
                } else {
                  await ref
                      .read(categoryControllerProvider.notifier)
                      .addCategory(nameController.text, descController.text);
                  if (context.mounted) {
                    Toaster.showSuccess(
                      context,
                      'Kategori berhasil ditambahkan',
                    );
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
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, Category category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Kategori'),
        content: Text(
          'Anda yakin ingin menghapus kategori "${category.name}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () async {
              try {
                await ref
                    .read(categoryControllerProvider.notifier)
                    .deleteCategory(category.id);
                if (context.mounted) {
                  Navigator.pop(context);
                  Toaster.showSuccess(context, 'Kategori berhasil dihapus');
                }
              } catch (e) {
                if (context.mounted) {
                  Toaster.showError(context, 'Gagal menghapus: $e');
                }
              }
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}
