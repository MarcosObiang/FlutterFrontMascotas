import 'dart:typed_data';

import 'package:mascotas_citas/models/PetModel.dart';

class CreateSignUpModel {
  final UserModel user;
  final PetModel pet;
  Map<String, dynamic>? files;

  CreateSignUpModel({
    required this.user,
    required this.pet,
  });

  factory CreateSignUpModel.fromJson(Map<String, dynamic> json) {
    return CreateSignUpModel(
      user: UserModel.fromJson(json['user']),
      pet: PetModel.fromJson(json['pet']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'pet': pet.toJson(),
    };
  }

  
}
