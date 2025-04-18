import 'package:dio/dio.dart';
import 'package:mascotas_citas/const_values/const_values.dart';
import 'package:mascotas_citas/services/auth/AuthSesionDataService.dart';

/// Servicio de API centralizado usando Dio.
class ApiService {
  late final Dio _dio;
  final AuthDataService authDataService;

  /// Inicializa el servicio con el [authDataService] y la [baseUrl] de la API.
  ApiService({
    required this.authDataService,
  }) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ConstValues.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );

    final token = authDataService.token;
    if (token != null) {
      setAuthToken(token);
    }
  }

  /// Establece el token de autenticación.
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  /// Realiza una petición GET a [path] con [queryParams].
  Future<Response> get({
    required String path,
    required Map<String, dynamic> queryParams,
  }) async {
    try {
      return await _dio.get(path, queryParameters: queryParams);
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  /// Realiza una petición POST a [path] con el cuerpo [data].
  Future<Response> post({
    required String path,
    required dynamic data,
  }) async {
    try {
      return await _dio.post(path, data: data);
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  /// Realiza una petición PUT a [path] con el cuerpo [data].
  Future<Response> put({
    required String path,
    required dynamic data,
  }) async {
    try {
      return await _dio.put(path, data: data);
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  /// Realiza una petición DELETE a [path] con el cuerpo [data].
  Future<Response> delete({
    required String path,
    required dynamic data,
  }) async {
    try {
      return await _dio.delete(path, data: data);
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  /// Devuelve un mensaje legible en caso de error.
  String _handleError(DioException error) {
    if (error.response != null) {
      return 'Error ${error.response?.statusCode}: ${error.response?.data}';
    } else {
      return 'Error: ${error.message}';
    }
  }
}
