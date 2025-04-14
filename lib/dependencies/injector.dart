import 'package:get_it/get_it.dart';
import 'package:mascotas_citas/Modules/Authentication/repo/AuthenticationRepo.dart';
import 'package:mascotas_citas/Modules/Authentication/usecases/LogInWithGoogleUseCase.dart';
import 'package:mascotas_citas/interfaces/auth/IAuthServices.dart';
import 'package:mascotas_citas/services/auth/AuthSesionDataService.dart';
import 'package:mascotas_citas/services/auth/WebLoginService.dart';
import 'package:mascotas_citas/services/platform/storage/SecureStorage.dart';

import '../Modules/Authentication/state/AuthState.dart';

final GetIt getIt = GetIt.instance;

void setUpServices(){
  getIt.registerSingleton<IAuthServices>(WebLoginService());
  getIt.registerSingleton<SecureStorage>(SecureStorage());
  getIt.registerSingleton<AuthDataService>(AuthDataService(secureStorage: getIt<SecureStorage>()));
}


void setUpStates(){
  getIt.registerSingleton<AuthState>(AuthState());
}



void setUpDependencies() {
  getIt.registerSingleton<AuthenticationRepo>(
      AuthenticationRepoImpl(webLoginService: getIt<IAuthServices>()));

  getIt.registerSingleton<LogInWithGoogleUseCase>(
      LogInWithGoogleUseCase(authenticationRepo: getIt<AuthenticationRepo>(), authdataService: getIt<AuthDataService>(), authState: getIt<AuthState>()));
}
