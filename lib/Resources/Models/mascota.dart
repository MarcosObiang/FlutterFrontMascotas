// models/mascota.dart
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
  
  // Campos para identificar el tipo de mascota
  final bool enAdopcion;
  final String? propietarioId; // null si es de un centro de adopción
  final String? centroAdopcionId; // null si es de un particular
  
  // Información sobre el propietario/centro (puede ser uno u otro)
  final String propietarioNombre;
  final String propietarioFoto;

  // Estado de la mascota (especialmente útil para mascotas en adopción)
  final String estado; // "disponible", "en proceso", "adoptada"
  
  // Añadido el getter fotoPerfil que retorna la primera foto o una URL por defecto
  String get fotoPerfil => fotos.isNotEmpty ? fotos[0] : 'https://via.placeholder.com/150';
  
  // Getter para determinar si la mascota pertenece a un particular
  bool get esDeParticular => propietarioId != null;
  
  // Getter para determinar si la mascota pertenece a un centro de adopción
  bool get esDeCentroAdopcion => centroAdopcionId != null;

  Mascota({
    required this.id,
    required this.nombre,
    required this.edad,
    required this.especie,
    required this.raza,
    required this.descripcion,
    required this.fotos,
    required this.propietarioNombre,
    required this.propietarioFoto,
    required this.ubicacion,
    required this.intereses,
    required this.enAdopcion,
    this.propietarioId,
    this.centroAdopcionId,
    this.estado = "disponible",
  });
  
  // Constructor para crear una mascota de un particular (no en adopción)
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
    return Mascota(
      id: id,
      nombre: nombre,
      edad: edad,
      especie: especie,
      raza: raza,
      descripcion: descripcion,
      fotos: fotos,
      propietarioNombre: propietarioNombre,
      propietarioFoto: propietarioFoto,
      ubicacion: ubicacion,
      intereses: intereses,
      enAdopcion: false,
      propietarioId: propietarioId,
      centroAdopcionId: null,
    );
  }
  
  // Constructor para crear una mascota de un particular en adopción
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
    String estado = "disponible",
  }) {
    return Mascota(
      id: id,
      nombre: nombre,
      edad: edad,
      especie: especie,
      raza: raza,
      descripcion: descripcion,
      fotos: fotos,
      propietarioNombre: propietarioNombre,
      propietarioFoto: propietarioFoto,
      ubicacion: ubicacion,
      intereses: intereses,
      enAdopcion: true,
      propietarioId: propietarioId,
      centroAdopcionId: null,
      estado: estado,
    );
  }
  
  // Constructor para crear una mascota de un centro de adopción
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
    String estado = "disponible",
  }) {
    return Mascota(
      id: id,
      nombre: nombre,
      edad: edad,
      especie: especie,
      raza: raza,
      descripcion: descripcion,
      fotos: fotos,
      propietarioNombre: centroNombre, // Usamos el mismo campo para el nombre del centro
      propietarioFoto: centroFoto, // Usamos el mismo campo para la foto del centro
      ubicacion: ubicacion,
      intereses: intereses,
      enAdopcion: true,
      propietarioId: null,
      centroAdopcionId: centroAdopcionId,
      estado: estado,
    );
  }

  // Constructor para deserializar desde JSON
  factory Mascota.fromJson(Map<String, dynamic> json) {
    return Mascota(
      id: json['id'],
      nombre: json['nombre'],
      edad: json['edad'],
      especie: json['especie'],
      raza: json['raza'],
      descripcion: json['descripcion'],
      fotos: List<String>.from(json['fotos']),
      propietarioNombre: json['propietarioNombre'],
      propietarioFoto: json['propietarioFoto'],
      ubicacion: json['ubicacion'],
      intereses: List<String>.from(json['intereses']),
      enAdopcion: json['enAdopcion'] ?? false,
      propietarioId: json['propietarioId'],
      centroAdopcionId: json['centroAdopcionId'],
      estado: json['estado'] ?? "disponible",
    );
  }

  // Constructor para serializar a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'edad': edad,
      'especie': especie,
      'raza': raza,
      'descripcion': descripcion,
      'fotos': fotos,
      'propietarioNombre': propietarioNombre,
      'propietarioFoto': propietarioFoto,
      'ubicacion': ubicacion,
      'intereses': intereses,
      'enAdopcion': enAdopcion,
      'propietarioId': propietarioId,
      'centroAdopcionId': centroAdopcionId,
      'estado': estado,
    };
  }
  
  // Método para crear una copia de la mascota con algunos campos modificados
  Mascota copyWith({
    String? id,
    String? nombre,
    String? edad,
    String? especie,
    String? raza, 
    String? descripcion,
    List<String>? fotos,
    String? propietarioNombre,
    String? propietarioFoto,
    String? ubicacion,
    List<String>? intereses,
    bool? enAdopcion,
    String? propietarioId,
    String? centroAdopcionId,
    String? estado,
  }) {
    return Mascota(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      edad: edad ?? this.edad,
      especie: especie ?? this.especie,
      raza: raza ?? this.raza,
      descripcion: descripcion ?? this.descripcion,
      fotos: fotos ?? this.fotos,
      propietarioNombre: propietarioNombre ?? this.propietarioNombre,
      propietarioFoto: propietarioFoto ?? this.propietarioFoto,
      ubicacion: ubicacion ?? this.ubicacion,
      intereses: intereses ?? this.intereses,
      enAdopcion: enAdopcion ?? this.enAdopcion,
      propietarioId: propietarioId ?? this.propietarioId,
      centroAdopcionId: centroAdopcionId ?? this.centroAdopcionId,
      estado: estado ?? this.estado,
    );
  }
  
  // Método para verificar si una mascota coincide con criterios de búsqueda
  bool coincideConCriterios({
    String? especieBuscada,
    String? razaBuscada,
    String? ubicacionBuscada,
    int? edadMinima,
    int? edadMaxima,
  }) {
    // Convertir edad de String a int para comparación
    int edadInt;
    try {
      edadInt = int.parse(edad);
    } catch (e) {
      edadInt = 0; // Valor predeterminado si no se puede convertir
    }
    
    // Verificar cada criterio aplicable
    if (especieBuscada != null && especieBuscada.isNotEmpty && 
        !especie.toLowerCase().contains(especieBuscada.toLowerCase())) {
      return false;
    }
    
    if (razaBuscada != null && razaBuscada.isNotEmpty && 
        !raza.toLowerCase().contains(razaBuscada.toLowerCase())) {
      return false;
    }
    
    if (ubicacionBuscada != null && ubicacionBuscada.isNotEmpty && 
        !ubicacion.toLowerCase().contains(ubicacionBuscada.toLowerCase())) {
      return false;
    }
    
    if (edadMinima != null && edadInt < edadMinima) {
      return false;
    }
    
    if (edadMaxima != null && edadInt > edadMaxima) {
      return false;
    }
    
    return true;
  }
  
  // Método para convertir una imagen única a formato de lista de fotos
  static List<String> convertirImagenALista(String? imagenUrl) {
    if (imagenUrl == null || imagenUrl.isEmpty) {
      return [];
    }
    return [imagenUrl];
  }
  
  // Método para convertir intereses de string a lista
  static List<String> convertirInteresesALista(String interesesStr) {
    if (interesesStr.isEmpty) {
      return [];
    }
    return interesesStr.split(',').map((e) => e.trim()).toList();
  }
}