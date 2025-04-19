// lib/Resources/Models/mascota.dart

import 'package:intl/intl.dart';

class Mascota {
  final String id;
  final String nombre;
  final String edad;
  final String especie;
  final String raza;
  final String descripcion;
  final List<String> fotos;
  final String ubicacion;
  final List<String> intereses;
  
  // Datos del propietario
  final String? propietarioId;
  final String? propietarioNombre;
  final String? propietarioFoto;
  
  // Datos del centro de adopción
  final String? centroAdopcionId;
  final String? centroNombre;
  final String? centroFoto;
  
  // Indica si está en adopción
  final bool enAdopcion;
  
  // Constructor privado base
  const Mascota._({
    required this.id,
    required this.nombre,
    required this.edad,
    required this.especie,
    required this.raza,
    required this.descripcion,
    required this.fotos,
    required this.ubicacion,
    required this.intereses,
    this.propietarioId,
    this.propietarioNombre,
    this.propietarioFoto,
    this.centroAdopcionId,
    this.centroNombre,
    this.centroFoto,
    required this.enAdopcion,
  });
  
  // Constructor para mascota particular (no en adopción)
  factory Mascota.particular({
    required String id,
    required String nombre,
    required String edad,
    required String especie,
    required String raza,
    required String descripcion,
    required List<String> fotos,
    required String propietarioId,
    required String propietarioNombre,
    required String propietarioFoto,
    required String ubicacion,
    required List<String> intereses,
  }) {
    return Mascota._(
      id: id,
      nombre: nombre,
      edad: edad,
      especie: especie,
      raza: raza,
      descripcion: descripcion,
      fotos: fotos,
      propietarioId: propietarioId,
      propietarioNombre: propietarioNombre,
      propietarioFoto: propietarioFoto,
      ubicacion: ubicacion,
      intereses: intereses,
      enAdopcion: false,
    );
  }
  
  // Constructor para mascota particular en adopción
  factory Mascota.particularEnAdopcion({
    required String id,
    required String nombre,
    required String edad,
    required String especie,
    required String raza,
    required String descripcion,
    required List<String> fotos,
    required String propietarioId,
    required String propietarioNombre,
    required String propietarioFoto,
    required String ubicacion,
    required List<String> intereses,
  }) {
    return Mascota._(
      id: id,
      nombre: nombre,
      edad: edad,
      especie: especie,
      raza: raza,
      descripcion: descripcion,
      fotos: fotos,
      propietarioId: propietarioId,
      propietarioNombre: propietarioNombre,
      propietarioFoto: propietarioFoto,
      ubicacion: ubicacion,
      intereses: intereses,
      enAdopcion: true,
    );
  }
  
  // Constructor para mascota de centro de adopción
  factory Mascota.enAdopcion({
    required String id,
    required String nombre,
    required String edad,
    required String especie,
    required String raza,
    required String descripcion,
    required List<String> fotos,
    required String centroAdopcionId,
    required String centroNombre,
    required String centroFoto,
    required String ubicacion,
    required List<String> intereses,
  }) {
    return Mascota._(
      id: id,
      nombre: nombre,
      edad: edad,
      especie: especie,
      raza: raza,
      descripcion: descripcion,
      fotos: fotos,
      centroAdopcionId: centroAdopcionId,
      centroNombre: centroNombre,
      centroFoto: centroFoto,
      ubicacion: ubicacion,
      intereses: intereses,
      enAdopcion: true,
    );
  }
  
  // Método para crear un objeto Mascota desde el JSON de la API
  factory Mascota.fromJson(Map<String, dynamic> json, Map<String, dynamic> ownerData) {
    // Calcular la edad en años basada en la fecha de nacimiento
    final birthDate = DateTime.fromMillisecondsSinceEpoch(json['birthDate']);
    final now = DateTime.now();
    final years = now.difference(birthDate).inDays ~/ 365;
    final edadString = '$years ${years == 1 ? 'año' : 'años'}';
    
    // Convertir las URLs de imágenes en una lista de strings
    final List<String> fotos = [];
    if (json['petImage1'] != null) fotos.add(json['petImage1']);
    if (json['petImage2'] != null) fotos.add(json['petImage2']);
    if (json['petImage3'] != null) fotos.add(json['petImage3']);
    
    // Por ahora, hardcodeamos algunos datos que no vienen en la API
    final List<String> intereses = ['Paseos', 'Jugar', 'Dormir'];
    final raza = json['species'] == 'dog' ? 'Perro' : 'Gato';
    
    return Mascota.particular(
      id: json['petUID'] ?? json['ownerUID'],
      nombre: json['name'],
      edad: edadString,
      especie: json['species'] == 'dog' ? 'Perro' : 'Gato',
      raza: raza,
      descripcion: json['petBio'],
      fotos: fotos,  // Ahora es List<String> explícitamente
      propietarioId: json['ownerUID'],
      propietarioNombre: ownerData['name'] ?? 'Propietario',
      propietarioFoto: ownerData['userImage1'] ?? 'https://via.placeholder.com/150',
      ubicacion: ownerData['location'] ?? 'Desconocida',
      intereses: intereses,  // Ahora es List<String> explícitamente
    );
  }
}