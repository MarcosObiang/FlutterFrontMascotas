// lib/Resources/Models/usuario.dart

class Usuario {
  final String id;
  final String nombre;
  final String? foto;
  final String? sexo;
  final String? bio;
  final DateTime? fechaNacimiento;
  final String? ubicacion;

  Usuario({
    required this.id,
    required this.nombre,
    this.foto,
    this.sexo,
    this.bio,
    this.fechaNacimiento,
    this.ubicacion,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['userUID'],
      nombre: json['name'],
      foto: json['userImage1'],
      sexo: json['sex'],
      bio: json['userBio'],
      fechaNacimiento: json['birthDate'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(json['birthDate']) 
          : null,
      ubicacion: json['location'],
    );
  }
}