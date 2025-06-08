import 'dart:ffi';
import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:mascotas_citas/utils/GetUriFromString.dart';

class ProfileSettings extends Equatable {
  String name;
  String userImage1;
  String userBio;
  int age=0;
  String sex="";
  DateTime birthDate;
  Uint8List? image;




  ProfileSettings(
      {required this.name, required this.userImage1, required this.userBio,required this.birthDate});

  @override
  // TODO: implement props
  List<Object> get props => [name, userImage1];

  factory ProfileSettings.fromMap(Map<String, dynamic> map) {
    return ProfileSettings(
      name: map['name'] as String,
      userImage1: map['userImage1'] as String,
      userBio: map['userBio'] as String,
      birthDate: DateTime.fromMillisecondsSinceEpoch(map['birthDate']),
    )..calculateAge()..generateValidImageUri();
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'userImage1': userImage1,
      'userBio': userBio,
    };
  }

  @override
  String toString() {
    return 'ProfileSettings{name: $name, userImage1: $userImage1, userBio: $userBio}';
  }


  void calculateAge() {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    this.age = age;
  }


  void generateValidImageUri() {
    if (userImage1.isNotEmpty) {
      this.userImage1=Geturifromstring().getUriFromString(userImage1);
    }
  }


}
