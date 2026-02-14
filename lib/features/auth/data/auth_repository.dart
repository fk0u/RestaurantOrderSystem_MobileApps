import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/storage_service.dart';
import '../domain/user_entity.dart';
// import '../../../core/services/api_client.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.read(storageServiceProvider));
});

class AuthRepository {
  final StorageService _storageService;
  // final ApiClient _api = ApiClient();

  AuthRepository(this._storageService);

  Future<User> login(String email, String password) async {
    // MOCK LOGIN
    await Future.delayed(const Duration(seconds: 1)); // Simulate network

    if (email.isEmpty || password.isEmpty) {
      throw Exception('Email dan password harus diisi');
    }

    final user = User(
      id: 'user_123',
      name: 'Admin Resto',
      email: email,
      role: 'admin', // Default to admin for now
      token: 'mock_token_12345',
    );

    await _storageService.saveAuthToken(user.token);
    await _storageService.saveUserRole(user.role);
    await _storageService.saveUserId(user.id);
    await _storageService.saveUserName(user.name);

    return user;
  }

  Future<void> logout() async {
    await _storageService.clearAuth();
  }

  Future<User?> getCurrentUser() async {
    final token = _storageService.getAuthToken();
    final role = _storageService.getUserRole();
    final id = _storageService.getUserId();
    final name = _storageService.getUserName();

    // In a real app, we'd validate the token against DB or verify signature.
    // Here we'll trust storage but maybe fetch user details if needed.
    // For now, simple reconstruction is fine for MVP.
    // Enhancement: Store userID in prefs to fetch full profile.

    if (token != null && role != null && id != null && name != null) {
      return User(
        id: id,
        name: name,
        email: 'user@example.com', // Placeholder
        role: role,
        token: token,
      );
    }
    return null;
  }
}
