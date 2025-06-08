import 'package:mascotas_citas/Modules/ProfileModule/repo/SettingsRepo.dart';
import 'package:mascotas_citas/Modules/ProfileModule/state/settingsState.dart';

class Updateuserbiousecase {
  final SettingsRepo settingsRepo;
  final SettingsState settingsState;

  Updateuserbiousecase(
      {required this.settingsRepo, required this.settingsState});

  Future<String> execute({required String userBIo}) async {
    settingsState
        .setUpdateProfileBioStatusUpdating(UpdateProfileBioStatus.updating);

    try {
      String result = await settingsRepo.updateUserBio(bio: userBIo);

      settingsState
          .setUpdateProfileBioStatusUpdating(UpdateProfileBioStatus.loaded);

      return result;
    } catch (e) {
      settingsState
          .setUpdateProfileBioStatusUpdating(UpdateProfileBioStatus.error);

      return Future.value("Error");
    }
  }
}
