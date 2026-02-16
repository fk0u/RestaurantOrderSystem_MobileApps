import '../domain/product_entity.dart';

import '../../../../core/network/api_client.dart';

class MenuRepository {
  final ApiClient _apiClient;

  MenuRepository(this._apiClient);

  Future<List<Product>> getProducts() async {
    try {
      final response = await _apiClient.get('/products');
      return (response as List).map((e) => Product.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to load products: $e');
    }
  }

  // --- Products CRUD ---

  Future<void> createProduct(Product product) async {
    try {
      await _apiClient.post(
        '/products',
        body: {
          'name': product.name,
          'price': product.price,
          'imageUrl': product.imageUrl,
          'categoryId': product.categoryId,
          'description': product.description,
          'stock': product.stock,
          'isAvailable': product.isAvailable,
        },
      );
    } catch (e) {
      throw Exception('Failed to create product: $e');
    }
  }

  Future<void> updateProduct(Product product) async {
    try {
      await _apiClient.put(
        '/products/${product.id}',
        body: {
          'name': product.name,
          'price': product.price,
          'imageUrl': product.imageUrl,
          'categoryId': product.categoryId,
          'description': product.description,
          'stock': product.stock,
          'isAvailable': product.isAvailable,
        },
      );
    } catch (e) {
      throw Exception('Failed to update product: $e');
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      await _apiClient.delete('/products/$id');
    } catch (e) {
      throw Exception('Failed to delete product: $e');
    }
  }

  // --- Categories CRUD ---

  Future<List<Map<String, dynamic>>> getCategories() async {
    try {
      final response = await _apiClient.get('/categories');
      return (response as List).cast<Map<String, dynamic>>();
    } catch (e) {
      throw Exception('Failed to load categories: $e');
    }
  }

  Future<void> createCategory(String name, String description) async {
    try {
      await _apiClient.post(
        '/categories',
        body: {'name': name, 'description': description},
      );
    } catch (e) {
      throw Exception('Failed to create category: $e');
    }
  }

  Future<void> updateCategory(int id, String name, String description) async {
    try {
      await _apiClient.put(
        '/categories/$id',
        body: {'name': name, 'description': description},
      );
    } catch (e) {
      throw Exception('Failed to update category: $e');
    }
  }

  Future<void> deleteCategory(int id) async {
    try {
      await _apiClient.delete('/categories/$id');
    } catch (e) {
      throw Exception('Failed to delete category: $e');
    }
  }

  // Optional: Add Search (Client-side filtering for now)
  Future<List<Product>> searchProducts(String query) async {
    final products = await getProducts();
    return products.where((product) {
      final nameLower = product.name.toLowerCase();
      final categoryLower = product.category.toLowerCase();
      final searchLower = query.toLowerCase();
      return nameLower.contains(searchLower) ||
          categoryLower.contains(searchLower);
    }).toList();
  }
}
