import 'package:mascotas_citas/Modules/ProfileModule/repo/SettingsRepo.dart';
import 'package:mascotas_citas/interfaces/usecase_interface.dart';
import 'package:mascotas_citas/services/auth/AuthSesionDataService.dart';

class LogOutUseCase implements UseCaseInterfacae<bool> {
  final SettingsRepo settingsRepo;
  final AuthDataService authDataService;
  LogOutUseCase({required this.settingsRepo, required this.authDataService});

  @override
  Future<bool> execute() async {
    await settingsRepo.logOut();
    await authDataService.clearAll();
    return true;
  }
}
