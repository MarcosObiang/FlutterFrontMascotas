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

  // Método para mostrar el modal de configuración de búsqueda
  void _mostrarConfiguracionBusqueda() {
    final configProvider = Provider.of<ConfiguracionBusquedaProvider>(context, listen: false);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            top: 20,
            left: 20,
            right: 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Opciones de búsqueda',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                
                // Selector del tipo de búsqueda
                const Text('Tipo de búsqueda:', style: TextStyle(fontWeight: FontWeight.bold)),
                DropdownButton<TipoBusqueda>(
                  value: configProvider.tipoBusquedaSeleccionado,
                  isExpanded: true,
                  icon: const Icon(Icons.arrow_downward),
                  onChanged: (TipoBusqueda? newValue) {
                    if (newValue != null) {
                      setModalState(() {
                        configProvider.setTipoBusqueda(newValue);
                      });
                    }
                  },
                  items: TipoBusqueda.values.map<DropdownMenuItem<TipoBusqueda>>((TipoBusqueda value) {
                    String label;
                    switch (value) {
                      case TipoBusqueda.todas:
                        label = 'Todas las mascotas';
                        break;
                      case TipoBusqueda.porProximidad:
                        label = 'Por proximidad';
                        break;
                      case TipoBusqueda.porEspecie:
                        label = 'Por especie';
                        break;
                    }
                    return DropdownMenuItem<TipoBusqueda>(
                      value: value,
                      child: Text(label),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                
                // Configuración específica según el tipo de búsqueda
                // Solo mostramos las opciones de especie cuando se ha seleccionado específicamente "Por especie"
                if (configProvider.tipoBusquedaSeleccionado == TipoBusqueda.porEspecie) ...[
                  const Text('Especie:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: configProvider.getEspeciesDisponibles().map((especie) {
                      // Corrección del color del chip seleccionado
                      final bool isSelected = configProvider.especieSeleccionada == especie;
                      return ChoiceChip(
                        label: Text(especie),
                        selected: isSelected,
                        selectedColor: Colors.pink,  // Color sólido para el seleccionado
                        backgroundColor: Colors.pink.withOpacity(0.1),
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        onSelected: (selected) {
                          if (selected) {
                            setModalState(() {
                              configProvider.setEspecieSeleccionada(especie);
                            });
                          }
                        },
                      );
                    }).toList(),
                  ),
                ],
                
                // Solo mostramos el radio de búsqueda cuando se ha seleccionado específicamente "Por proximidad"
                if (configProvider.tipoBusquedaSeleccionado == TipoBusqueda.porProximidad) ...[
                  const SizedBox(height: 20),
                  Text(
                    'Radio de búsqueda (${configProvider.distanciaMaxima.round()} km):',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Slider(
                    value: configProvider.distanciaMaxima,
                    min: 1,
                    max: 100,
                    divisions: 99,
                    label: configProvider.distanciaMaxima.round().toString(),
                    activeColor: Colors.pink,
                    inactiveColor: Colors.pink.withOpacity(0.2),
                    onChanged: (double value) {
                      setModalState(() {
                        configProvider.setDistanciaMaxima(value);
                      });
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('1 km', style: TextStyle(color: Colors.grey)),
                      Text('100 km', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ],
                
                const SizedBox(height: 20),
                
                // Botones de acción
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        
                        // Aplicamos la configuración y guardamos
                        await configProvider.aplicarCambiosBusqueda();
                        
                        // Recargamos mascotas con la nueva configuración
                        _viewModel.cargarMascotas(configProvider);
                        
                        // Mostramos confirmación
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Configuración aplicada')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink,
                      ),
                      child: const Text('Aplicar', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
              backgroundImage: NetworkImage(mascota.petImage1 ?? ''),
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
                // Botón para abrir la configuración de búsqueda
                IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: _mostrarConfiguracionBusqueda,
                  tooltip: 'Opciones de búsqueda',
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () => viewModel.cargarMascotas(configProvider),
                  tooltip: 'Recargar mascotas',
                ),
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
        // Indicador del tipo de búsqueda actual
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),          
          child: Row(
            children: [
              const Icon(Icons.search, size: 16),
              const SizedBox(width: 8),
              Text(
                viewModel.getTipoBusquedaTexto(configProvider),
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              BotonAccion(
                icon: Icons.close,
                color: Colors.red,
                onPressed: () {
                  viewModel.darDislike();
                  _showSnackBar(context, 'Descartaste esta mascota', Colors.red);
                },
              ),
              BotonAccion(
                icon: Icons.favorite,
                color: Colors.pink,
                onPressed: () async {
                  bool isMatch = await viewModel.darLike();
                  if (isMatch) {
                    _showMatchNotification(context, viewModel.mascotaActual!);
                  }
                  _showSnackBar(context, '¡Te gusta esta mascota!', Colors.pink);
                },
              ),
            ],
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
              _showMatchNotification(context, mascota);
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