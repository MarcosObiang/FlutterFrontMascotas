import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:mascotas_citas/models/PetModel.dart';
import 'package:mascotas_citas/const_values/const_values.dart';
import 'package:mascotas_citas/services/auth/AuthSesionDataService.dart';

/// Servicio de API centralizado usando Dio.
class ApiService {
  late final Dio _dio;
  final AuthDataService authDataService;
  String requestToken = '';

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

    if (requestToken.isEmpty) {
      setAuthToken();
    }
  }

  /// Establece el token de autenticación.
  void setAuthToken() {
    if (authDataService.token == null) {
      return;
    }

    final token = authDataService.token;
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  /// Realiza una petición GET a [path] con [queryParams].
  Future<Response> get({
    required String path,
    required Map<String, dynamic> queryParams,
  }) async {
    setAuthToken();

    try {
      return await _dio.get(path, queryParameters: queryParams);
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  /// Realiza una petición POST a [path] con el cuerpo [data] y opcionalmente archivos en un mapa [files].
  Future<Response> post({
    required String path,
    required dynamic data,
    Map<String, dynamic>? files,  // Parámetro para archivos en un mapa
  }) async {
    setAuthToken();
    try {
      if (files != null && files.isNotEmpty) {
        // Si hay archivos, usamos FormData para incluirlos junto con los datos
        return await _uploadFiles(path, data, files);
      } else {
        // Si no hay archivos, solo enviamos los datos
        return await _dio.post(path, data: data);
      }
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  /// Método privado para manejar la subida de archivos junto con otros datos (FormData).
  Future<Response> _uploadFiles(String path, dynamic data, Map<String, dynamic> files) async {
    try {
      // Crear FormData para enviar tanto los archivos como los datos
      final formData = FormData.fromMap({
        ...files.map((key, value) {
          // Asegurarnos de que el valor sea un File o Uint8List
          if (value is File) {
            return MapEntry(key, MultipartFile.fromFile(value.path, filename: key));
          } else if (value is Uint8List) {
            return MapEntry(key, MultipartFile.fromBytes(value, filename: key));
          } else {
            throw Exception('Archivo no soportado. Aceptamos solo File o Uint8List.');
          }
        }),
      });
      
      Map<dynamic, dynamic> mappedData = data;
      mappedData.forEach((key, value) {
        formData.fields.add(MapEntry(key, value.toString()));
      });

      // Realizar la solicitud POST con FormData
      return await _dio.post(
        path,
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  /// Realiza una petición PUT a [path] con el cuerpo [data].
  Future<Response> put({
    required String path,
    required dynamic data,
  }) async {
    setAuthToken();

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
    setAuthToken();

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