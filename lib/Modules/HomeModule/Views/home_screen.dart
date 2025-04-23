import 'package:flutter/material.dart';
import 'package:mascotas_citas/models/PetModel.dart'; // Usamos el modelo PetModel
import '../../../Resources/Widgets/boton_accion.dart';
import '../../../Resources/Widgets/tarjeta_mascota.dart';
import '../../../Resources/Services/api_service.dart';

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
  
  // Lista de mascotas con el modelo PetModel
  List<PetModel>? _mascotas;
  bool _isLoading = true;
  String? _error;
  
  // Servicio API
  final ApiService _apiService = ApiService();
  
  @override
  void initState() {
    super.initState();
    _cargarMascotas();
  }
  
  // Método para cargar las mascotas desde la API
  Future<void> _cargarMascotas() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      final mascotas = await _apiService.getAllPets();
      setState(() {
        _mascotas = mascotas;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error al cargar las mascotas: $e';
        _isLoading = false;
      });
    }
  }
  
  int _currentIndex = 0;
  
  // Método para obtener la mascota actual
  PetModel? get mascotaActual {
    if (_mascotas == null || _currentIndex >= _mascotas!.length) {
      return null;
    }
    return _mascotas![_currentIndex];
  }
  
  // Método para dar like
  void darLike() async {
    // Verificar que hay una mascota actual
    if (mascotaActual == null) return;
    
    final String userId = "usuarioActual.id"; // Esto debería venir del usuario logueado
    final String petId = mascotaActual!.id;
    
    try {
      // Llamar al API Service para registrar el like
      final resultado = await _apiService.createLike(userId, petId);
      if (resultado['isMatch'] == true) {
        // Mostrar notificación de match
        _showMatchNotification(context, mascotaActual!);
      }
      // Avanzamos al siguiente perfil
      setState(() {
        _currentIndex++;
      });
      _showSnackBar(context, '¡Te gusta esta mascota!', Colors.pink);
    } catch (e) {
      // Manejar error
      _showSnackBar(context, 'Error al registrar el like: $e', Colors.red);
    }
  }
  
  // Método para mostrar notificación de match
  void _showMatchNotification(BuildContext context, PetModel mascota) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('¡Tienes un nuevo match!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(mascota.petImage1),
            ),
            SizedBox(height: 16),
            Text('Has hecho match con ${mascota.name}'),
            Text('¡Ve a la sección de matches para chatear!'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cerrar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Aquí podrías navegar a la página de matches
            },
            child: Text('Ver match'),
          ),
        ],
      ),
    );
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
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pets, color: Colors.pink),
            SizedBox(width: 8),
            Text('Wild Love', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargarMascotas,
            tooltip: 'Recargar mascotas',
          ),
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : _error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_error!, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _cargarMascotas,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            )
          : Column(
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
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSwipeableCard(BuildContext context, PetModel mascota) {
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