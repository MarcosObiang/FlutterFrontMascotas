import 'package:logger/web.dart';
import 'package:mascotas_citas/Modules/ProfileModule/model/ProfileSettings.dart';
import 'package:mascotas_citas/Modules/ProfileModule/repo/SettingsRepo.dart';
import 'package:mascotas_citas/Modules/ProfileModule/state/settingsState.dart';
import 'package:mascotas_citas/interfaces/self_started_use_case_interface.dart';
import 'package:mascotas_citas/interfaces/usecase_interface.dart';

class Getprofiledatausecase implements UseCaseInterfacae,ISelfStartedUseCaseInterface {
  final SettingsRepo settingsRepo;
  final SettingsState settingsState;

  Getprofiledatausecase({required this.settingsRepo, required this.settingsState});
  @override
  Future execute() async {
    try {
      ProfileSettings profileSettings = await settingsRepo.getUserData();
      settingsState.setData(profileSettings);


      Logger().i(profileSettings);
    } catch (e) {
      print(e);
    }
  }
  
  @override
  Future<void> init() {
    // TODO: implement init
    execute();
    return Future.value();
  }
}
