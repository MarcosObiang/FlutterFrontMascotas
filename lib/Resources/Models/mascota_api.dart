// lib/Resources/Models/mascota.dart


class Mascota {
  // Core properties
  final String id;
  final String nombre;
  final String sexo;
  final String descripcion;
  final String especie;
  final String raza;
  final List<String> fotos;
  final String ubicacion;
  final List<String> intereses;
  final bool enAdopcion;
  
  // API properties
  final String ownerUID;
  final String petImage1;
  final String petImage2;
  final String petImage3;
  final String sex;
  final String petBio;
  final String species;
  final int birthDate;
  
  // Datos del propietario
  final String? propietarioId;
  final String propietarioNombre;
  final String propietarioFoto;
  
  // Datos del centro de adopción
  final String? centroAdopcionId;
  final String? centroNombre;
  final String? centroFoto;

  // Constructor privado base
  const Mascota._({
    required this.id,
    required this.nombre,
    required this.sexo,
    required this.especie,
    required this.raza,
    required this.descripcion,
    required this.fotos,
    required this.ubicacion,
    required this.intereses,
    required this.enAdopcion,
    required this.ownerUID,
    required this.petImage1,
    required this.petImage2,
    required this.petImage3,
    required this.sex,
    required this.petBio,
    required this.species,
    required this.birthDate,
    this.propietarioId,
    required this.propietarioNombre,
    required this.propietarioFoto,
    this.centroAdopcionId,
    this.centroNombre,
    this.centroFoto,
  });
  
  // Constructor para mascota particular (no en adopción)
  factory Mascota.particular({
    required String id,
    required String nombre,
    required String sexo,
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
      sexo: sexo,
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
      ownerUID: propietarioId,
      petImage1: fotos.isNotEmpty ? fotos[0] : '',
      petImage2: fotos.length > 1 ? fotos[1] : '',
      petImage3: fotos.length > 2 ? fotos[2] : '',
      sex: sexo,
      petBio: descripcion,
      species: especie,
      birthDate: 0, // Default value when not available
    );
  }
  
  // Constructor para mascota particular en adopción
  factory Mascota.particularEnAdopcion({
    required String id,
    required String nombre,
    required String sexo,
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
      sexo: sexo,
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
      ownerUID: propietarioId,
      petImage1: fotos.isNotEmpty ? fotos[0] : '',
      petImage2: fotos.length > 1 ? fotos[1] : '',
      petImage3: fotos.length > 2 ? fotos[2] : '',
      sex: sexo,
      petBio: descripcion,
      species: especie,
      birthDate: 0, // Default value when not available
    );
  }
  
  // Constructor para mascota de centro de adopción
  factory Mascota.enAdopcion({
    required String id,
    required String nombre,
    required String sexo,
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
      sexo: sexo,
      especie: especie,
      raza: raza,
      descripcion: descripcion,
      fotos: fotos,
      propietarioId: null,
      propietarioNombre: centroNombre,
      propietarioFoto: centroFoto,
      centroAdopcionId: centroAdopcionId,
      centroNombre: centroNombre,
      centroFoto: centroFoto,
      ubicacion: ubicacion,
      intereses: intereses,
      enAdopcion: true,
      ownerUID: centroAdopcionId,
      petImage1: fotos.isNotEmpty ? fotos[0] : '',
      petImage2: fotos.length > 1 ? fotos[1] : '',
      petImage3: fotos.length > 2 ? fotos[2] : '',
      sex: sexo,
      petBio: descripcion,
      species: especie,
      birthDate: 0, // Default value when not available
    );
  }
  
  // Constructor directo para API
  factory Mascota({
    required String id,
    required String ownerUID,
    required String name,
    required String petImage1,
    required String petImage2,
    required String petImage3,
    required String sex,
    required String petBio,
    required String species,
    required int birthDate,
    bool enAdopcion = false,
    required List<String> intereses,
    required String propietarioNombre,
    required String propietarioFoto,
    required String ubicacion,
  }) {
    List<String> fotos = [];
    if (petImage1.isNotEmpty) fotos.add(petImage1);
    if (petImage2.isNotEmpty) fotos.add(petImage2);
    if (petImage3.isNotEmpty) fotos.add(petImage3);

    return Mascota._(
      id: id,
      nombre: name,
      sexo: sex,
      especie: species,
      raza: "", // Default empty value
      descripcion: petBio,
      fotos: fotos,
      ubicacion: ubicacion,
      intereses: intereses,
      enAdopcion: enAdopcion,
      ownerUID: ownerUID,
      petImage1: petImage1,
      petImage2: petImage2,
      petImage3: petImage3,
      sex: sex,
      petBio: petBio,
      species: species,
      birthDate: birthDate,
      propietarioId: ownerUID,
      propietarioNombre: propietarioNombre,
      propietarioFoto: propietarioFoto,
    );
  }
  
  // Create an empty Mascota for forms
  factory Mascota.empty({
    required String propietarioId,
    required String propietarioNombre,
    required String propietarioFoto,
    required String ubicacion,
  }) {
    return Mascota(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      ownerUID: propietarioId,
      name: '',
      petImage1: '',
      petImage2: '',
      petImage3: '',
      sex: '',
      petBio: '',
      species: '',
      birthDate: 0,
      enAdopcion: false,
      intereses: [],
      propietarioNombre: propietarioNombre,
      propietarioFoto: propietarioFoto,
      ubicacion: ubicacion,
    );
  }

  // Método para crear un objeto Mascota desde el JSON de la API
  factory Mascota.fromJson(Map<String, dynamic> json) {
    return Mascota(
      id: json['petUID'] ?? json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      ownerUID: json['ownerUID'] ?? '',
      name: json['name'] ?? '',
      petImage1: json['petImage1'] ?? '',
      petImage2: json['petImage2'] ?? '',
      petImage3: json['petImage3'] ?? '',
      sex: json['sex'] ?? '',
      petBio: json['petBio'] ?? '',
      species: json['species'] ?? '',
      birthDate: json['birthDate'] ?? 0,
      intereses: List<String>.from(json['interests'] ?? []),
      propietarioNombre: json['ownerName'] ?? '',
      propietarioFoto: json['ownerImage'] ?? '',
      ubicacion: json['location'] ?? 'No disponible',
    );
  }
  
  // Legacy fromJson for compatibility with old code
  factory Mascota.fromJsonWithOwner(Map<String, dynamic> json, Map<String, dynamic> ownerData) {
    // Calcular la edad en años basada en la fecha de nacimiento
    final birthDate = json['birthDate'] != null ? 
        DateTime.fromMillisecondsSinceEpoch(json['birthDate']) : 
        DateTime.now();
    final now = DateTime.now();
    final years = now.difference(birthDate).inDays ~/ 365;
    
    // Convertir las URLs de imágenes en una lista de strings
    final List<String> fotos = [];
    if (json['petImage1'] != null && json['petImage1'].isNotEmpty) fotos.add(json['petImage1']);
    if (json['petImage2'] != null && json['petImage2'].isNotEmpty) fotos.add(json['petImage2']);
    if (json['petImage3'] != null && json['petImage3'].isNotEmpty) fotos.add(json['petImage3']);
    
    // Por ahora, hardcodeamos algunos datos que no vienen en la API
    final List<String> intereses = json['interests'] != null ? 
        List<String>.from(json['interests']) : 
        ['Paseos', 'Jugar', 'Dormir'];
    
    return Mascota(
      id: json['petUID'] ?? json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      ownerUID: json['ownerUID'] ?? '',
      name: json['name'] ?? '',
      petImage1: json['petImage1'] ?? '',
      petImage2: json['petImage2'] ?? '',
      petImage3: json['petImage3'] ?? '',
      sex: json['sex'] ?? '',
      petBio: json['petBio'] ?? '',
      species: json['species'] ?? '',
      birthDate: json['birthDate'] ?? 0,
      intereses: intereses,
      propietarioNombre: ownerData['name'] ?? 'Propietario',
      propietarioFoto: ownerData['userImage1'] ?? 'assets/images/default_user.png',
      ubicacion: ownerData['location'] ?? 'Desconocida',
    );
  }
  
  // Calculate age from birthDate (milliseconds since epoch)
  String get edad {
    if (birthDate == 0) return "";
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