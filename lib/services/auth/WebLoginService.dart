import 'dart:developer' as developer;
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:mascotas_citas/Exceptions/ModuleException.dart';
import 'package:mascotas_citas/Exceptions/TimeOutException.dart';
import 'package:mascotas_citas/const_values/const_values.dart';
import 'package:mascotas_citas/interfaces/auth/IAuthServices.dart';
import 'package:app_links/app_links.dart';
import 'package:mascotas_citas/services/ApiService.dart';
import 'package:url_launcher/url_launcher_string.dart';

// Esta clase implementa el login con Google en aplicaciones Flutter Web.
class WebLoginService implements IAuthServices {
  // Instancias necesarias: una para los enlaces y otra para autenticación web.
  final appLinks = AppLinks();
  final FlutterWebAuth2 appAuth = FlutterWebAuth2();
  ApiService apiService;

  // Constructor que recibe el servicio de API para hacer llamadas al backend.
  WebLoginService({required this.apiService});

  // Método principal para iniciar sesión
  @override
  Future<Map<String, dynamic>?> login() async {
    try {
      // URL base del endpoint de autorización de Google
      final authorizationEndpoint =
          Uri.parse('https://accounts.google.com/o/oauth2/v2/auth');

      // Scope que define los permisos que queremos (nombre, foto, correo)
      final scope = 'profile email';

      // Construimos la URL de autorización con parámetros necesarios
      final authorizationUrl = authorizationEndpoint.replace(queryParameters: {
        'client_id': ConstValues.googleClientId,
        'redirect_uri': ConstValues.redirectUrl,
        'response_type': 'code',
        'scope': scope,
        // Puedes añadir 'state' para mayor seguridad
      });

      // Imprime la URL que se abrirá en el navegador
      print(authorizationUrl.toString());

      // Abre el navegador para que el usuario se autentique con su cuenta de Google
      final result = await FlutterWebAuth2.authenticate(
        url: authorizationUrl.toString(),
        callbackUrlScheme: 'com.example.mascotascitas', // Tu esquema de redirección personalizado
        options: FlutterWebAuth2Options(useWebview: false),
      );

      // Si el usuario completó el login, extraemos el código de autorización
      if (result != null) {
        print('Código de autorización recibido: ${result}');
        String authCode = _getAuthCode(result);

        // Se envía el código al backend para intercambiarlo por un token
        return _getAccessToken(authCode);
      } else {
        print('Autorización fallida o cancelada');
      }
    } catch (e) {
      print('Error al iniciar sesión: $e');
    }
  }

  // Método auxiliar para extraer el código de autorización desde la URL devuelta
  String _getAuthCode(String uriString) {
    Uri uri = Uri.parse(uriString);
    String code = uri.queryParameters['code']!;
    return code;
  }

  // Método que llama a tu backend con el código para obtener el token y demás datos del usuario
  Future<Map<String, dynamic>> _getAccessToken(String authCode) async {
    try {
      final response =
          await apiService.get(path: "/auth/google/code", queryParams: {
        "code": authCode,
      });

      // Extraemos los datos importantes de la respuesta del backend
      Map<String, dynamic> result = {
        'token': response.data['data']['token'],
        'refreshToken': response.data['data']['token'], // parece que se repite el token aquí  pero es para que cuando elijamos si queiremos logica de refresco mas adelante, por ahora vale para ir trando
        'userUID': response.data['data']['userUID'],
        'expirationDate': response.data['data']['expiresAt'],
      };

      return result;

    } on Exception catch (e) {
      throw Exception(e);
    }
  }





  // Métodos aún no implementados para logout y refresco del token
  @override
  Future<void> logout() {
    throw UnimplementedError();
  }

  @override
  Future<void> refreshToken({required String refreshToken}) {
    throw UnimplementedError();
  }
}
