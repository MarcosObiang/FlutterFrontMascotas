class PetModel {
  final String id;
  final String petUID;
  final String onwerUID;
  final String name;
  final String petImage1;

  final String sex;
  final String petBio;
  final DateTime birthDate;
  final String spicies;

  PetModel({
    required this.id,
    required this.petUID,
    required this.onwerUID,
    required this.name,
    required this.petImage1,

    required this.sex,
    required this.petBio,
    required this.birthDate,
    required this.spicies,
  });

  factory PetModel.fromJson(Map<String, dynamic> json) {
    return PetModel(
      id: json['id'],
      petUID: json['petUID'],
      onwerUID: json['onwerUID'],
      name: json['name'],
      petImage1: json['petImage1'],

      sex: json['sex'],
      petBio: json['petBio'],
      birthDate: DateTime.parse(json['birthDate']),
      spicies: json['spicies'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'petUID': petUID,
      'onwerUID': onwerUID,
      'name': name,
      'petImage1': petImage1,

      'sex': sex,
      'petBio': petBio,
      'birthDate': birthDate.toIso8601String(),
      'spicies': spicies,
    };
  }
}

class Location {
  final String type;
  final List<double> coordinates;

  Location({
    required this.type,
    required this.coordinates,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      type: json['type'],
      coordinates: List<double>.from(json['coordinates'].map((c) => c.toDouble())),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'coordinates': coordinates,
    };
  }
}


class UserModel {
  final String id;
  final String userUID;
  final String name;
  final String userImage1;
  final String sex;
  final Location location;
  final String userBio;
  final String datingSexPreference;
  final DateTime birthDate;

  UserModel({
    required this.id,
    required this.userUID,
    required this.name,
    required this.userImage1,
    required this.sex,
    required this.location,
    required this.userBio,
    required this.datingSexPreference,
    required this.birthDate,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      userUID: json['userUID'],
      name: json['name'],
      userImage1: json['userImage1'],
      sex: json['sex'],
      location: Location.fromJson(json['location']),
      userBio: json['userBio'],
      datingSexPreference: json['datingSexPreference'],
      birthDate: DateTime.parse(json['birthDate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userUID': userUID,
      'name': name,
      'userImage1': userImage1,
      'sex': sex,
      'location': location.toJson(),
      'userBio': userBio,
      'datingSexPreference': datingSexPreference,
      'birthDate': birthDate.toIso8601String(),
    };
  }
}
