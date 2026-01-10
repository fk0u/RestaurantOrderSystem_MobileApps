import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/database/database_helper.dart';
import '../domain/user_entity.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    ref.read(storageServiceProvider),
  );
});

class AuthRepository {
  final StorageService _storageService;

  AuthRepository(this._storageService);

  Future<User> login(String email, String password) async {
    final db = await DatabaseHelper.instance.database;
    
    final maps = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );

    if (maps.isNotEmpty) {
      final userMap = maps.first;
      // Generate a simple token (in real app, use JWT or similar)
      final token = 'tok_${userMap['id']}_${DateTime.now().millisecondsSinceEpoch}';
      
      final user = User(
        id: userMap['id'] as String,
        name: userMap['name'] as String,
        role: userMap['role'] as String,
        token: token,
      );

      // Persist session
      await _storageService.saveAuthToken(user.token);
      await _storageService.saveUserRole(user.role);
      
      return user;
    } else {
      throw Exception('Email atau password salah');
    }
  }

  Future<void> logout() async {
    await _storageService.clearAuth();
  }
  
  Future<User?> getCurrentUser() async {
    final token = _storageService.getAuthToken();
    final role = _storageService.getUserRole();
    
    // In a real app, we'd validate the token against DB or verify signature.
    // Here we'll trust storage but maybe fetch user details if needed.
    // For now, simple reconstruction is fine for MVP.
    // Enhancement: Store userID in prefs to fetch full profile.
    
    if (token != null && role != null) {
      // Reconstruct user (simulated)
      return User(id: 'current', name: 'User', role: role, token: token);
    }
    return null;
  }
}
