import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/database_helper.dart';
import '../domain/product_entity.dart';

final menuRepositoryProvider = Provider<MenuRepository>((ref) {
  return MenuRepository();
});

class MenuRepository {
  MenuRepository();

  Future<List<Product>> getProducts() async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query('products');

    return maps.map((json) => Product.fromJson(json)).toList();
  }

  // Optional: Add Search
  Future<List<Product>> searchProducts(String query) async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query(
      'products',
      where: 'name LIKE ? OR category LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );
     return maps.map((json) => Product.fromJson(json)).toList();
  }
}
