import 'dart:typed_data';


class CreateUserModel {
  final String name;
  final Uint8List image1;
  final Uint8List image2;
  final Uint8List image3;
  final String sex;
  final String userBio;
  final String datingSexPreference;
  final String birthDateISO;

  CreateUserModel({
    required this.name,
    required this.image1,
    required this.image2,
    required this.image3,
    required this.sex,
    required this.userBio,
    required this.datingSexPreference,
    required this.birthDateISO,
  });
}
