import 'package:flutter/material.dart';
import '../../../Resources/Models/mascota.dart';
import '../../../Resources/Widgets/boton_accion.dart';
import '../../../Resources/Widgets/tarjeta_mascota.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// Variables para controlar la animación
  double _dragPosition = 0;
  double _dragPercentage = 0;
  bool _isDragging = false;

  /// Constantes de UI
  final double _maxRotation = 0.1; // Radianes
  final double _maxScale = 1.05;
  final double _minOpacity = 0.8;
  
  // Lista de mascotas de ejemplo
  late List<Mascota> _mascotas;
  
  @override
  void initState() {
    super.initState();
    // Inicializar la lista de mascotas con datos de ejemplo
    _mascotas = [
      Mascota.particular(
        id: '1',
        nombre: 'Rocky',
        edad: '3',
        especie: 'Perro',
        raza: 'Labrador',
        descripcion: 'Un perro cariñoso y juguetón que adora los paseos',
        fotos: ['assets/images/mascota1.jpg'],
        propietarioId: 'user1',
        propietarioNombre: 'Juan Pérez',
        propietarioFoto: 'assets/images/user1.jpg',
        ubicacion: 'Madrid',
        intereses: ['Paseos', 'Jugar a la pelota', 'Nadar'],
      ),
      Mascota.particularEnAdopcion(
        id: '2',
        nombre: 'Luna',
        edad: '2',
        especie: 'Gato',
        raza: 'Siamés',
        descripcion: 'Gata tranquila que le encanta dormir en el sofá',
        fotos: ['assets/images/mascota2.jpg'],
        propietarioId: 'user2',
        propietarioNombre: 'María López',
        propietarioFoto: 'assets/images/user2.jpg',
        ubicacion: 'Barcelona',
        intereses: ['Dormir', 'Jugar con láser', 'Cajas'],
      ),
      Mascota.enAdopcion(
        id: '3',
        nombre: 'Max',
        edad: '5',
        especie: 'Perro',
        raza: 'Pastor Alemán',
        descripcion: 'Perro entrenado y obediente, ideal para familias',
        fotos: ['assets/images/mascota3.jpg'],
        centroAdopcionId: 'centro1',
        centroNombre: 'Centro de Adopción Patitas',
        centroFoto: 'assets/images/centro1.jpg',
        ubicacion: 'Valencia',
        intereses: ['Entrenamiento', 'Correr', 'Niños'],
      ),
    ];
  }
  
  int _currentIndex = 0;
  
  // Método para obtener la mascota actual
  Mascota? get mascotaActual {
    if (_currentIndex < _mascotas.length) {
      return _mascotas[_currentIndex];
    }
    return null;
  }
  
  // Método para dar like
  void darLike() {
    setState(() {
      _currentIndex++;
    });
  }
  
  // Método para dar dislike
  void darDislike() {
    setState(() {
      _currentIndex++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(242, 217, 208, 1),
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pets, color: Colors.pink),
            SizedBox(width: 8),
            Text('Wild Love', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        centerTitle: true,
      ),
      backgroundColor: const Color.fromRGBO(242, 217, 208, 1),
      body: Column(
        children: [
          if (mascotaActual == null)
            const Expanded(
              child: Center(
                child: Text('No hay más mascotas disponibles por el momento'),
              ),
            )
          else
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildSwipeableCard(context, mascotaActual!),
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                BotonAccion(
                  icon: Icons.close,
                  color: Colors.red,
                  onPressed: () {
                    darDislike();
                    _showSnackBar(context, 'Descartaste esta mascota', Colors.red);
                  },
                ),
                BotonAccion(
                  icon: Icons.favorite,
                  color: Colors.pink,
                  onPressed: () {
                    darLike();
                    _showSnackBar(context, '¡Te gusta esta mascota!', Colors.pink);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwipeableCard(BuildContext context, Mascota mascota) {
    final screenWidth = MediaQuery.of(context).size.width;
    final threshold = screenWidth * 0.4; // Umbral para decidir si es swipe
    
    return GestureDetector(
      onHorizontalDragStart: (details) {
        setState(() {
          _isDragging = true;
        });
      },
      onHorizontalDragUpdate: (details) {
        setState(() {
          _dragPosition += details.delta.dx;
          _dragPercentage = _dragPosition / threshold;
          // Limitamos el porcentaje entre -1 y 1
          _dragPercentage = _dragPercentage.clamp(-1.0, 1.0);
        });
      },
      onHorizontalDragEnd: (details) {
        if (_dragPosition.abs() > threshold) {
          // Si supera el umbral, consideramos que es un swipe completo
          if (_dragPosition > 0) {
            // Swipe derecha (like)
            darLike();
            _showSnackBar(context, '¡Te gusta esta mascota!', Colors.pink);
          } else {
            // Swipe izquierda (dislike)
            darDislike();
            _showSnackBar(context, 'Descartaste esta mascota', Colors.red);
          }
        }
        
        // Reiniciamos las variables de animación
        setState(() {
          _dragPosition = 0;
          _dragPercentage = 0;
          _isDragging = false;
        });
      },
      child: Stack(
        children: [
          // Tarjeta con transformaciones
          Transform.translate(
            offset: Offset(_dragPosition, 0),
            child: Transform.rotate(
              angle: _dragPercentage * _maxRotation,
              child: Transform.scale(
                scale: _isDragging ? _maxScale : 1.0,
                child: TarjetaMascota(mascota: mascota),
              ),
            ),
          ),
          
          // Indicador de Like (derecha)
          if (_dragPercentage > 0.1)
            Positioned(
              top: 50,
              right: 30,
              child: Transform.rotate(
                angle: -0.5,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.pink, width: 4),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'LIKE',
                    style: TextStyle(
                      color: Colors.pink,
                      fontWeight: FontWeight.bold,
                      fontSize: 32,
                    ),
                  ),
                ),
              ),
            ),
          
          // Indicador de Dislike (izquierda)
          if (_dragPercentage < -0.1)
            Positioned(
              top: 50,
              left: 30,
              child: Transform.rotate(
                angle: 0.5,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.red, width: 4),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'NOPE',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 32,
                    ),
                  ),
                ),
              ),
            ),
          
          // Overlay de color para indicar dirección
          if (_dragPercentage != 0)
            Positioned.fill(
              child: Opacity(
                opacity: _dragPercentage.abs() * (1 - _minOpacity),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: _dragPercentage > 0 ? Alignment.centerLeft : Alignment.centerRight,
                      end: _dragPercentage > 0 ? Alignment.centerRight : Alignment.centerLeft,
                      colors: _dragPercentage > 0 
                        ? [Colors.white.withOpacity(0), Colors.pink.withOpacity(0.3)]
                        : [Colors.white.withOpacity(0), Colors.red.withOpacity(0.3)],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(milliseconds: 800),
      ),
    );
  }
}