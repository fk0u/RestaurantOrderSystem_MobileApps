import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/mock_api_service.dart';
import '../domain/product_entity.dart';

final menuRepositoryProvider = Provider<MenuRepository>((ref) {
  return MenuRepository(MockApiService()); // Ideally inject mock provider
});

class MenuRepository {
  final MockApiService _apiService;

  MenuRepository(this._apiService);

  Future<List<Product>> getProducts() async {
    return await _apiService.getProducts();
  }
}
