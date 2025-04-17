import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../State/mascota_provider.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(242, 217, 208, 1),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pets, color: Colors.pink),
            SizedBox(width: 8),
            Text('Wild Love', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        centerTitle: true,
      ),
      backgroundColor: Color.fromRGBO(242, 217, 208, 1),
      body: Consumer<MascotaProvider>(
        builder: (context, mascotaProvider, child) {
          final mascotaActual = mascotaProvider.mascotaActual;
          
          if (mascotaActual == null) {
            return Center(
              child: Text('No hay más mascotas disponibles por el momento'),
            );
          }
          
          return Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _buildSwipeableCard(context, mascotaActual, mascotaProvider),
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
                      onPressed: () => mascotaProvider.darDislike(),
                    ),
                    BotonAccion(
                      icon: Icons.favorite,
                      color: Colors.pink,
                      onPressed: () => mascotaProvider.darLike(),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSwipeableCard(BuildContext context, dynamic mascota, MascotaProvider provider) {
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
            provider.darLike();
            _showSnackBar(context, '¡Te gusta esta mascota!', Colors.pink);
          } else {
            // Swipe izquierda (dislike)
            provider.darDislike();
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
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.pink, width: 4),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
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
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.red, width: 4),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
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
        duration: Duration(milliseconds: 800),
      ),
    );
  }
}