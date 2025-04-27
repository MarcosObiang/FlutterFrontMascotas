import 'package:dio/dio.dart';
import 'package:mascotas_citas/Modules/AuthenticationModule/DTOs/LogInDTO.dart';
import 'package:mascotas_citas/interfaces/auth/IAuthServices.dart';
import 'package:mascotas_citas/services/ApiService.dart';
import 'package:mascotas_citas/services/auth/WebLoginService.dart';

abstract class AuthenticationRepo {
  Future<LoginDTO?> login();
  Future<bool> isUserAlreadyRegistered();
  Future<void> logout();
  Future<void> refreshToken({required String refreshToken});
}

class AuthenticationRepoImpl implements AuthenticationRepo {
  IAuthServices webLoginService;
  ApiService apiService;

  AuthenticationRepoImpl(
      {required this.webLoginService, required this.apiService});

  @override
  Future<LoginDTO?> login() async {
    Map<String, dynamic>? loginData = await webLoginService.login();
    if (loginData != null) {
      return LoginDTO.fromJson(loginData);
    } else {
      return null;
    }
  }

  @override

  /// Comprueba si el usuario ya está registrado en el backend.
  ///
  /// El backend extrae el [userUID] directamente del token de autenticación enviado en la cabecera.
  ///
  /// Retorna `true` si el usuario está registrado, `false` si no.
  Future<bool> isUserAlreadyRegistered() async {
    Response<dynamic> response =
        await apiService.get(path: "/auth/is-user-registered", queryParams: {});

    if (response.statusCode == 200) {
      if (response.data is bool) {
        return response.data;
      } else {
        throw Exception("Error: El formato de la respuesta no es un booleano");
      }
    } else {
      throw Exception("Error: ${response.statusCode}");
    }
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
