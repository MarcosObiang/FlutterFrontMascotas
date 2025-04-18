import 'package:get_it/get_it.dart';
import 'package:mascotas_citas/Modules/AuthenticationModule/repo/AuthenticationRepo.dart';
import 'package:mascotas_citas/Modules/AuthenticationModule/usecases/LogInWithGoogleUseCase.dart';
import 'package:mascotas_citas/interfaces/auth/IAuthServices.dart';
import 'package:mascotas_citas/services/ApiService.dart';
import 'package:mascotas_citas/services/auth/AuthSesionDataService.dart';
import 'package:mascotas_citas/services/auth/WebLoginService.dart';
import 'package:mascotas_citas/services/platform/storage/SecureStorage.dart';

import '../Modules/AuthenticationModule/state/AuthState.dart';

final GetIt getIt = GetIt.instance;

void setUpServices() {
  getIt.registerSingleton<SecureStorage>(SecureStorage());
  getIt.registerSingleton<AuthDataService>(
      AuthDataService(secureStorage: getIt<SecureStorage>()));
  getIt.registerSingleton<ApiService>(
      ApiService(authDataService: getIt<AuthDataService>()));
  getIt.registerSingleton<IAuthServices>(
      WebLoginService(apiService: getIt<ApiService>()));
}

void setUpStates() {
  getIt.registerSingleton<AuthState>(AuthState());
}

void setUpDependencies() {
  getIt.registerSingleton<AuthenticationRepo>(
      AuthenticationRepoImpl(webLoginService: getIt<IAuthServices>()));

  getIt.registerSingleton<LogInWithGoogleUseCase>(LogInWithGoogleUseCase(
      authenticationRepo: getIt<AuthenticationRepo>(),
      authdataService: getIt<AuthDataService>(),
      authState: getIt<AuthState>()));
}
