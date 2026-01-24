import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/product_entity.dart';
import '../../../core/services/api_client.dart';

final menuRepositoryProvider = Provider<MenuRepository>((ref) {
  return MenuRepository();
});

class MenuRepository {
  final ApiClient _api;

  MenuRepository({ApiClient? apiClient}) : _api = apiClient ?? ApiClient();

  Future<List<Product>> getProducts() async {
    final data = await _api.getList('/products');
    return data.map((item) {
      final map = item as Map<String, dynamic>;
      return Product(
        id: map['id'].toString(),
        name: map['name'] ?? '',
        description: map['description'] ?? '',
        price: (map['price'] as num?)?.toDouble() ?? 0,
        imageUrl: map['image_url'] ?? '',
        category: (map['category']?['name']) ?? '',
        calories: (map['calories'] as num?)?.toInt() ?? 0,
        stock: (map['stock'] as num?)?.toInt() ?? 0,
      );
    }).toList();
  }

  // Optional: Add Search
  Future<List<Product>> searchProducts(String query) async {
    final products = await getProducts();
    return products.where((p) {
      final q = query.toLowerCase();
      return p.name.toLowerCase().contains(q) || p.category.toLowerCase().contains(q);
    }).toList();
  }
}
