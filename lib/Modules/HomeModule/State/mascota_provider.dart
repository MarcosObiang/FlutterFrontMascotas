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
    // Mascotas de ejemplo con imágenes de Unsplash
    _mascotas = [
      Mascota(
        id: '1',
        nombre: 'Luna',
        edad: '3',
        especie: 'Perro',
        raza: 'Labrador',
        descripcion: 'Me encanta jugar a buscar la pelota y nadar en el lago. Soy muy amigable con otros perros y niños.',
        fotos: [
          'https://images.unsplash.com/photo-1552053831-71594a27632d?q=80&w=500',
          'https://images.unsplash.com/photo-1587300003388-59208cc962cb?q=80&w=500'
        ],
        propietarioNombre: 'Carlos',
        propietarioFoto: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&w=200',
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
          'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?q=80&w=500',
          'https://images.unsplash.com/photo-1573865526739-10659fec78a5?q=80&w=500'
        ],
        propietarioNombre: 'Ana',
        propietarioFoto: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=200',
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
          'https://images.unsplash.com/photo-1583337130417-3346a1be7dee?q=80&w=500',
          'https://images.unsplash.com/photo-1575859431774-2e57ed632664?q=80&w=500'
        ],
        propietarioNombre: 'Miguel',
        propietarioFoto: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?q=80&w=200',
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
          'https://images.unsplash.com/photo-1530281700549-e82e7bf110d6?q=80&w=500',
          'https://images.unsplash.com/photo-1633722715903-c330a2ae823d?q=80&w=500'
        ],
        propietarioNombre: 'Elena',
        propietarioFoto: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=200',
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
          'https://images.unsplash.com/photo-1533738363-b7f9aef128ce?q=80&w=500',
          'https://images.unsplash.com/photo-1519052537078-e6302a4968d4?q=80&w=500'
        ],
        propietarioNombre: 'Martín',
        propietarioFoto: 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?q=80&w=200',
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
          'https://images.unsplash.com/photo-1557973557-ddfa9ee8c9bf?q=80&w=500',
          'https://images.unsplash.com/photo-1558556249-fac65b6aae9c?q=80&w=500'
        ],
        propietarioNombre: 'Sofía',
        propietarioFoto: 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?q=80&w=200',
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
          'https://images.unsplash.com/photo-1589941013453-ec89f33b5e95?q=80&w=500',
          'https://images.unsplash.com/photo-1555991415-1b04a71f18c5?q=80&w=500'
        ],
        propietarioNombre: 'Alberto',
        propietarioFoto: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?q=80&w=200',
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
          'https://images.unsplash.com/photo-1518791841217-8f162f1e1131?q=80&w=500',
          'https://images.unsplash.com/photo-1513360371669-4adf3dd7dff8?q=80&w=500'
        ],
        propietarioNombre: 'Laura',
        propietarioFoto: 'https://images.unsplash.com/photo-1531746020798-e6953c6e8e04?q=80&w=200',
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
          'https://images.unsplash.com/photo-1505628346881-b72b27e84530?q=80&w=500',
          'https://images.unsplash.com/photo-1596492784531-6e6eb5ea9993?q=80&w=500'
        ],
        propietarioNombre: 'Javier',
        propietarioFoto: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=200',
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
          'https://images.unsplash.com/photo-1503256207526-0d5d80fa2f47?q=80&w=500',
          'https://images.unsplash.com/photo-1555897209-208b67f652c5?q=80&w=500'
        ],
        propietarioNombre: 'Carmen',
        propietarioFoto: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?q=80&w=200',
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
          'https://images.unsplash.com/photo-1543466835-00a7907e9de1?q=80&w=500'
        ],
        centroAdopcionId: 'c1',
        centroNombre: 'Protectora Amigos Peludos',
        centroFoto: 'https://images.unsplash.com/photo-1618077360395-f3068be8e001?q=80&w=200',
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
          'https://images.unsplash.com/photo-1478098711619-5ab0b478d6e6?q=80&w=500'
        ],
        centroAdopcionId: 'c2',
        centroNombre: 'Refugio Felino',
        centroFoto: 'https://images.unsplash.com/photo-1606836576983-8b458e75221d?q=80&w=200',
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