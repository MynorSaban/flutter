import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'auth_interceptor.dart';
import 'auth_service.dart';

final Dio useApi = _buildClient();

Dio _buildClient() {
  final dio = Dio(
    BaseOptions(
      baseUrl: dotenv.env['API_URL_BASE']?? 'localhost:8080',
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 3),
      responseType: ResponseType.json,
    ),
  );

  dio.interceptors.add(AuthInterceptor(AuthService()));

  return dio;
}
