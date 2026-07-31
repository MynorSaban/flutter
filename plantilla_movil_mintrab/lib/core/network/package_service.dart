import 'package:dio/dio.dart';
import 'dio_client.dart';

class PackageService {
  // GET sin parametros
  Future<Map<String, dynamic>> getPackage(String name) async {
    final response = await useApi.get('/packages/$name');
    return response.data as Map<String, dynamic>;
  }

  // GET con query params  ej: /packages?page=1&limit=10
  Future<List<dynamic>> getPackages({int page = 1}) async {
    final response = await useApi.get(
      '/packages',
      queryParameters: {'page': page},
    );
    return response.data['packages'] as List<dynamic>;
  }

  // POST con body JSON
  Future<Map<String, dynamic>> createPackage({
    required String name,
    required String version,
  }) async {
    final response = await useApi.post(
      '/packages',
      data: {'name': name, 'version': version},
    );
    return response.data as Map<String, dynamic>;
  }

  // POST con headers adicionales (ej: token de autenticacion)
  Future<Map<String, dynamic>> createPackageAuth({
    required String name,
    required String token,
  }) async {
    final response = await useApi.post(
      '/packages',
      data: {'name': name},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return response.data as Map<String, dynamic>;
  }
}
