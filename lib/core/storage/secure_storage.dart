import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const _tokenKey = 'access_token';
  static const _expiresKey = 'token_expires_at';

  final FlutterSecureStorage _storage;

  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
            );

  Future<void> saveToken(String token, int expiresIn) async {
    final expiresAt =
        DateTime.now().add(Duration(seconds: expiresIn)).toIso8601String();
    await _storage.write(key: _tokenKey, value: token);
    await _storage.write(key: _expiresKey, value: expiresAt);
  }

  Future<String?> getToken() async {
    final token = await _storage.read(key: _tokenKey);
    if (token == null) return null;

    final expiresAtStr = await _storage.read(key: _expiresKey);
    if (expiresAtStr != null) {
      final expiresAt = DateTime.tryParse(expiresAtStr);
      if (expiresAt != null && DateTime.now().isAfter(expiresAt)) {
        await clearToken();
        return null;
      }
    }
    return token;
  }

  Future<bool> hasValidToken() async {
    return (await getToken()) != null;
  }

  Future<void> clearToken() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _expiresKey);
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
