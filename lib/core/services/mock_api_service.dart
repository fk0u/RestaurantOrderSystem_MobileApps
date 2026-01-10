import '../../features/menu/domain/product_entity.dart';
import '../../features/auth/domain/user_entity.dart';

class MockApiService {
  Future<List<String>> getTables() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return List.generate(10, (index) => 'Meja ${index + 1}');
  }

  Future<List<Product>> getProducts() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return [
      Product(
        id: '1',
        name: 'Burger Sapi Klasik',
        description: 'Daging sapi premium dengan keju, selada, dan saus spesial.',
        price: 45000,
        imageUrl: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?auto=format&fit=crop&w=500&q=60',
        category: 'makanan_utama',
        calories: 450,
      ),
      Product(
        id: '2',
        name: 'Ayam Goreng Krispi',
        description: 'Ayam goreng renyah dengan bumbu rahasia.',
        price: 35000,
        imageUrl: 'https://images.unsplash.com/photo-1626082927389-6cd097cdc6ec?auto=format&fit=crop&w=500&q=60',
        category: 'makanan_utama',
        calories: 380,
      ),
      Product(
        id: '3',
        name: 'Pasta Carbonara',
        description: 'Pasta creamy dengan daging asap dan keju parmesan.',
        price: 55000,
        imageUrl: 'https://images.unsplash.com/photo-1612874742237-98280d839bb4?auto=format&fit=crop&w=500&q=60',
        category: 'makanan_utama',
        calories: 520,
      ),
      Product(
        id: '4',
        name: 'Es Teh Lemon',
        description: 'Teh segar dengan perasan lemon asli.',
        price: 15000,
        imageUrl: 'https://images.unsplash.com/photo-1556679343-c7306c1976bc?auto=format&fit=crop&w=500&q=60',
        category: 'minuman',
        calories: 120,
      ),
      Product(
        id: '5',
        name: 'Kopi Susu Gula Aren',
        description: 'Kopi susu kekinian dengan gula aren.',
        price: 22000,
        imageUrl: 'https://images.unsplash.com/photo-1572442388796-11668a67e53d?auto=format&fit=crop&w=500&q=60',
        category: 'minuman',
        calories: 180,
      ),
      Product(
        id: '6',
        name: 'Kentang Goreng',
        description: 'Kentang goreng renyah dengan taburan garam laut.',
        price: 20000,
        imageUrl: 'https://images.unsplash.com/photo-1630384060421-2c084f2f45cc?auto=format&fit=crop&w=500&q=60',
        category: 'camilan',
        calories: 320,
      ),
    ];
  }

  Future<User?> login(String username, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    if (username == 'admin' && password == 'admin') {
      return User(id: 'u1', name: 'Administrator', role: 'admin', token: 'mock-token-admin');
    } else if (username == 'kitchen' && password == 'kitchen') {
      return User(id: 'u2', name: 'Staff Dapur', role: 'kitchen', token: 'mock-token-kitchen');
    } else {
      return User(id: 'u3', name: 'Pelanggan', role: 'customer', token: 'mock-token-user');
    }
  }
}
