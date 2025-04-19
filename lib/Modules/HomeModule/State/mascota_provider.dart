// providers/mascota_provider.dart
import 'package:flutter/material.dart';
import '../../../Resources/Models/mascota.dart';
import '../../../Resources/Models/match.dart';  
import '../../../Resources/Models/mensaje.dart';

class MascotaProvider extends ChangeNotifier {
  List<Mascota> _mascotas = [];
  List<Match> _matches = [];
  List<Mensaje> _mensajes = [];
  int _mascotaIndex = 0;
  
  List<Mascota> get mascotas => _mascotas;
  List<Match> get matches => _matches;
  List<Mensaje> get mensajes => _mensajes;
  Mascota? get mascotaActual => _mascotaIndex < _mascotas.length ? _mascotas[_mascotaIndex] : null;
  // Añadido el getter miMascota
  Mascota? get miMascota => _mascotas.isNotEmpty ? _mascotas[0] : null;
  
  // Simulación de datos para desarrollo
  MascotaProvider() {
    _cargarDatosIniciales();
  }
  
  // Método para cargar mascotas (soluciona el error en HomeScreen)
  void cargarMascotas() {
    // Reiniciamos el índice para volver a mostrar todas las mascotas
    _mascotaIndex = 0;
    
    // Opcionalmente, podríamos reorganizar la lista para dar sensación de nuevos datos
    _mascotas.shuffle();
    
    notifyListeners();
  }
  
  void _cargarDatosIniciales() {
    // Mascotas de ejemplo con imágenes locales
    _mascotas = [
      Mascota(
        id: '1',
        nombre: 'Luna',
        edad: '3',
        especie: 'Perro',
        raza: 'Labrador',
        descripcion: 'Me encanta jugar a buscar la pelota y nadar en el lago. Soy muy amigable con otros perros y niños.',
        fotos: [
          'assets/mascotas/luna_1.jpg',
          'assets/mascotas/luna_2.jpg'
        ],
        propietarioNombre: 'Carlos',
        propietarioFoto: 'assets/propietarios/carlos.jpg',
        ubicacion: 'Madrid',
        intereses: ['Paseos', 'Jugar con pelotas', 'Nadar'],
        enAdopcion: false,
        propietarioId: 'p1',
      ),
      Mascota(
        id: '2',
        nombre: 'Michi',
        edad: '2',
        especie: 'Gato',
        raza: 'Siamés',
        descripcion: 'Soy muy curioso y me encanta dormir al sol. Busco amigos tranquilos para compartir momentos de relax.',
        fotos: [
          'assets/mascotas/michi_1.jpg',
          'assets/mascotas/michi_2.jpg'
        ],
        propietarioNombre: 'Ana',
        propietarioFoto: 'assets/propietarios/ana.jpg',
        ubicacion: 'Barcelona',
        intereses: ['Dormir', 'Observar pájaros', 'Juguetes interactivos'],
        enAdopcion: false,
        propietarioId: 'p2',
      ),
      Mascota(
        id: '3',
        nombre: 'Rocky',
        edad: '4',
        especie: 'Perro',
        raza: 'Bulldog Francés',
        descripcion: 'Soy muy juguetón y activo. Me encanta conocer nuevos amigos para jugar en el parque cada día.',
        fotos: [
          'assets/mascotas/rocky_1.jpg',
          'assets/mascotas/rocky_2.jpg'
        ],
        propietarioNombre: 'Miguel',
        propietarioFoto: 'assets/propietarios/miguel.jpg',
        ubicacion: 'Valencia',
        intereses: ['Correr', 'Socializar', 'Juguetes masticables'],
        enAdopcion: false,
        propietarioId: 'p3',
      ),
      Mascota(
        id: '4',
        nombre: 'Max',
        edad: '5',
        especie: 'Perro',
        raza: 'Golden Retriever',
        descripcion: 'Soy un compañero leal y cariñoso. Me encanta hacer nuevos amigos peludos y jugar sin parar.',
        fotos: [
          'assets/mascotas/max_1.jpg',
          'assets/mascotas/max_2.jpg'
        ],
        propietarioNombre: 'Elena',
        propietarioFoto: 'assets/propietarios/elena.jpg',
        ubicacion: 'Sevilla',
        intereses: ['Natación', 'Buscar la pelota', 'Paseos en la playa'],
        enAdopcion: false,
        propietarioId: 'p4',
      ),
      Mascota(
        id: '5',
        nombre: 'Nina',
        edad: '1',
        especie: 'Gato',
        raza: 'Maine Coon',
        descripcion: 'Soy juguetona pero también disfruto de la tranquilidad. Busco amigos para jugar de vez en cuando.',
        fotos: [
          'assets/mascotas/nina_1.jpg',
          'assets/mascotas/nina_2.jpg'
        ],
        propietarioNombre: 'Martín',
        propietarioFoto: 'assets/propietarios/martin.jpg',
        ubicacion: 'Bilbao',
        intereses: ['Juguetes con plumas', 'Trepar', 'Descansar al sol'],
        enAdopcion: false,
        propietarioId: 'p5',
      ),
      Mascota(
        id: '6',
        nombre: 'Coco',
        edad: '2',
        especie: 'Perro',
        raza: 'Pomerania',
        descripcion: 'Soy pequeño pero con gran personalidad. Me encanta la aventura y conocer nuevos amigos.',
        fotos: [
          'assets/mascotas/coco_1.jpg',
          'assets/mascotas/coco_2.jpg'
        ],
        propietarioNombre: 'Sofía',
        propietarioFoto: 'assets/propietarios/sofia.jpg',
        ubicacion: 'Málaga',
        intereses: ['Juegos de interior', 'Paseos cortos', 'Socializar'],
        enAdopcion: false,
        propietarioId: 'p6',
      ),
      Mascota(
        id: '7',
        nombre: 'Zeus',
        edad: '4',
        especie: 'Perro',
        raza: 'Pastor Alemán',
        descripcion: 'Soy inteligente y activo. Necesito amigos que puedan seguir mi ritmo en largas caminatas.',
        fotos: [
          'assets/mascotas/zeus_1.jpg',
          'assets/mascotas/zeus_2.jpg'
        ],
        propietarioNombre: 'Alberto',
        propietarioFoto: 'assets/propietarios/alberto.jpg',
        ubicacion: 'Zaragoza',
        intereses: ['Entrenamiento', 'Correr', 'Juegos de inteligencia'],
        enAdopcion: false,
        propietarioId: 'p7',
      ),
      Mascota(
        id: '8',
        nombre: 'Simba',
        edad: '3',
        especie: 'Gato',
        raza: 'Bengalí',
        descripcion: 'Soy muy activo y juguetón. Me encantan los juegos de caza y correr por toda la casa.',
        fotos: [
          'assets/mascotas/simba_1.jpg',
          'assets/mascotas/simba_2.jpg'
        ],
        propietarioNombre: 'Laura',
        propietarioFoto: 'assets/propietarios/laura.jpg',
        ubicacion: 'Alicante',
        intereses: ['Juegos interactivos', 'Trepar', 'Perseguir juguetes'],
        enAdopcion: false,
        propietarioId: 'p8',
      ),
      Mascota(
        id: '9',
        nombre: 'Toby',
        edad: '6',
        especie: 'Perro',
        raza: 'Beagle',
        descripcion: 'Soy muy sociable y me encanta oler todo lo que encuentro. Busco amigos para pasear juntos.',
        fotos: [
          'assets/mascotas/toby_1.jpg',
          'assets/mascotas/toby_2.jpg'
        ],
        propietarioNombre: 'Javier',
        propietarioFoto: 'assets/propietarios/javier.jpg',
        ubicacion: 'Murcia',
        intereses: ['Rastreo', 'Paseos largos', 'Jugar con otros perros'],
        enAdopcion: false,
        propietarioId: 'p9',
      ),
      Mascota(
        id: '10',
        nombre: 'Bella',
        edad: '2',
        especie: 'Perro',
        raza: 'Border Collie',
        descripcion: 'Soy muy inteligente y enérgica. Necesito amigos que me ayuden a gastar toda mi energía.',
        fotos: [
          'assets/mascotas/bella_1.jpg',
          'assets/mascotas/bella_2.jpg'
        ],
        propietarioNombre: 'Carmen',
        propietarioFoto: 'assets/propietarios/carmen.jpg',
        ubicacion: 'Granada',
        intereses: ['Frisbee', 'Agility', 'Entrenamientos de obediencia'],
        enAdopcion: false,
        propietarioId: 'p10',
      ),
      // Añadamos también algunas mascotas en adopción
      Mascota.enAdopcion(
        id: '11',
        nombre: 'Nube',
        edad: '1',
        especie: 'Perro',
        raza: 'Mestizo',
        descripcion: 'Soy una perrita muy cariñosa y necesito un hogar lleno de amor.',
        fotos: [
          'assets/mascotas/nube_1.jpg'
        ],
        centroAdopcionId: 'c1',
        centroNombre: 'Protectora Amigos Peludos',
        centroFoto: 'assets/centros/protectora_amigos.jpg',
        ubicacion: 'Madrid',
        intereses: ['Paseos tranquilos', 'Juguetes', 'Dormir'],
      ),
      Mascota.enAdopcion(
        id: '12',
        nombre: 'Tigre',
        edad: '4',
        especie: 'Gato',
        raza: 'Atigrado',
        descripcion: 'He pasado mucho tiempo en la calle y ahora busco un hogar tranquilo.',
        fotos: [
          'assets/mascotas/tigre_1.jpg'
        ],
        centroAdopcionId: 'c2',
        centroNombre: 'Refugio Felino',
        centroFoto: 'assets/centros/refugio_felino.jpg',
        ubicacion: 'Barcelona',
        intereses: ['Descansar', 'Mimos', 'Espacios tranquilos'],
      ),
    ];
    
    // Simular algunos matches
    _matches = [
      Match(
        id: 'm1',
        mascotaId1: '1',
        mascotaId2: '2',
        fechaMatch: DateTime.now().subtract(Duration(days: 3)),
      ),
      Match(
        id: 'm2',
        mascotaId1: '1',
        mascotaId2: '5',
        fechaMatch: DateTime.now().subtract(Duration(days: 1)),
      ),
      Match(
        id: 'm3',
        mascotaId1: '1',
        mascotaId2: '8',
        fechaMatch: DateTime.now().subtract(Duration(hours: 5)),
      ),
    ];
    
    // Simular mensajes
    _mensajes = [
      Mensaje(
        id: 'msg1',
        matchId: 'm1',
        emisorId: '1',
        contenido: '¡Hola! Me gustaría conocerte en el parque',
        fechaEnvio: DateTime.now().subtract(Duration(days: 2)),
        leido: true,
      ),
      Mensaje(
        id: 'msg2',
        matchId: 'm1',
        emisorId: '2',
        contenido: '¡Claro! ¿Qué te parece este domingo?',
        fechaEnvio: DateTime.now().subtract(Duration(days: 1)),
        leido: false,
      ),
      Mensaje(
        id: 'msg3',
        matchId: 'm2',
        emisorId: '1',
        contenido: '¡Hola Nina! Vi que te gusta descansar al sol, ¡a mí también!',
        fechaEnvio: DateTime.now().subtract(Duration(hours: 12)),
        leido: true,
      ),
      Mensaje(
        id: 'msg4',
        matchId: 'm2',
        emisorId: '5',
        contenido: 'Miau! Sí, es mi actividad favorita. ¿Te gustaría quedar algún día?',
        fechaEnvio: DateTime.now().subtract(Duration(hours: 6)),
        leido: true,
      ),
      Mensaje(
        id: 'msg5',
        matchId: 'm3',
        emisorId: '1',
        contenido: '¡Hola Simba! Me encantaría conocer a un gato tan activo como tú',
        fechaEnvio: DateTime.now().subtract(Duration(hours: 4)),
        leido: false,
      ),
    ];
    
    notifyListeners();
  }
  
  void darLike() {
    if (_mascotaIndex < _mascotas.length) {
      // Simulación de match 20% de las veces
      if (DateTime.now().millisecond % 5 == 0) {
        _crearNuevoMatch();
      }
      
      _avanzarSiguienteMascota();
    }
  }
  
  void darDislike() {
    if (_mascotaIndex < _mascotas.length) {
      _avanzarSiguienteMascota();
    }
  }
  
  void _avanzarSiguienteMascota() {
    _mascotaIndex++;
    if (_mascotaIndex >= _mascotas.length) {
      // Si llegamos al final, podríamos recargar más mascotas o mostrar mensaje
      // Por ahora simplemente reiniciamos para el demo
      _mascotaIndex = 0;
    }
    notifyListeners();
  }
  
  void _crearNuevoMatch() {
    final match = Match(
      id: 'm${_matches.length + 1}',
      mascotaId1: '1', // ID de nuestra mascota (simulado)
      mascotaId2: _mascotas[_mascotaIndex].id,
      fechaMatch: DateTime.now(),
    );
    
    _matches.add(match);
    notifyListeners();
  }
  
  List<Mascota> obtenerMascotasConMatch() {
    // Filtramos las mascotas que tienen match con nuestra mascota (ID 1 para este ejemplo)
    final mascotasIds = _matches
        .where((match) => match.mascotaId1 == '1' || match.mascotaId2 == '1')
        .map((match) => match.mascotaId1 == '1' ? match.mascotaId2 : match.mascotaId1)
        .toList();
    
    return _mascotas.where((mascota) => mascotasIds.contains(mascota.id)).toList();
  }
  
  List<Mensaje> obtenerMensajesDeMatch(String matchId) {
    return _mensajes.where((mensaje) => mensaje.matchId == matchId).toList();
  }
  
  void enviarMensaje(String matchId, String contenido) {
    final nuevoMensaje = Mensaje(
      id: 'msg${_mensajes.length + 1}',
      matchId: matchId,
      emisorId: '1', // ID de nuestra mascota (simulado)
      contenido: contenido,
      fechaEnvio: DateTime.now(),
      leido: false,
    );
    
    _mensajes.add(nuevoMensaje);
    notifyListeners();
  }
}