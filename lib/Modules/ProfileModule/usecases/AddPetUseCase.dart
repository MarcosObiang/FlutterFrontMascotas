import 'package:mascotas_citas/Modules/ProfileModule/model/PetSettingsModel.dart';
import 'package:mascotas_citas/Modules/ProfileModule/repo/SettingsRepo.dart';
import 'package:mascotas_citas/Modules/ProfileModule/state/settingsState.dart';

class Addpetusecase {
  final SettingsRepo settingsRepo;
  final SettingsState settingsState;

  Addpetusecase({required this.settingsRepo, required this.settingsState});

  Future<String> execute(PetSettingsModel petSettingsModel) async {
    try {
      String result = await settingsRepo.addPet(pet: petSettingsModel);

      return result;
    } catch (e) {
      print(e);
      return Future.value("Error");
    }
  }
}
