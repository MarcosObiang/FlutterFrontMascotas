// datos/datos_mascotas.dart
import 'mascota.dart';
import 'match.dart';
import 'mensaje.dart';

// Datos de ejemplo para mascotas
final List<Mascota> DATOS_MASCOTAS = [
  Mascota(
    id: '1',
    nombre: 'Mi Mascota',
    edad: '3',
    raza: 'Labrador',
    descripcion: 'Mi adorable mascota',
    fotos: ['assets/images/mi_mascota.jpg'],
    especie: 'perro',
    propietarioNombre: 'Luis',
    propietarioFoto: 
    'assets/images/luis.jpg',
    ubicacion: 'Madrid',
    intereses: ['Jugar', 'Comer', 'Dormir'],
    enAdopcion: false,
    
  ),
  Mascota(
    id: '2',
    nombre: 'Luna',
    edad: '2',
    raza: 'Beagle',
    descripcion: 'Juguetona y muy amigable',
    fotos: ['assets/images/luna.jpg'],
    especie: 'perro',
    propietarioNombre: 'Juan',
    propietarioFoto: 'assets/images/juan.jpg',
    ubicacion: 'Barcelona',
    intereses: ['Jugar', 'Caminar', 'Dormir'],
    enAdopcion: true,
    
  ),
  Mascota(
    id: '3',
    nombre: 'Max',
    edad: '4',
    raza: 'Golden Retriever',
    descripcion: 'Le encanta nadar y jugar a la pelota',
    fotos: ['assets/images/max.jpg'],
    especie: 'perro',
    propietarioNombre: 'Ana',
    propietarioFoto: 'assets/images/ana.jpg',
    ubicacion: 'Madrid',
    intereses: ['Jugar', 'Nadar', 'Correr'],
    enAdopcion: true,
    
  ),
  Mascota(
    id: '4',
    nombre: 'Coco',
    edad: '1',
    raza: 'French Bulldog',
    descripcion: 'Muy cari oso y le encantan los mimos',
    fotos: ['assets/images/coco.jpg'],
    especie: 'perro',
    propietarioNombre: 'Luisa',
    propietarioFoto: 'assets/images/luisa.jpg',
    ubicacion: 'Sevilla',
    intereses: ['Caminar', 'Dormir', 'Jugar'],
    enAdopcion: true,
    
  ),
];

// Datos de ejemplo para matches
final List<Match> DATOS_MATCHES = [
  Match(
    id: 'match1',
    mascotaId1: '1',
    mascotaId2: '2',
    fechaMatch: DateTime.now().subtract(Duration(days: 5)),
  ),
  Match(
    id: 'match2',
    mascotaId1: '1',
    mascotaId2: '3',
    fechaMatch: DateTime.now().subtract(Duration(days: 2)),
  ),
  Match(
    id: 'match3',
    mascotaId1: '4',
    mascotaId2: '1',
    fechaMatch: DateTime.now().subtract(Duration(days: 1)),
  ),
];

// Datos de ejemplo para mensajes organizados por match
final Map<String, List<Mensaje>> DATOS_MENSAJES_POR_MATCH = {
  'match1': [
    Mensaje(
      id: 'msg1',
      matchId: 'match1',
      emisorId: '1',
      contenido: '¡Hola Luna! ¿Cómo estás?',
      fechaEnvio: DateTime.now().subtract(Duration(hours: 5)),
      leido: true,
    ),
    Mensaje(
      id: 'msg2',
      matchId: 'match1',
      emisorId: '2',
      contenido: '¡Hola! Muy bien, ¿y tú? ¿Quieres jugar en el parque?',
      fechaEnvio: DateTime.now().subtract(Duration(hours: 4)),
      leido: true,
    ),
    Mensaje(
      id: 'msg3',
      matchId: 'match1',
      emisorId: '1',
      contenido: '¡Claro! Me encantaría. ¿A qué hora?',
      fechaEnvio: DateTime.now().subtract(Duration(hours: 3)),
      leido: true,
    ),
    Mensaje(
      id: 'msg4',
      matchId: 'match1',
      emisorId: '2',
      contenido: '¿Te parece bien a las 5?',
      fechaEnvio: DateTime.now().subtract(Duration(hours: 2)),
      leido: false,
    ),
  ],
  'match2': [
    Mensaje(
      id: 'msg5',
      matchId: 'match2',
      emisorId: '1',
      contenido: '¡Hola Max! Vi que también te gusta jugar con pelotas',
      fechaEnvio: DateTime.now().subtract(Duration(days: 1)),
      leido: true,
    ),
    Mensaje(
      id: 'msg6',
      matchId: 'match2',
      emisorId: '3',
      contenido: '¡Sí! Es mi juguete favorito. ¿Jugamos algún día?',
      fechaEnvio: DateTime.now().subtract(Duration(hours: 12)),
      leido: true,
    ),
  ],
  // match3 no tiene mensajes todavía
};