import 'package:flutter/material.dart';
import 'package:mascotas_citas/models/PetModel.dart';
import '../component/boton_accion.dart';
import '../component/tarjeta_mascota.dart';
import 'package:provider/provider.dart';
import 'package:mascotas_citas/Modules/ProfileModule/component/configuracion_busqueda_provider.dart';
import '../ViewModel/home_view_model.dart';

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
  
  // ViewModel
  late final HomeViewModel _viewModel;
  
  @override
  void initState() {
    super.initState();
    _viewModel = HomeViewModel();
    
    // Retraso para permitir que el provider se inicialice completamente
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final configProvider = Provider.of<ConfiguracionBusquedaProvider>(context, listen: false);
      _viewModel.cargarMascotas(configProvider);
    });
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

  @override
  Widget build(BuildContext context) {
    // Observamos cambios en el ViewModel y en el ConfigProvider
    final configProvider = Provider.of<ConfiguracionBusquedaProvider>(context);
    
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Consumer<HomeViewModel>(
        builder: (context, viewModel, _) {
          return Scaffold(
            appBar: AppBar(
              leading:  null,
              automaticallyImplyLeading: false,
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
             
              ],
            ),
            body: _buildBody(viewModel, configProvider),
          );
        },
      ),
    );
  }
  
  Widget _buildBody(HomeViewModel viewModel, ConfiguracionBusquedaProvider configProvider) {
    // Mostrar pantalla de carga
    if (viewModel.status == LoadingStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    // Mostrar pantalla de error
    if (viewModel.status == LoadingStatus.error) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              viewModel.errorMessage ?? 'Error desconocido', 
              style: const TextStyle(color: Colors.red)
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => viewModel.cargarMascotas(configProvider),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }
    
    // Mostrar contenido principal
    return Column(
      children: [

        if (viewModel.mascotaActual == null)
          const Expanded(
            child: Center(
              child: Text('No hay más mascotas disponibles por el momento'),
            ),
          )
        else
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildSwipeableCard(context, viewModel, viewModel.mascotaActual!),
            ),
          ),

      ],
    );
  }

  Widget _buildSwipeableCard(
    BuildContext context, 
    HomeViewModel viewModel, 
    PetModel mascota
  ) {
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
      onHorizontalDragEnd: (details) async {
        if (_dragPosition.abs() > threshold) {
          // Si supera el umbral, consideramos que es un swipe completo
          if (_dragPosition > 0) {
            // Swipe derecha (like)
            bool isMatch = await viewModel.darLike();
            if (isMatch) {
            }
            _showSnackBar(context, '¡Te gusta esta mascota!', Colors.pink);
          } else {
            // Swipe izquierda (dislike)
            viewModel.darDislike();
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
}