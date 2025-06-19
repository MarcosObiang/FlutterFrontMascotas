import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:mascotas_citas/const_values/const_values.dart';
import 'package:mascotas_citas/services/auth/AuthSesionDataService.dart';

/// Servicio de API centralizado usando Dio.
class DioApiService {
  late final Dio _dio;
  final AuthDataService authDataService;
  String requestToken = '';

  /// Inicializa el servicio con el [authDataService] y la [baseUrl] de la API.
  DioApiService({
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
    // AGREGAR EL HEADER userUID
    if (authDataService.userUID != null) {
      _dio.options.headers['userUID'] = authDataService.userUID;
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
      print(e.message);
 
      rethrow;
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
    print(e.message);
      rethrow;
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
      // Añadir otros datos a la solicitud
     
    });
    
    Map<dynamic,dynamic> mappedData=data;
    mappedData.forEach((key, value) {
      formData.fields.add(MapEntry(key, value.toString()));
    });

    print(formData.fields.toSet());
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
  } on DioException {
      rethrow;
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
    } on DioException {
      rethrow;
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
    } on DioException {
      rethrow;
    }
  }


}
