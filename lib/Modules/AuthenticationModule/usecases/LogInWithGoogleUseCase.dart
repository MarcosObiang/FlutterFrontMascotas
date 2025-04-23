import 'package:mascotas_citas/Exceptions/ModuleException.dart';
import 'package:mascotas_citas/Modules/AuthenticationModule/DTOs/LogInDTO.dart';
import 'package:mascotas_citas/Modules/AuthenticationModule/repo/AuthenticationRepo.dart';
import 'package:mascotas_citas/Modules/AuthenticationModule/state/AuthState.dart';
import 'package:mascotas_citas/services/auth/AuthSesionDataService.dart';




class LogInWithGoogleUseCase {
  final AuthenticationRepo authenticationRepo;
  final AuthDataService authdataService;
  final AuthState authState;

  /// Constructor for the [LogInWithGoogleUseCase].
  ///
  /// Requires an [AuthenticationRepo] for handling authentication-related operations,
  /// an [AuthDataService] for managing authentication data, and an [AuthState]
  /// for managing the authentication state.
  LogInWithGoogleUseCase(
      {required this.authenticationRepo,
      required this.authdataService,
      required this.authState});

  /// Executes the login process using Google authentication.
  ///
  /// This method attempts to log in the user, store the received tokens and user data,
  /// and check if the user is already registered. It updates the [AuthState] accordingly.
  /// Returns `true` if the user is already registered, `false` otherwise.
  Future<bool> execute() async {
    authState.setAuthStateLoading();
    try {
      LoginDTO? token = await authenticationRepo.login();
      await authdataService.setToken(token?.token);
      await authdataService.setRefreshToken(token?.refreshToken);
      await authdataService.setUserUID(token?.userUID);
      await authdataService.setExpirationDate(token?.expirationDate);
      authState.setAuthStateUserLogged();

      bool isUserAlreadyRegistered =
          await authenticationRepo.isUserAlreadyRegistered();
      return isUserAlreadyRegistered;
    } catch (e) {
      ModuleException moduleException = ModuleException(
        message: "Error al iniciar sesión",
        title: "Error",
      );
      authState.setError(moduleException);
      throw moduleException;
    }
  }
} 