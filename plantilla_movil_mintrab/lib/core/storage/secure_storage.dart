import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  SecureStorage._();
  static final SecureStorage instance = SecureStorage._();

  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static const _keyAccess = 'access_token';
  static const _keyRefresh = 'refresh_token';

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      _storage.write(key: _keyAccess, value: accessToken),
      _storage.write(key: _keyRefresh, value: refreshToken),
    ]);
  }

  Future<String?> getAccessToken() => _storage.read(key: _keyAccess);
  Future<String?> getRefreshToken() => _storage.read(key: _keyRefresh);

  // Decodifica el JWT y retorna el payload como Map
  Future<Map<String, dynamic>?> getUserInfo() async {
    final token = await getAccessToken();
    if (token == null) return null;

    final parts = token.split('.');
    if (parts.length != 3) return null;

    final payload = base64Url.normalize(parts[1]);
    final decoded = utf8.decode(base64Url.decode(payload));
    print('--------------------ESTO ES CUANDO DECODIFICA EL JWT----------------------');
    print(decoded);
    print('--------------------FINALIZA LA DECODIFICACION----------------------');

    return jsonDecode(decoded) as Map<String, dynamic>;
  }

  Future<void> clearTokens() => _storage.deleteAll();
}
