import 'dart:convert';
import 'dart:typed_data';

import 'package:mascotas_citas/Modules/ProfileModule/model/PetSettingsModel.dart';
import 'package:mascotas_citas/Modules/ProfileModule/model/ProfileSettings.dart';
import 'package:mascotas_citas/services/ApiService.dart';
import 'package:mascotas_citas/services/auth/AuthSesionDataService.dart';

abstract class SettingsRepo {
  Future<bool> logOut();
  Future<ProfileSettings> getUserData();
  Future<List<PetSettingsModel>> getPetData();
  Future<String> updaateUserPicture({required Uint8List picture});
  Future<String> updateUserBio({required String bio});
  Future<String> addPet({required PetSettingsModel pet});
}

class SettingsRepoImpl implements SettingsRepo {
  final AuthDataService authDataService;
  final DioApiService apiService;

  SettingsRepoImpl({
    required this.authDataService,
    required this.apiService,
  });

  @override
  Future<bool> logOut() async {
    try {
      final result = apiService.get(path: "/auth/sign-out", queryParams: {});
      await authDataService.clearAll();
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<PetSettingsModel>> getPetData() async {
    List<PetSettingsModel> pets = [];

    final response = await apiService.get(
        path: "/pets-service/pets/get-pet-data-by-owner",
        queryParams: {"ownerUID": authDataService.userUID});

    if (response.statusCode != 200) {
      throw Exception("Error al obtener los datos del usuario");
    }
    if (response.data == null) {
      throw Exception("Error al obtener los datos del usuario");
    }

    if (response.data is! List) {
      throw Exception("Error al obtener los datos del usuario");
    }

    for (int i = 0; i < response.data.length; i++) {
      pets.add(PetSettingsModel.fromMap(response.data[i]));
    }

    return pets;
  }

  @override
  Future<ProfileSettings> getUserData() async {
    final response =
        await apiService.get(path: "/user-service/users/get", queryParams: {});
    if (response.statusCode == 200) {
      return ProfileSettings.fromMap(response.data);
    } else {
      throw Exception("Error al obtener los datos del usuario");
    }
  }

  @override
  Future<String> updaateUserPicture({required Uint8List picture}) async {
    final response = await apiService
        .post(path: "/orquestador/api/users/update-image", data: {}, files: {
      "userImage": picture,
    });
    if (response.statusCode == 200) {
      return "OK";
    } else {
      throw Exception("Error al acctualizar la imagen del usuario");
    }
  }

  @override
  Future<String> updateUserBio({required String bio}) async {
    final response = await apiService.put(
        path: "/user-service/users/update-bio",
        data: {"userBio": bio, "userUID": authDataService.userUID});
    if (response.statusCode == 200) {
      return "OK";
    } else {
      throw Exception("Error al accctualizar la bio del usuario");
    }
  }

  @override
  Future<String> addPet({required PetSettingsModel pet}) async {
    final response = await apiService.post(
        path: "/orquestador/api/pets/create",
        data: { "petJson":jsonEncode(pet.toMap())},
        files: {"petImage1": pet.image});
    if (response.statusCode == 200) {
      return "OK";
    } else {
      throw Exception("Error al accctualizar la bio del usuario");
    }
  }
}
