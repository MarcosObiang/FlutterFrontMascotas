import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:mascotas_citas/utils/GetUriFromString.dart';

class PetSettingsModel extends Equatable {
  String petUID;
  String ownerUID;
  String petImageUID;
  String name;
  String species;
  String sex;
  DateTime birthDate;
  int age;
  String petBio;
  Uint8List? image;

  PetSettingsModel(
      {required this.petUID,
      required this.ownerUID,
      required this.name,
      required this.species,
      required this.petImageUID,
      required this.sex,
      required this.birthDate,
      required this.age,
      required this.petBio});

  @override
  List<Object> get props => [name, species, age];

  factory PetSettingsModel.fromMap(Map<String, dynamic> map) {
    return PetSettingsModel(
      petUID: map['petUID'] as String,
      ownerUID: map['ownerUID'] as String,
      name: map['name'] as String,
      species: map['species'] as String,
      petImageUID: map['petImage1'] as String,
      sex: map['sex'] as String,
      birthDate: DateTime.fromMillisecondsSinceEpoch(map['birthDate']),
      age: 0,
      petBio: map['petBio'] as String,
    )..generateValidImageUri();
  }

  Map<String, dynamic> toMap() {
    return {
      'petUID': petUID,
      'ownerUID': "ownerUID",
      'name': name,
      'species': species,
      'sex': sex,
      'birthDate': birthDate.toIso8601String(),
      "petImage1": "petImageUID",
      'petBio': petBio,
    };
  }

  void generateValidImageUri() {
    if (petImageUID.isNotEmpty) {
      this.petImageUID = Geturifromstring().getUriFromString(petImageUID);
    }
  }

  @override
  String toString() {
    return "PetSettingsModel(petUID: $petUID, ownerUID: $ownerUID, name: $name, species: $species, sex: $sex, birthDate: $birthDate, age: $age, petBio: $petBio)";
  }
}
