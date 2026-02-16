import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:restaurant_order_system/features/menu/data/menu_repository.dart';
import 'package:restaurant_order_system/features/menu/domain/product_entity.dart';

import '../../../../core/di/injection_container.dart';

final productManagementControllerProvider =
    StateNotifierProvider.autoDispose<
      ProductManagementController,
      AsyncValue<List<Product>>
    >((ref) {
      return ProductManagementController(sl<MenuRepository>());
    });

class ProductManagementController
    extends StateNotifier<AsyncValue<List<Product>>> {
  final MenuRepository _repository;

  ProductManagementController(this._repository)
    : super(const AsyncValue.loading()) {
    getProducts();
  }

  Future<void> getProducts() async {
    try {
      state = const AsyncValue.loading();
      final products = await _repository.getProducts();
      state = AsyncValue.data(products);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addProduct(Product product) async {
    await _repository.createProduct(product);
    await getProducts();
  }

  Future<void> updateProduct(Product product) async {
    await _repository.updateProduct(product);
    await getProducts();
  }

  Future<void> deleteProduct(String id) async {
    await _repository.deleteProduct(id);
    await getProducts();
  }
}
