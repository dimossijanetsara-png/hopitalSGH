import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const _storage = FlutterSecureStorage();

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';
  static const String _userRoleKey = 'user_role';

  Future<void> saveTokens({
    required String access,
    required String refresh,
  }) async {
    await Future.wait([
      _storage.write(key: _accessTokenKey, value: access),
      _storage.write(key: _refreshTokenKey, value: refresh),
    ]);
  }

  Future<void> saveUserId(String id) async {
    await _storage.write(key: _userIdKey, value: id);
  }

  Future<void> saveUserRole(String role) async {
    await _storage.write(key: _userRoleKey, value: role);
  }

  Future<String?> getAccessToken() async {
    return _storage.read(key: _accessTokenKey);
  }

  Future<String?> getRefreshToken() async {
    return _storage.read(key: _refreshTokenKey);
  }

  Future<String?> getUserId() async {
    return _storage.read(key: _userIdKey);
  }

  Future<String?> getUserRole() async {
    return _storage.read(key: _userRoleKey);
  }

  Future<void> clear() async {
    await Future.wait([
      _storage.delete(key: _accessTokenKey),
      _storage.delete(key: _refreshTokenKey),
      _storage.delete(key: _userIdKey),
      _storage.delete(key: _userRoleKey),
    ]);
  }

  Future<bool> hasTokens() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }
}
