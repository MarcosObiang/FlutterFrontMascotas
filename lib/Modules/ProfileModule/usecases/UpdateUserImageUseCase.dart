import 'dart:typed_data';

import 'package:logger/web.dart';
import 'package:mascotas_citas/Modules/ProfileModule/repo/SettingsRepo.dart';
import 'package:mascotas_citas/Modules/ProfileModule/state/settingsState.dart';

class Updateuserimageusecase {
  final SettingsRepo settingsRepo;
  final SettingsState settingsState;


  Updateuserimageusecase({required this.settingsRepo, required this.settingsState});

  Future<String> execute(Uint8List imageData) async {
          settingsState.setUpdateProfilePictureStatusUpdating(UpdateProfilePictureStatus.updating);

    try {
      String result = await settingsRepo.updaateUserPicture(picture: imageData);
      settingsState.setUpdateProfilePictureStatusUpdating(UpdateProfilePictureStatus.loaded);
      return result;
    } catch (e) {
      
      Logger().e(e.toString());

      rethrow;
    }
  }
}
