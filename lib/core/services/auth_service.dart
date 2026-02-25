import 'package:dio/dio.dart';
import '../models/user.dart';
import '../storage/secure_storage.dart';
import 'api_client.dart';

class AuthService {
  final ApiClient _api;
  final SecureStorageService _storage;

  AuthService({required ApiClient api, required SecureStorageService storage})
      : _api = api,
        _storage = storage;

  Future<AuthResult> login(String email, String password) async {
    final response = await _api.dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    final data = _api.extractData(response);
    final result = AuthResult.fromJson(data);
    await _storage.saveToken(result.accessToken, result.expiresIn);
    return result;
  }

  Future<AuthResult> register(String email, String password) async {
    final response = await _api.dio.post('/auth/register', data: {
      'email': email,
      'password': password,
    });
    final data = _api.extractData(response);
    final result = AuthResult.fromJson(data);
    await _storage.saveToken(result.accessToken, result.expiresIn);
    return result;
  }

  Future<void> refreshToken() async {
    final response = await _api.dio.post('/auth/refresh');
    final data = _api.extractData(response);
    await _storage.saveToken(
      data['access_token'],
      data['expires_in'] ?? 604800,
    );
  }

  Future<void> logout() async {
    try {
      await _api.dio.post('/auth/logout');
    } on DioException catch (_) {
      // Ignore errors — clear local token regardless
    }
    await _storage.clearToken();
  }

  Future<User> getProfile() async {
    final response = await _api.dio.get('/auth/profile');
    final data = _api.extractData(response);
    return User.fromJson(data);
  }

  Future<bool> isLoggedIn() async {
    return await _storage.hasValidToken();
  }
}
