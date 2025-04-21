class Usuario {
  final String userUID;
  final String name;
  final String userImage1;
  final String sex;
  final String userBio;
  final int birthDate;

  Usuario({
    required this.userUID,
    required this.name,
    required this.userImage1,
    required this.sex,
    required this.userBio,
    required this.birthDate,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      userUID: json['userUID'] ?? '',
      name: json['name'] ?? '',
      userImage1: json['userImage1'] ?? '',
      sex: json['sex'] ?? '',
      userBio: json['userBio'] ?? '',
      birthDate: json['birthDate'] ?? 0,
    );
  }

  // Helper getters to match expected fields in the UI
  String get nombre => name;
  String get fotoPerfil => userImage1;
  String get sexo => sex;
  String get bio => userBio;
  String get ubicacion => "No disponible"; // Add location if available in API
  
  // Calculate age from birthDate (milliseconds since epoch)
  String get edad {
    if (birthDate == 0) return "No disponible";
    final birthDateTime = DateTime.fromMillisecondsSinceEpoch(birthDate);
    final currentDate = DateTime.now();
    int age = currentDate.year - birthDateTime.year;
    if (currentDate.month < birthDateTime.month || 
        (currentDate.month == birthDateTime.month && currentDate.day < birthDateTime.day)) {
      age--;
    }
    return age.toString();
  }
}