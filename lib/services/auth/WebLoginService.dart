import 'dart:developer' as developer;
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:mascotas_citas/Exceptions/ModuleException.dart';
import 'package:mascotas_citas/Exceptions/TimeOutException.dart';
import 'package:mascotas_citas/const_values/const_values.dart';
import 'package:mascotas_citas/interfaces/auth/IAuthServices.dart';
import 'package:app_links/app_links.dart';
import 'package:mascotas_citas/services/ApiService.dart';
import 'package:url_launcher/url_launcher_string.dart';

class WebLoginService implements IAuthServices {
  final appLinks = AppLinks();
  final FlutterWebAuth2 appAuth = FlutterWebAuth2();
  ApiService apiService;

  WebLoginService({required this.apiService});

  @override
  Future<Map<String, dynamic>?> login() async {
    try {
      final authorizationEndpoint =
          Uri.parse('https://accounts.google.com/o/oauth2/v2/auth');

      final scope = 'profile'; // Define los permisos que necesitas

      final authorizationUrl = authorizationEndpoint.replace(queryParameters: {
        'client_id': ConstValues.googleClientId,
        'redirect_uri': ConstValues.redirectUrl,
        'response_type': 'code',
        'scope': scope,
        // Puedes añadir un 'state' para seguridad
      });
      // Solicitar el código de autorización (solo abrirá la página en el navegador)
      print(authorizationUrl.toString());
      // Realizar la autorización
      final result = await FlutterWebAuth2.authenticate(
          url: authorizationUrl.toString(),
          callbackUrlScheme: 'com.example.mascotascitas',
          options: FlutterWebAuth2Options(useWebview: false));

      // El flujo se detiene aquí, ya que solo abrimos el navegador y esperamos el código de autorización
      // Después de la autorización, Google redirigirá al backend
      if (result != null) {
        print('Código de autorización recibido: ${result}');
        String authCode = _getAuthCode(result);
       return _getAccessToken(authCode);
      } else {
        print('Autorización fallida o cancelada');
      }
    } catch (e) {
      print('Error al iniciar sesión: $e');
    }
  }

  String _getAuthCode(String uriString) {
    Uri uri = Uri.parse(uriString);
    String code = uri.queryParameters['code']!;
    return code;
  }

  Future<Map<String, dynamic>> _getAccessToken(String authCode) async {
    try {
      final response =
          await apiService.get(path: "/auth/google/code", queryParams: {
        "code": authCode,
      });

      return {
        'token': response.data['token'],
        'refreshToken': response.data['refreshToken'],
        'userUID': response.data['userUID'],
        'expirationDate': response.data['expirationDate']
      };

      return response.data;
    } on Exception catch (e) {
      throw Exception(e);
    }
  }

  Future<Map<String, dynamic>?> _listenForRedirects() async {
    try {
      final uriStream = await appLinks.stringLinkStream.first
          .timeout(Duration(seconds: 30), onTimeout: () async {
        throw TimeOutException(
            message: "Tiempo de espera agotado", title: "Error", content: " ");
      });
      return _extractAuthTokenFromUri(Uri.parse(uriStream));
    } catch (e) {
      developer.log('Error al escuchar redirección: ${e.toString()}');
      return null;
    }
  }

  Map<String, dynamic>? _extractAuthTokenFromUri(Uri uri) {
    final token = uri.queryParameters['token'];
    final refreshToken = uri.queryParameters['refreshToken'] ?? "NOT_FOUND";
    final userUID = uri.queryParameters['userUID'];
    final expirationDate = uri.queryParameters['expiresAt'];
    if (token == null ||
        refreshToken == null ||
        userUID == null ||
        expirationDate == null) {
      return null;
    }
    return {
      'token': token,
      'refreshToken': refreshToken,
      'userUID': userUID,
      'expirationDate': expirationDate,
    };
  }

  @override
  Future<void> logout() {
    // TODO: implement logout
    throw UnimplementedError();
  }

  @override
  Future<void> refreshToken({required String refreshToken}) {
    // TODO: implement refreshToken
    throw UnimplementedError();
  }
}
