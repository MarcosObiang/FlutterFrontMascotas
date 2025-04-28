import 'package:mascotas_citas/services/ApiService.dart';
import 'package:mascotas_citas/services/auth/AuthSesionDataService.dart';

abstract class SettingsRepo {
  Future<bool> logOut();
}

class SettingsRepoImpl implements SettingsRepo {
  final AuthDataService authDataService;
  final DioApiService apiService;

  SettingsRepoImpl({
    required this.authDataService,
    required this.apiService,
  });

  @override
  Future<bool> logOut() async {
    try {
      final result = apiService.get(path: "/auth/sign-out", queryParams: {});
      await authDataService.clearAll();
      return true;
    } catch (e) {
      return false;
    }
  }
}
