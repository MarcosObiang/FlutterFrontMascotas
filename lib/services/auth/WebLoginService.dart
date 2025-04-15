import 'dart:developer' as developer;
import 'package:mascotas_citas/const_values/const_values.dart';
import 'package:mascotas_citas/interfaces/auth/IAuthServices.dart';
import 'package:uni_links/uni_links.dart';
import 'package:url_launcher/url_launcher_string.dart';

class WebLoginService implements IAuthServices {
  @override
  Future<Map<String, dynamic>?> login() async {
    try {
      await launchUrlString(ConstValues.loginUrl);
      return await _listenForRedirects();
    } catch (e) {
      developer.log('Error en login: ${e.toString()}');
      return null;
    }
  }

  Future<Map<String, dynamic>?> _listenForRedirects() async {
    try {

      // Escucha el stream de URIs
      final uriStream = await uriLinkStream.first;
      return _extractAuthTokenFromUri(uriStream!);
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
