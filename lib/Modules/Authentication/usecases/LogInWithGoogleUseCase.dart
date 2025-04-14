import 'package:mascotas_citas/Exceptions/ModuleException.dart';
import 'package:mascotas_citas/Modules/Authentication/DTOs/LogInDTO.dart';
import 'package:mascotas_citas/Modules/Authentication/repo/AuthenticationRepo.dart';
import 'package:mascotas_citas/Modules/Authentication/state/AuthState.dart';
import 'package:mascotas_citas/services/auth/AuthSesionDataService.dart';

class LogInWithGoogleUseCase {
  final AuthenticationRepo authenticationRepo;
  final AuthDataService authdataService;
  final AuthState authState;

  LogInWithGoogleUseCase(
      {required this.authenticationRepo,
      required this.authdataService,
      required this.authState});

  Future<void> execute() async {

    authState.setAuthStateLoading();
    try {
      LoginDTO? token = await authenticationRepo.login();
      // await authdataService.setToken(token?.token);
      // await authdataService.setRefreshToken(token?.refreshToken);
      // await authdataService.setUserUID(token?.userUID);
      // await authdataService.setExpirationDate(token?.expirationDate);
      authState.setAuthStateUserLogged();

    } on Exception catch (e) {
      ModuleException moduleException = ModuleException(
          message: "Error al iniciar sesión",
          title: "Error",
          content: "Ha ocurrido un error al iniciar sesión");
      authState.setError(moduleException);
    }
  }
}
