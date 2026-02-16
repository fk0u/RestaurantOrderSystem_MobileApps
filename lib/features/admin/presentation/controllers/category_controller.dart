import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:restaurant_order_system/features/menu/data/menu_repository.dart';
import 'package:restaurant_order_system/features/menu/domain/category_entity.dart';

import '../../../../core/di/injection_container.dart';

final categoryControllerProvider =
    StateNotifierProvider.autoDispose<
      CategoryController,
      AsyncValue<List<Category>>
    >((ref) {
      return CategoryController(sl<MenuRepository>());
    });

class CategoryController extends StateNotifier<AsyncValue<List<Category>>> {
  final MenuRepository _repository;

  CategoryController(this._repository) : super(const AsyncValue.loading()) {
    getCategories();
  }

  Future<void> getCategories() async {
    try {
      state = const AsyncValue.loading();
      final data = await _repository.getCategories();
      final categories = data.map((json) => Category.fromJson(json)).toList();
      state = AsyncValue.data(categories);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addCategory(String name, String description) async {
    await _repository.createCategory(name, description);
    await getCategories();
  }

  Future<void> updateCategory(int id, String name, String description) async {
    await _repository.updateCategory(id, name, description);
    await getCategories();
  }

  Future<void> deleteCategory(int id) async {
    await _repository.deleteCategory(id);
    await getCategories();
  }
}
