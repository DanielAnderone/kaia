import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenManager {
  static const _storage = FlutterSecureStorage();
  static const _userTokenKey = 'user_token';
  static const _adminTokenKey = 'admin_token';

  // Usuário
  static Future<void> setUserToken(String token) async =>
      await _storage.write(key: _userTokenKey, value: token);

  static Future<String?> getToken() async =>
      await _storage.read(key: _userTokenKey);

  // Admin
  static Future<void> setAdminToken(String token) async =>
      await _storage.write(key: _adminTokenKey, value: token);

  static Future<String?> getAdminToken() async =>
      await _storage.read(key: _adminTokenKey);

  static Future<void> deleteToken() async => await _storage.deleteAll();
}
