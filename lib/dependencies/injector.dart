import 'package:get_it/get_it.dart';
import 'package:mascotas_citas/Modules/AuthenticationModule/repo/AuthenticationRepo.dart';
import 'package:mascotas_citas/Modules/AuthenticationModule/usecases/LogInWithGoogleUseCase.dart';
import 'package:mascotas_citas/Modules/AuthenticationModule/usecases/SelfLogInWithLoginUseCase.dart';
import 'package:mascotas_citas/Modules/CreateUserModule/repo/CreateUserRepo.dart';
import 'package:mascotas_citas/Modules/CreateUserModule/state/CreateUserState.dart';
import 'package:mascotas_citas/Modules/CreateUserModule/usecases/CreateUserUseCase.dart';
import 'package:mascotas_citas/Modules/ProfileModule/repo/SettingsRepo.dart';
import 'package:mascotas_citas/Modules/ProfileModule/state/settingsState.dart';
import 'package:mascotas_citas/Modules/ProfileModule/usecases/LogOutUseCase.dart';
import 'package:mascotas_citas/interfaces/auth/IAuthServices.dart';
import 'package:mascotas_citas/services/ApiService.dart';
import 'package:mascotas_citas/services/auth/AuthSesionDataService.dart';
import 'package:mascotas_citas/services/auth/WebLoginService.dart';
import 'package:mascotas_citas/services/platform/storage/LocationManager.dart';
import 'package:mascotas_citas/services/platform/storage/SecureStorage.dart';
import 'package:mascotas_citas/startter_manager.dart';

import '../Modules/AuthenticationModule/state/AuthState.dart';

final GetIt getIt = GetIt.instance;

void setUpServices() {
  getIt.registerSingleton<SecureStorage>(SecureStorage());
  getIt.registerSingleton<AuthDataService>(
      AuthDataService(secureStorage: getIt<SecureStorage>()));
  getIt.registerSingleton<DioApiService>(
      DioApiService(authDataService: getIt<AuthDataService>()));
  getIt.registerSingleton<IAuthServices>(
      WebLoginService(apiService: getIt<DioApiService>()));
  getIt.registerSingleton<LocationManager>(LocationManager());
}

void setUpStates() {
  getIt.registerSingleton<AuthState>(AuthState());
  getIt.registerSingleton<CreateUserState>(CreateUserState());
  getIt.registerSingleton<Settingsstate>(Settingsstate());
}

void setUpDependencies() {
  getIt.registerSingleton<SettingsRepo>(SettingsRepoImpl(
      authDataService: getIt<AuthDataService>(),
      apiService: getIt<DioApiService>()));
  getIt.registerSingleton<LogOutUseCase>(LogOutUseCase(
      settingsRepo: getIt<SettingsRepo>(),
      authDataService: getIt<AuthDataService>()));
  getIt.registerSingleton<AuthenticationRepo>(AuthenticationRepoImpl(
      webLoginService: getIt<IAuthServices>(),
      apiService: getIt<DioApiService>()));
  getIt.registerSingleton<CreateUserRepo>(
      CreateUserRepoImpl(apiService: getIt<DioApiService>()));

  getIt.registerSingleton<LogInWithGoogleUseCase>(LogInWithGoogleUseCase(
      authenticationRepo: getIt<AuthenticationRepo>(),
      authdataService: getIt<AuthDataService>(),
      authState: getIt<AuthState>()));
  getIt.registerSingleton<CheckIfUsserCanLogInUseCase>(
      CheckIfUsserCanLogInUseCase(authDataService: getIt<AuthDataService>()));

  getIt.registerSingleton<StarterManager>(StarterManager(
      selfLoginWithGoogleUseCase: getIt<CheckIfUsserCanLogInUseCase>(),
      starters: []));
}

Future<void> initAsyncDependencies() async {
  await getIt<AuthDataService>().loadAll();
}
