import 'package:dio/dio.dart';
import '../storage/secure_storage.dart';
import 'auth_service.dart';

class AuthInterceptor extends Interceptor {
  final AuthService _authService;

  AuthInterceptor(this._authService);

  // agrega el token automaticamente
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await SecureStorage.instance.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  // Se ejecuta cuando el servidor responde con error
  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Solo intentamos refresh si fue un 401 (token expirado)
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    try {
      final newToken = await _authService.refreshAccessToken();

      // Reintenta la peticion original con el nuevo token
      final retryOptions = err.requestOptions
        ..headers['Authorization'] = 'Bearer $newToken';

      final response = await Dio().fetch(retryOptions);
      return handler.resolve(response);
    } on DioException {
      // Refresh fallo — sesion expirada, limpia los tokens
      await SecureStorage.instance.clearTokens();
      handler.next(err);
    }
  }
}
