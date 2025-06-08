import 'package:mascotas_citas/Modules/ProfileModule/repo/SettingsRepo.dart';
import 'package:mascotas_citas/Modules/ProfileModule/starter/ProfileModuleStarter.dart';
import 'package:mascotas_citas/Modules/ProfileModule/state/settingsState.dart';
import 'package:mascotas_citas/Modules/ProfileModule/usecases/AddPetUseCase.dart';
import 'package:mascotas_citas/Modules/ProfileModule/usecases/GetPetsDataUseCase.dart';
import 'package:mascotas_citas/Modules/ProfileModule/usecases/GetProfileDataUseCase.dart';
import 'package:mascotas_citas/Modules/ProfileModule/usecases/LogOutUseCase.dart';
import 'package:mascotas_citas/Modules/ProfileModule/usecases/UpdateUserBioUseCase.dart';
import 'package:mascotas_citas/Modules/ProfileModule/usecases/UpdateUserImageUseCase.dart';
import 'package:mascotas_citas/dependencies/injector.dart';
import 'package:mascotas_citas/services/ApiService.dart';
import 'package:mascotas_citas/services/auth/AuthSesionDataService.dart';

class ProfileSettingsModuleInjector {
  static void init() {
    getIt.registerSingleton<SettingsState>(SettingsState());

    getIt.registerSingleton<SettingsRepo>(SettingsRepoImpl(
      apiService: getIt.get<DioApiService>(),
      authDataService: getIt.get<AuthDataService>(),
    ));

    getIt.registerSingleton<Getprofiledatausecase>(Getprofiledatausecase(
      settingsRepo: getIt.get<SettingsRepo>(),
      settingsState: getIt.get<SettingsState>(),
    ));

        getIt.registerSingleton<Addpetusecase>(Addpetusecase(
      settingsRepo: getIt.get<SettingsRepo>(),
      settingsState: getIt.get<SettingsState>(),
    ));


    getIt.registerSingleton<Updateuserimageusecase>(Updateuserimageusecase(
      settingsRepo: getIt.get<SettingsRepo>(),
      settingsState: getIt.get<SettingsState>(),
    ));

        getIt.registerSingleton<Updateuserbiousecase>(Updateuserbiousecase(
      settingsRepo: getIt.get<SettingsRepo>(),
      settingsState: getIt.get<SettingsState>(),
    ));

    getIt.registerSingleton<LogOutUseCase>(LogOutUseCase(
        settingsRepo: getIt<SettingsRepo>(),
        authDataService: getIt<AuthDataService>()));

    getIt.registerSingleton<Getpetsdatausecase>(Getpetsdatausecase(
      settingsRepo: getIt.get<SettingsRepo>(),
      settingsState: getIt.get<SettingsState>(),
    ));

    getIt.registerSingleton<Profilemodulestarter>(
        Profilemodulestarter(useCases: [
      getIt.get<Getprofiledatausecase>(),
      getIt.get<Getpetsdatausecase>(),
    ], settingsState: getIt.get<SettingsState>()));
  }
}
