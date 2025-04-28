import 'package:mascotas_citas/interfaces/self_started_use_case_interface.dart';
import 'package:mascotas_citas/interfaces/usecase_interface.dart';
import 'package:mascotas_citas/services/auth/AuthSesionDataService.dart';

///
///
/// This class is responsible for checking if the user can log in.
/// It checks if the user is already logged in and if the token is still valid.
/// It uses the `AuthDataService` to get the authentication data.
/// If the user is logged in and the token is still valid, it returns `true`.
/// Otherwise, it returns `false`.
class CheckIfUsserCanLogInUseCase implements UseCaseInterfacae<bool> {
  AuthDataService authDataService;
  CheckIfUsserCanLogInUseCase({required this.authDataService});
  @override
  Future<bool> execute() async {
    bool isUserLogged = await _isAuthDataInMemory();
    if (isUserLogged) {
      final isTokenStillValid = await _isTokenStillValid();
      return isTokenStillValid;
    } else {
      return false;
    }
  }

  /// Check if the user is logged in
  /// This method checks if the user is logged in by verifying the presence of
  /// the token, refresh token, user UID, and expiration date in the auth data service.
  /// It returns `true` if all values are present, and `false` otherwise.
  /// If any of the values are null, it returns `false`.
  ///

  Future<bool> _isAuthDataInMemory() async {
    String? token = authDataService.getToken();
    String? refreshToken = authDataService.getRefreshToken();
    String? userUID = authDataService.getUserUID();
    DateTime? expirationDate = authDataService.getExpirationDate();

    if (token != null &&
        refreshToken != null &&
        userUID != null &&
        expirationDate != null) {
      return true;
    } else {
      return false;
    }
  }

  /// Check if the token is still valid
  /// This method checks if the token is still valid by comparing the expiration date
  /// with the current date and time.
  /// It returns `true` if the token is still valid, and `false` otherwise.
  /// If the expiration date is null, it returns `false`.
  ///
  Future<bool> _isTokenStillValid() async {
    DateTime? expirationDate = authDataService.getExpirationDate();
    if (expirationDate != null) {
      return expirationDate
          .isAfter(DateTime.now().subtract(const Duration(hours: 1)));
    } else {
      return false;
    }
  }
}
