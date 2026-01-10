import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/product_entity.dart';
import '../data/menu_repository.dart';

final menuControllerProvider = StateNotifierProvider<MenuController, AsyncValue<List<Product>>>((ref) {
  final repository = MenuRepository(); // Now uses SQLite internally
  return MenuController(repository);
});

class MenuController extends StateNotifier<AsyncValue<List<Product>>> {
  final MenuRepository _repository;
  List<Product> _allProducts = [];

  MenuController(this._repository) : super(const AsyncValue.loading()) {
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    state = const AsyncValue.loading();
    try {
      _allProducts = await _repository.getProducts();
      state = AsyncValue.data(_allProducts);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void filterByCategory(String category) {
    if (category == 'All') {
      state = AsyncValue.data(_allProducts);
    } else {
      final filtered = _allProducts.where((p) => p.category == category).toList();
      state = AsyncValue.data(filtered);
    }
  }
}
