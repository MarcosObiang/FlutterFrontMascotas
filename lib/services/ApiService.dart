import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';  // Importante: añadir esta dependencia
import 'package:mascotas_citas/const_values/const_values.dart';
import 'package:mascotas_citas/services/auth/AuthSesionDataService.dart';

/// Servicio de API centralizado usando Dio.
class ApiService {
  Dio get dioClient => _dio;
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
        connectTimeout: const Duration(seconds: 30),  // Aumentado para subidas de archivos
        receiveTimeout: const Duration(seconds: 30),  // Aumentado para subidas de archivos
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );

    if (requestToken.isEmpty) {
      setAuthToken();
    }
    
    // Añadir interceptor para debugging
    _dio.interceptors.add(LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
      responseBody: true,
      error: true,
    ));
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
        return await _uploadFiles(path, data, files, 'POST');
      } else {
        // Si no hay archivos, solo enviamos los datos
        return await _dio.post(path, data: data);
      }
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  /// Realiza una petición PUT a [path] con el cuerpo [data] y opcionalmente archivos.
  Future<Response> put({
    required String path,
    required dynamic data,
    Map<String, dynamic>? files,  // Añadimos soporte para archivos en PUT
  }) async {
    setAuthToken();

    try {
      if (files != null && files.isNotEmpty) {
        // Si hay archivos, usamos FormData para incluirlos junto con los datos
        return await _uploadFiles(path, data, files, 'PUT');
      } else {
        // Si no hay archivos, solo enviamos los datos
        return await _dio.put(path, data: data);
      }
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
  
  /// Método privado mejorado para manejar la subida de archivos junto con otros datos (FormData).
  Future<Response> _uploadFiles(
    String path, 
    dynamic data, 
    Map<String, dynamic> files,
    String method,
  ) async {
    try {
      // Crear un FormData vacío
      final formData = FormData();
      
      // Añadir los campos de datos (no archivos)
      if (data is Map<String, dynamic>) {
        data.forEach((key, value) {
          formData.fields.add(MapEntry(key, value.toString()));
        });
      }
      
      // Añadir los archivos
      for (var entry in files.entries) {
        final key = entry.key;
        final value = entry.value;
        
        if (value is File) {
          // Determinar el tipo MIME basado en la extensión del archivo
          String extension = value.path.split('.').last.toLowerCase();
          String mimeType = 'image/jpeg'; // Por defecto
          
          if (extension == 'png') {
            mimeType = 'image/png';
          } else if (extension == 'gif') {
            mimeType = 'image/gif';
          } else if (extension == 'webp') {
            mimeType = 'image/webp';
          }
          
          // Crear el MultipartFile
          final fileName = value.path.split('/').last;
          final multipartFile = await MultipartFile.fromFile(
            value.path,
            filename: fileName,
            contentType: MediaType.parse(mimeType),
          );
          
          // Añadir al FormData
          formData.files.add(MapEntry(key, multipartFile));
          
        } else if (value is Uint8List) {
          // Para datos binarios
          final fileName = 'image_${DateTime.now().millisecondsSinceEpoch}.jpg';
          final multipartFile = MultipartFile.fromBytes(
            value,
            filename: fileName,
            contentType: MediaType.parse('image/jpeg'),
          );
          
          formData.files.add(MapEntry(key, multipartFile));
        } else {
          throw Exception('Tipo de archivo no soportado: ${value.runtimeType}');
        }
      }

      // Debug: imprimir el contenido del FormData
      print('FormData fields: ${formData.fields}');
      print('FormData files: ${formData.files.map((f) => '${f.key}: ${f.value.filename}').join(', ')}');
      
      // Realizar la solicitud con FormData
      return await _dio.request(
        path,
        data: formData,
        options: Options(
          method: method,
          headers: {
            'Content-Type': 'multipart/form-data',
          },
          // Aumentar el timeout para subidas grandes
          sendTimeout: const Duration(seconds: 60),
          receiveTimeout: const Duration(seconds: 60),
        ),
      );
    } on DioException catch (e) {
      print('Error en _uploadFiles: ${e.message}');
      print('Response data: ${e.response?.data}');
      print('Response statusCode: ${e.response?.statusCode}');
      throw Exception(_handleError(e));
    } catch (e) {
      print('Error general en _uploadFiles: $e');
      throw Exception('Error al subir archivos: $e');
    }
  }
  
  /// Determina el tipo MIME basado en la extensión del archivo
  String _getMimeType(String extension) {
    switch (extension) {
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'jpg':
      case 'jpeg':
      default:
        return 'image/jpeg';
    }
  }
  
  /// Actualiza la imagen de perfil del usuario
  Future<Response> updateUserImage({
    required String userUID,
    required File userImage,
  }) async {
    setAuthToken();
    
    try {
      // Crear el FormData
      final formData = FormData();
      
      // Determinar el tipo MIME basado en la extensión del archivo
      String extension = userImage.path.split('.').last.toLowerCase();
      String mimeType = _getMimeType(extension);
      
      // Agregar el archivo con el nombre correcto para el endpoint
      final fileName = userImage.path.split('/').last;
      final multipartFile = await MultipartFile.fromFile(
        userImage.path,
        filename: fileName,
        contentType: MediaType.parse(mimeType),
      );
      
      formData.files.add(MapEntry('userImage', multipartFile));
      
      // Realizar la solicitud con el header requerido
      return await _dio.post(
        '/api/update-user-image',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
            'userUID': userUID,
          },
        ),
      );
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }
  
  /// Actualiza las imágenes de la mascota
  Future<Response> updatePetImages({
    required String userUID,
    required String petUID,
    File? petImage1,
    File? petImage2,
    File? petImage3,
  }) async {
    setAuthToken();
    
    try {
      // Verificar que se ha proporcionado al menos una imagen
      if (petImage1 == null && petImage2 == null && petImage3 == null) {
        throw Exception('Debes proporcionar al menos una imagen de mascota');
      }
      
      // Crear el FormData
      final formData = FormData();
      
      // Agregar cada imagen si está presente
      if (petImage1 != null) {
        final mimeType = _getMimeType(petImage1.path.split('.').last.toLowerCase());
        final fileName = petImage1.path.split('/').last;
        final multipartFile = await MultipartFile.fromFile(
          petImage1.path,
          filename: fileName,
          contentType: MediaType.parse(mimeType),
        );
        formData.files.add(MapEntry('petImage1', multipartFile));
      }
      
      if (petImage2 != null) {
        final mimeType = _getMimeType(petImage2.path.split('.').last.toLowerCase());
        final fileName = petImage2.path.split('/').last;
        final multipartFile = await MultipartFile.fromFile(
          petImage2.path,
          filename: fileName,
          contentType: MediaType.parse(mimeType),
        );
        formData.files.add(MapEntry('petImage2', multipartFile));
      }
      
      if (petImage3 != null) {
        final mimeType = _getMimeType(petImage3.path.split('.').last.toLowerCase());
        final fileName = petImage3.path.split('/').last;
        final multipartFile = await MultipartFile.fromFile(
          petImage3.path,
          filename: fileName,
          contentType: MediaType.parse(mimeType),
        );
        formData.files.add(MapEntry('petImage3', multipartFile));
      }
      
      // Realizar la solicitud con los headers requeridos
      return await _dio.post(
        '/api/update-pet-images',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
            'userUID': userUID,
            'petUID': petUID,
          },
        ),
      );
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