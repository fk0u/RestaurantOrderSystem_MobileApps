import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/services/mock_api_service.dart';
import '../domain/user_entity.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    MockApiService(),
    ref.read(storageServiceProvider),
  );
});

class AuthRepository {
  final MockApiService _apiService;
  final StorageService _storageService;

  AuthRepository(this._apiService, this._storageService);

  Future<User> login(String username, String password) async {
    final user = await _apiService.login(username, password);
    
    if (user == null) {
      throw Exception('Login Failed');
    }
    
    // Persist session
    await _storageService.saveAuthToken(user.token);
    await _storageService.saveUserRole(user.role);
    
    return user;
  }

  Future<void> logout() async {
    await _storageService.clearAuth();
  }
  
  Future<User?> getCurrentUser() async {
    final token = _storageService.getAuthToken();
    final role = _storageService.getUserRole();
    
    if (token != null && role != null) {
      // Mock, just return a reconstructed user
      return User(id: 'current', name: 'User', role: role, token: token);
    }
    return null;
  }
}
