import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/storage_service.dart';
import '../domain/user_entity.dart';
import '../../../../core/network/api_client.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.read(storageServiceProvider), ApiClient());
});

class AuthRepository {
  final StorageService _storageService;
  final ApiClient _apiClient;

  AuthRepository(this._storageService, this._apiClient);

  Future<User> login(String email, String password) async {
    try {
      final response = await _apiClient.post(
        '/auth/login',
        body: {'email': email, 'password': password},
      );

      if (response == null) {
        throw Exception('Login failed: No response');
      }

      final userMap = response['user'];
      final token = response['token'];

      final user = User(
        id: userMap['id'].toString(), // Ensure string if ID is int
        name: userMap['name'],
        email: userMap['email'],
        role: userMap['role'],
        token: token,
      );

      await _storageService.saveAuthToken(user.token);
      await _storageService.saveUserRole(user.role);
      await _storageService.saveUserId(user.id);
      await _storageService.saveUserName(user.name);

      return user;
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  Future<User> register(String name, String email, String password) async {
    try {
      final response = await _apiClient.post(
        '/auth/register',
        body: {'name': name, 'email': email, 'password': password},
      );

      if (response == null) {
        throw Exception('Registration failed: No response');
      }

      final userMap = response['user'];
      // Backend returns structure with user object inside
      final token = userMap['token'];

      final user = User(
        id: userMap['id'].toString(),
        name: userMap['name'],
        email: userMap['email'],
        role: userMap['role'],
        token: token,
      );

      // Auto login after register
      await _storageService.saveAuthToken(user.token);
      await _storageService.saveUserRole(user.role);
      await _storageService.saveUserId(user.id);
      await _storageService.saveUserName(user.name);

      return user;
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  Future<void> logout() async {
    // Optionally call API logout
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
