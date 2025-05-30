// models/PetModel.dart
class PetModel {
  final String id;
  final String petUID;
  final String ownerUID;
  final String name;
  final String petImage1;
  final String? petImage2;  // Marcado como nullable
  final String? petImage3;  // Marcado como nullable
  final String sex;
  final String petBio;      // Se mantiene como final
  final DateTime birthDate;
  final String species;
  PetModel({
    required this.id,
    required this.petUID,
    required this.ownerUID,
    required this.name,
    required this.petImage1,
    this.petImage2,
    this.petImage3,
    required this.sex,
    required this.petBio,
    required this.birthDate,
    required this.species,
  });
  // Constructor copia para crear una nueva instancia con cambios
  PetModel copyWith({
    String? id,
    String? petUID,
    String? ownerUID,
    String? name,
    String? petImage1,
    String? petImage2,
    String? petImage3,
    String? sex,
    String? petBio,
    DateTime? birthDate,
    String? species,
  }) {
    return PetModel(
      id: id ?? this.id,
      petUID: petUID ?? this.petUID,
      ownerUID: ownerUID ?? this.ownerUID,
      name: name ?? this.name,
      petImage1: petImage1 ?? this.petImage1,
      petImage2: petImage2 ?? this.petImage2,
      petImage3: petImage3 ?? this.petImage3,
      sex: sex ?? this.sex,
      petBio: petBio ?? this.petBio,
      birthDate: birthDate ?? this.birthDate,
      species: species ?? this.species,
    );
  }
  factory PetModel.fromJson(Map<String, dynamic> json) {
    return PetModel(
      id: json['id'] ?? '',
      petUID: json['petUID'] ?? '',
      ownerUID: json['ownerUID'] ?? '',
      name: json['name'] ?? '',
      petImage1: json['petImage1'] ?? '',
      petImage2: json['petImage2'],
      petImage3: json['petImage3'],
      sex: json['sex'] ?? '',
      petBio: json['petBio'] ?? '',
      birthDate: json['birthDate'] != null 
        ? (json['birthDate'] is String 
            ? DateTime.parse(json['birthDate']) 
            : DateTime.fromMillisecondsSinceEpoch(json['birthDate']))
        : DateTime.now(),
      species: json['species'] ?? '',
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'petUID': petUID,
      'ownerUID': ownerUID,
      'name': name,
      'petImage1': petImage1,
      'petImage2': petImage2,
      'petImage3': petImage3,
      'sex': sex,
      'petBio': petBio,
      'birthDate': birthDate.toIso8601String(),
      'species': species,
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