
import 'dart:typed_data';

import 'package:mascotas_citas/Exceptions/ModuleException.dart';
import 'package:mascotas_citas/Modules/CreateUserModule/model/CreateUserModel.dart';
import 'package:mascotas_citas/Modules/CreateUserModule/repo/CreateUserRepo.dart';
import 'package:mascotas_citas/Modules/CreateUserModule/state/CreateUserState.dart';
import 'package:mascotas_citas/models/PetModel.dart';
import 'package:mascotas_citas/services/platform/storage/LocationManager.dart';

class SignUpUseCase {
  final CreateUserRepo createUserRepo;
  final LocationManager locationManager;
  final CreateUserState createUserState;

  SignUpUseCase(
      {required this.createUserRepo,
      required this.locationManager,
      required this.createUserState});

  Future<void> execute({
    required String userUID,
    required String userName,
    required String userSex,
    required DateTime userBirthDate,
    required String userBio,
    required String datingSexPreference,
    required String petUID,
    required String petName,
    required String petSex,
    required DateTime petBirthDate,
    required String petBio,
    required String petSpecies,
    required Uint8List userImage,
    required Uint8List petImage,
  }) async {
    createUserState.setCreateUserLoadingStatus();

    try {
      final user = UserModel(
        id: 'persona', // se puede autogenerar o asignar en el backend
        userUID: userUID,
        name: userName,
        sex: userSex,
        birthDate: userBirthDate,
        userBio: userBio,
        datingSexPreference: datingSexPreference,
        location: await locationManager.getCurrentLocation(),
        userImage1: '',
      );

      final pet = PetModel(
        id: 'mascota',
        petUID: petUID,
        onwerUID: userUID,
        name: petName,
        sex: petSex,
        birthDate: petBirthDate,
        petBio: petBio,
        spicies: petSpecies,
        petImage1: '',
      );

      final signUpModel = CreateSignUpModel(user: user, pet: pet)
        ..files = {'userImage1': userImage, 'petImage1': petImage};

      await createUserRepo.createUser(signUpModel);
      createUserState.setCreateUserStatusSuccess();
    } catch (e) {
      ModuleException moduleException = ModuleException(
        message: e.toString(),
        title: "Error",
      );

      createUserState.setCreateUserErrorStatus();
    }
  }
}
