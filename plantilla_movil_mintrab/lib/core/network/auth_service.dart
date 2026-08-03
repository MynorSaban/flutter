import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../storage/secure_storage.dart';

final String _clientId = dotenv.env['CLIENT_ID'] ?? 'client';
final String _realm = dotenv.env['REALM'] ?? 'Interno';
final String _keycloakBase = dotenv.env['KEYCLOAK_BASE'] ?? 'localhost:8080';
final String _keycloakTokenUrl = '$_keycloakBase/realms/$_realm/protocol/openid-connect/token';

class AuthService {
  final _dio = Dio();
  Future<void> login({
    required String username,
    required String password,
  }) async {
    final response = await _dio.post(
      _keycloakTokenUrl,
      data: {
        'grant_type': 'password',
        'client_id': _clientId,
        'username': username,
        'password': password,
      },
       options: Options(contentType: 'application/x-www-form-urlencoded'),
    );
    await SecureStorage.instance.saveTokens(
      accessToken: response.data['access_token'] as String,
      refreshToken: response.data['refresh_token'] as String,
    );
  }

  // Llamado automaticamente por AuthInterceptor cuando el access_token expira
  Future<String> refreshAccessToken() async {
    final refreshToken = await SecureStorage.instance.getRefreshToken();

    final response = await _dio.post(
      _keycloakTokenUrl,
      data: {
        'grant_type': 'refresh_token',
        'client_id': _clientId,
        'refresh_token': refreshToken,
      },
      options: Options(contentType: 'application/x-www-form-urlencoded'),
    );

    final newAccess = response.data['access_token'] as String;
    final newRefresh = response.data['refresh_token'] as String;

    await SecureStorage.instance.saveTokens(
      accessToken: newAccess,
      refreshToken: newRefresh,
    );

    return newAccess;
  }

  Future<void> logout() => SecureStorage.instance.clearTokens();
}
