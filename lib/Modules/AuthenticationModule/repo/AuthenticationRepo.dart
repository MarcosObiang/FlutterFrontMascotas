import 'package:mascotas_citas/Modules/AuthenticationModule/DTOs/LogInDTO.dart';
import 'package:mascotas_citas/interfaces/auth/IAuthServices.dart';
import 'package:mascotas_citas/services/auth/WebLoginService.dart';

abstract class AuthenticationRepo {
  Future<LoginDTO?> login();
  Future<void> logout();
  Future<void> refreshToken({required String refreshToken});
}

class AuthenticationRepoImpl implements AuthenticationRepo {
  IAuthServices webLoginService;

  AuthenticationRepoImpl({required this.webLoginService});

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
