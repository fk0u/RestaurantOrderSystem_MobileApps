import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/product_entity.dart';
import '../../../core/services/mock_service.dart';
// import '../../../core/services/api_client.dart';

final menuRepositoryProvider = Provider<MenuRepository>((ref) {
  return MenuRepository();
});

class MenuRepository {
  // final ApiClient _api;
  final MockService _mockService = MockService();

  MenuRepository();

  Future<List<Product>> getProducts() async {
    // final data = await _api.getList('/products');
    return _mockService.getProducts();
  }

  // Optional: Add Search
  Future<List<Product>> searchProducts(String query) async {
    final products = await getProducts();
    return products.where((p) {
      final q = query.toLowerCase();
      return p.name.toLowerCase().contains(q) ||
          p.category.toLowerCase().contains(q);
    }).toList();
  }
}
