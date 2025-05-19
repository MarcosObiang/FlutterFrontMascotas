import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
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
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
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

  /// Método GET para realizar peticiones HTTP
  /// 
  /// @param path URL del endpoint
  /// @param queryParams Parámetros de consulta opcionales
  /// @param headers Headers HTTP opcionales para sobrescribir los predeterminados
  Future<Response> get({
    required String path,
    Map<String, dynamic>? queryParams,
    Map<String, dynamic>? headers,
  }) async {
    try {
      // Si se proporcionan headers específicos, actualizamos los headers del cliente
      if (headers != null && headers.isNotEmpty) {
        dioClient.options.headers.addAll(headers);
      } else {
        // Asegurarse de que al menos tengamos el header de Content-Type
        dioClient.options.headers['Content-Type'] = 'application/json';
        
        // Intentar obtener y añadir el token si existe
        String? token = authDataService.token;
        if (token != null && token.isNotEmpty) {
          dioClient.options.headers['Authorization'] = 'Bearer $token';
        }
      }
      
      // Realizar la petición GET
      final response = await dioClient.get(
        path,
        queryParameters: queryParams,
      );
      
      print('*** Request ***');
      print('uri: $path${queryParams != null ? '?' + queryParams.entries.map((e) => '${e.key}=${e.value}').join('&') : ''}');
      print('method: GET');
      print('responseType: ${dioClient.options.responseType}');
      print('followRedirects: ${dioClient.options.followRedirects}');
      print('persistentConnection: ${dioClient.options.persistentConnection}');
      print('connectTimeout: ${dioClient.options.connectTimeout}');
      print('sendTimeout: ${dioClient.options.sendTimeout}');
      print('receiveTimeout: ${dioClient.options.receiveTimeout}');
      print('receiveDataWhenStatusError: ${dioClient.options.receiveDataWhenStatusError}');
      print('extra: ${dioClient.options.extra}');
      print('headers:');
      dioClient.options.headers.forEach((key, value) {
        print(' $key: $value');
      });
      print('data:');
      print(null);
      print('');
      
      return response;
    } on DioException catch (e) {
      print('*** DioException ***:');
      print('uri: ${e.requestOptions.uri}');
      print(e.toString());
      print('uri: ${e.requestOptions.uri}');
      print('statusCode: ${e.response?.statusCode}');
      print('headers:');
      e.response?.headers.forEach((name, values) {
        print(' $name: ${values.join(',')}');
      });
      print('Response Text:');
      print(e.response?.data.toString());
      print('\n');
      
      if (e.response != null) {
        throw Exception('Error ${e.response!.statusCode}: ${e.response!.data}');
      } else {
        throw Exception('Error de conexión: ${e.message}');
      }
    } catch (e) {
      print('Error general en petición GET: $e');
      rethrow;
    }
  }

  /// Método POST para realizar peticiones HTTP
  /// 
  /// @param path URL del endpoint
  /// @param data Datos a enviar en el cuerpo de la petición
  /// @param queryParams Parámetros de consulta opcionales
  /// @param headers Headers HTTP opcionales para sobrescribir los predeterminados
  /// @param files Archivos a subir (opcional)
  Future<Response> post({
    required String path,
    dynamic data,
    Map<String, dynamic>? queryParams,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? files,
  }) async {
    try {
      // Si se proporcionan headers específicos, actualizamos los headers del cliente
      if (headers != null && headers.isNotEmpty) {
        dioClient.options.headers.addAll(headers);
      } else {
        // Asegurarse de que al menos tengamos el header de Content-Type
        dioClient.options.headers['Content-Type'] = 'application/json';
        
        // Intentar obtener y añadir el token si existe
        String? token = authDataService.token;
        if (token != null && token.isNotEmpty) {
          dioClient.options.headers['Authorization'] = 'Bearer $token';
        }
      }
      
      Response response;
      
      // Si hay archivos, usamos FormData para incluirlos junto con los datos
      if (files != null && files.isNotEmpty) {
        response = await _uploadFiles(path, data, files, 'POST', queryParams);
      } else {
        // Si no hay archivos, solo enviamos los datos
        response = await dioClient.post(
          path,
          data: data,
          queryParameters: queryParams,
        );
      }
      
      print('*** Request ***');
      print('uri: $path${queryParams != null ? '?' + queryParams.entries.map((e) => '${e.key}=${e.value}').join('&') : ''}');
      print('method: POST');
      print('responseType: ${dioClient.options.responseType}');
      print('followRedirects: ${dioClient.options.followRedirects}');
      print('persistentConnection: ${dioClient.options.persistentConnection}');
      print('connectTimeout: ${dioClient.options.connectTimeout}');
      print('sendTimeout: ${dioClient.options.sendTimeout}');
      print('receiveTimeout: ${dioClient.options.receiveTimeout}');
      print('receiveDataWhenStatusError: ${dioClient.options.receiveDataWhenStatusError}');
      print('extra: ${dioClient.options.extra}');
      print('headers:');
      dioClient.options.headers.forEach((key, value) {
        print(' $key: $value');
      });
      print('data:');
      print(data);
      print('');
      
      return response;
    } on DioException catch (e) {
      print('*** DioException ***:');
      print('uri: ${e.requestOptions.uri}');
      print(e.toString());
      print('uri: ${e.requestOptions.uri}');
      print('statusCode: ${e.response?.statusCode}');
      print('headers:');
      e.response?.headers.forEach((name, values) {
        print(' $name: ${values.join(',')}');
      });
      print('Response Text:');
      print(e.response?.data.toString());
      print('\n');
      
      if (e.response != null) {
        throw Exception('Error ${e.response!.statusCode}: ${e.response!.data}');
      } else {
        throw Exception('Error de conexión: ${e.message}');
      }
    } catch (e) {
      print('Error general en petición POST: $e');
      rethrow;
    }
  }

//   /// Método privado para manejar la subida de archivos junto con otros datos (FormData).
// Future<Response> _uploadFiles(String path, dynamic data, Map<String, dynamic> files) async {
//   try {
//     // Crear FormData para enviar tanto los archivos como los datos
//     final formData = FormData.fromMap({
//       ...files.map((key, value) {
//         // Asegurarnos de que el valor sea un File o Uint8List
//         if (value is File) {
//           return MapEntry(key, MultipartFile.fromFile(value.path, filename: key));
//         } else if (value is Uint8List) {
//           return MapEntry(key, MultipartFile.fromBytes(value, filename: key));
//         } else {
//           throw Exception('Archivo no soportado. Aceptamos solo File o Uint8List.');
//         }
//       }),
//       // Añadir otros datos a la solicitud
     
//     });
    
//     Map<dynamic,dynamic> mappedData=data;
//     mappedData.forEach((key, value) {
//       formData.fields.add(MapEntry(key, value.toString()));
//     });

//     print(formData.fields.toSet());
//     // Realizar la solicitud POST con FormData
//     return await _dio.post(
//       path,
//       data: formData,
//       options: Options(
//         headers: {
//           'Content-Type': 'multipart/form-data',
//         },
//       ),
//     );
//   } on DioException catch (e) {
//       rethrow;
//   }
// }

  /// Realiza una petición PUT a [path] con el cuerpo [data].
  Future<Response> put({
    required String path,
    required dynamic data,
  }) async {
      setAuthToken();

    try {
      return await _dio.put(path, data: data);
    } on DioException catch (e) {
      rethrow;
    }
  }

  /// Realiza una petición DELETE a [path] con el cuerpo [data].
  Future<Response> delete({
    required String path,
    dynamic data,
    Map<String, dynamic>? queryParams,
    Map<String, dynamic>? headers,
  }) async {
    try {
      // Si se proporcionan headers específicos, actualizamos los headers del cliente
      if (headers != null && headers.isNotEmpty) {
        dioClient.options.headers.addAll(headers);
      } else {
        // Asegurarse de que al menos tengamos el header de Content-Type
        dioClient.options.headers['Content-Type'] = 'application/json';
        
        // Intentar obtener y añadir el token si existe
        String? token = authDataService.token;
        if (token != null && token.isNotEmpty) {
          dioClient.options.headers['Authorization'] = 'Bearer $token';
        }
      }
      
      final response = await dioClient.delete(
        path, 
        data: data,
        queryParameters: queryParams,
      );
      
      print('*** Request ***');
      print('uri: $path${queryParams != null ? '?' + queryParams.entries.map((e) => '${e.key}=${e.value}').join('&') : ''}');
      print('method: DELETE');
      print('responseType: ${dioClient.options.responseType}');
      print('followRedirects: ${dioClient.options.followRedirects}');
      print('persistentConnection: ${dioClient.options.persistentConnection}');
      print('connectTimeout: ${dioClient.options.connectTimeout}');
      print('sendTimeout: ${dioClient.options.sendTimeout}');
      print('receiveTimeout: ${dioClient.options.receiveTimeout}');
      print('receiveDataWhenStatusError: ${dioClient.options.receiveDataWhenStatusError}');
      print('extra: ${dioClient.options.extra}');
      print('headers:');
      dioClient.options.headers.forEach((key, value) {
        print(' $key: $value');
      });
      print('data:');
      print(data);
      print('');
      
      return response;
    } on DioException catch (e) {
      print('*** DioException ***:');
      print('uri: ${e.requestOptions.uri}');
      print(e.toString());
      print('uri: ${e.requestOptions.uri}');
      print('statusCode: ${e.response?.statusCode}');
      print('headers:');
      e.response?.headers.forEach((name, values) {
        print(' $name: ${values.join(',')}');
      });
      print('Response Text:');
      print(e.response?.data.toString());
      print('\n');
      
      if (e.response != null) {
        throw Exception('Error ${e.response!.statusCode}: ${e.response!.data}');
      } else {
        throw Exception('Error de conexión: ${e.message}');
      }
    } catch (e) {
      print('Error general en petición DELETE: $e');
      rethrow;
    }
  }
  
  /// Método privado mejorado para manejar la subida de archivos junto con otros datos (FormData).
  Future<Response> _uploadFiles(
    String path, 
    dynamic data, 
    Map<String, dynamic> files,
    String method,
    Map<String, dynamic>? queryParams,
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
          String mimeType = _getMimeType(extension);
          
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
        queryParameters: queryParams,
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
/// Actualiza la imagen de perfil del usuario
Future<Response> updateUserImage({
  required String userUID,
  required File userImage,
}) async {
  try {
    // Crear el FormData
    final formData = FormData();
    
    // Asegurarse de que el archivo existe
    if (!await userImage.exists()) {
      throw Exception('El archivo no existe: ${userImage.path}');
    }
    
    // Determinar el tipo MIME basado en la extensión del archivo
    String extension = userImage.path.split('.').last.toLowerCase();
    String mimeType = _getMimeType(extension);
    
    print('Enviando archivo: ${userImage.path}');
    print('Tipo MIME: $mimeType');
    
    // Agregar el archivo con el nombre correcto para el endpoint
    final fileName = userImage.path.split('/').last;
    final multipartFile = await MultipartFile.fromFile(
      userImage.path,
      filename: fileName,
      contentType: MediaType.parse(mimeType),
    );
    
    // Agregar el archivo con el nombre correcto según el controlador
    formData.files.add(MapEntry('file', multipartFile));
    
    // Agregar los parámetros requeridos
    formData.fields.add(MapEntry('userUID', userUID));
    formData.fields.add(MapEntry('index', '1')); // Asumimos que es la imagen de perfil
    formData.fields.add(MapEntry('type', 'profileImage')); // Tipo de imagen
    
    print('FormData creado con éxito');
    print('Usuario UID: $userUID');
    
    // Establecer los headers correctos
    Map<String, dynamic> headers = {
      'Content-Type': 'multipart/form-data',
    };
    
    print('Enviando solicitud a: http://localhost:8091/media/upload');
    
    // Realizar la solicitud
    return await post(
      path: 'http://localhost:8091/media/upload',
      data: formData,
      headers: headers,
    );
  } catch (e) {
    print('Error en updateUserImage: $e');
    rethrow;
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
      final headers = {
        'Content-Type': 'multipart/form-data',
        'userUID': userUID,
        'petUID': petUID,
      };
      
      return await post(
        path: '/api/update-pet-images',
        data: formData,
        headers: headers,
      );
    } catch (e) {
      print('Error en updatePetImages: $e');
      rethrow;
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