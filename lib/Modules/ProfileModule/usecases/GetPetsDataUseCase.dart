import 'package:logger/web.dart';
import 'package:mascotas_citas/Modules/ProfileModule/model/PetSettingsModel.dart';
import 'package:mascotas_citas/Modules/ProfileModule/repo/SettingsRepo.dart';
import 'package:mascotas_citas/Modules/ProfileModule/state/settingsState.dart';
import 'package:mascotas_citas/interfaces/self_started_use_case_interface.dart';
import 'package:mascotas_citas/interfaces/usecase_interface.dart';

class Getpetsdatausecase implements UseCaseInterfacae,ISelfStartedUseCaseInterface {
  final SettingsRepo settingsRepo;
  final SettingsState settingsState;


  Getpetsdatausecase({required this.settingsRepo,required this.settingsState});

  @override
  Future execute() async {
    try {
      List<PetSettingsModel> petSettingsList = await settingsRepo.getPetData();
      Logger().i(petSettingsList.toString());
      settingsState.setData(petSettingsList);
    } catch (e) {
      Logger().e(e.toString());
    }
  }
  
  @override
  Future<void> init() {
    // TODO: implement init
    execute();
    return Future.value();
   
  }
}
