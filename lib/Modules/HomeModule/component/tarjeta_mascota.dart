import 'package:flutter/material.dart';
import 'package:mascotas_citas/models/PetModel.dart';
import 'package:provider/provider.dart';
import 'package:mascotas_citas/Resources/providers/theme_provider.dart';
import 'dart:async';

class TarjetaMascota extends StatefulWidget {
  final PetModel mascota;
  
  const TarjetaMascota({super.key, required this.mascota});
  
  @override
  State<TarjetaMascota> createState() => _TarjetaMascotaState();
}

class _TarjetaMascotaState extends State<TarjetaMascota> with SingleTickerProviderStateMixin {
  int _currentImageIndex = 0;
  Timer? _imageTimer;
  late AnimationController _animationController;
  late Animation<double> _animation;
  
  // Traducción de especies en español
  final Map<String, String> _especiesTraducidas = {
    'dog': 'Perro',
    'cat': 'Gato',
    'bird': 'Ave',
    'rabbit': 'Conejo',
    'hamster': 'Hámster',
    'fish': 'Pez',
    'turtle': 'Tortuga',
    'lizard': 'Lagarto',
    'snake': 'Serpiente',
    'guinea pig': 'Cobaya',
    'ferret': 'Hurón',
    'other': 'Otro',
  };

  @override
  void initState() {
    super.initState();
    // Configurar animación para cambios de imagen
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    
    // Iniciar el temporizador para cambiar imágenes cada 30 segundos
    _startImageTimer();
  }

  @override
  void dispose() {
    // Liberar recursos
    _imageTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _startImageTimer() {
    _imageTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _nextImage();
    });
  }

  void _nextImage() {
    final List<String?> images = _getValidImages();
    if (images.isEmpty) return;
    
    _animationController.forward(from: 0.0);
    
    setState(() {
      _currentImageIndex = (_currentImageIndex + 1) % images.length;
    });
  }

  void _previousImage() {
    final List<String?> images = _getValidImages();
    if (images.isEmpty) return;
    
    _animationController.forward(from: 0.0);
    
    setState(() {
      _currentImageIndex = (_currentImageIndex - 1 + images.length) % images.length;
    });
  }

  // Función para construir la URL completa de la imagen
  String _buildImageUrl(String imageSource) {
    // Si ya es una URL completa (contiene http:// o https://), la devolvemos tal como está
    if (imageSource.startsWith('http://') || imageSource.startsWith('https://')) {
      return imageSource;
    }
    
    // Si es solo un nombre de archivo, agregamos el prefijo del servidor local
    return 'http://localhost:8091/media/get-media?fileName=$imageSource';
  }

  // Obtener lista de imágenes válidas
  List<String> _getValidImages() {
    return [
      widget.mascota.petImage1,
      widget.mascota.petImage2,
      widget.mascota.petImage3,
    ].where((img) => img != null && img.isNotEmpty).cast<String>().toList();
  }

  // Obtener imagen actual para mostrar
  String? _getCurrentImage() {
    final List<String> images = _getValidImages();
    
    if (images.isEmpty) {
      return null; // Retornamos null en lugar de placeholder
    }
    
    // Construir la URL completa para la imagen actual
    return _buildImageUrl(images[_currentImageIndex]);
  }

  // Traducir la especie al español
  String _getEspecieEnEspanol() {
    final String especie = (widget.mascota.species ?? '').toLowerCase();
    return _especiesTraducidas[especie] ?? especie;
  }

  // Obtener emoji por especie
  IconData _getIconoEspecie() {
    final String especie = (widget.mascota.species ?? '').toLowerCase();
    switch (especie) {
      case 'dog': return Icons.pets;
      case 'cat': return Icons.pets;
      case 'bird': return Icons.flutter_dash;
      case 'fish': return Icons.water;
      case 'turtle': return Icons.pest_control;
      case 'rabbit': return Icons.pets;
      default: return Icons.pets;
    }
  }

  // Widget para mostrar cuando no hay imagen
  Widget _buildNoImageWidget(ColorScheme colorScheme) {
    return Container(
      color: colorScheme.surfaceContainerHighest,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.pets,
            size: 80,
            color: colorScheme.primary.withOpacity(0.6),
          ),
          const SizedBox(height: 16),
          Text(
            'Sin imagen disponible',
            style: TextStyle(
              color: colorScheme.onSurface.withOpacity(0.7),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Foto próximamente',
            style: TextStyle(
              color: colorScheme.onSurface.withOpacity(0.5),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // Widget para mostrar error de carga de imagen
  Widget _buildImageErrorWidget(ColorScheme colorScheme) {
    return Container(
      color: colorScheme.surfaceContainerHighest,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image,
            size: 60,
            color: colorScheme.error.withOpacity(0.7),
          ),
          const SizedBox(height: 16),
          Text(
            'Error al cargar imagen',
            style: TextStyle(
              color: colorScheme.error,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Verifica tu conexión',
            style: TextStyle(
              color: colorScheme.onSurface.withOpacity(0.6),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Obtener el provider de tema
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final theme = isDarkMode ? themeProvider.darkTheme : themeProvider.lightTheme;
    final colorScheme = theme.colorScheme;
    
    // Calcular la edad en años
    final DateTime now = DateTime.now();
    final DateTime petBirthDate = widget.mascota.birthDate ?? now;
    final Duration difference = now.difference(petBirthDate);
    final int years = (difference.inDays / 365).floor();
    final int months = ((difference.inDays % 365) / 30).floor();
    
    // Obtener la lista de imágenes disponibles para los indicadores
    final List<String> images = _getValidImages();
    final String? currentImageUrl = _getCurrentImage();
    
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 10,
      shadowColor: colorScheme.primary.withOpacity(0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Imagen de la mascota con carrusel
          Expanded(
            flex: 7,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Imagen principal con animación o placeholder
                currentImageUrl != null
                    ? FadeTransition(
                        opacity: _animation,
                        child: Image.network(
                          currentImageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => 
                              _buildImageErrorWidget(colorScheme),
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                color: theme.colorScheme.primary,
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            );
                          },
                        ),
                      )
                    : _buildNoImageWidget(colorScheme),
                
                // Gradiente para mejor legibilidad del texto
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.8),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Gradiente superior para decoración
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 80,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.5),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Botones de navegación para las fotos
                if (images.length > 1 && currentImageUrl != null) ...[
                  // Botón anterior
                  Positioned(
                    left: 10,
                    top: 0,
                    bottom: 0,
                    child: GestureDetector(
                      onTap: _previousImage,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.chevron_left,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ),
                  ),
                  
                  // Botón siguiente
                  Positioned(
                    right: 10,
                    top: 0,
                    bottom: 0,
                    child: GestureDetector(
                      onTap: _nextImage,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.chevron_right,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ),
                  ),
                ],
                
                // Indicadores de carrusel
                if (images.length > 1 && currentImageUrl != null)
                  Positioned(
                    bottom: 110,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        images.length,
                        (index) => GestureDetector(
                          onTap: () {
                            setState(() {
                              _currentImageIndex = index;
                              _animationController.forward(from: 0.0);
                            });
                          },
                          child: Container(
                            width: 10,
                            height: 10,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 1),
                              color: _currentImageIndex == index
                                  ? Colors.white
                                  : Colors.transparent,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                
                // Contador de fotos
                if (images.isNotEmpty && currentImageUrl != null)
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.photo_library,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "${_currentImageIndex + 1}/${images.length}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                
                // Información básica de la mascota
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Icon(
                                  _getIconoEspecie(),
                                  color: Colors.white,
                                  size: 24,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '${widget.mascota.name ?? 'Sin nombre'}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Indicador de sexo
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: (widget.mascota.sex ?? '').toLowerCase() == 'male' 
                                    ? Colors.blue.shade600 
                                    : colorScheme.primary,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  (widget.mascota.sex ?? '').toLowerCase() == 'male' ? Icons.male : Icons.female,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  (widget.mascota.sex ?? '').toLowerCase() == 'male' ? 'Macho' : 'Hembra',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            _getEspecieEnEspanol(),
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "•",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            years > 0 
                                ? "$years ${years == 1 ? 'año' : 'años'}" 
                                : "$months ${months == 1 ? 'mes' : 'meses'}",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Descripción de la mascota
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Separador decorativo
                Container(
                  height: 3,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colorScheme.primaryContainer,
                        colorScheme.primary.withOpacity(0.7),
                        colorScheme.primary,
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.pets,
                              size: 20,
                              color: colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Sobre mí',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const Spacer(),
                            // Un pequeño corazón decorativo
                            Icon(
                              Icons.favorite,
                              size: 16,
                              color: colorScheme.primary,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Text(
                              widget.mascota.petBio ?? 'Soy una mascota muy especial buscando amigos. ¡Conóceme!',
                              style: TextStyle(
                                fontSize: 14,
                                color: colorScheme.onSurface,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Información del dueño
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: themeProvider.isDarkMode 
                        ? colorScheme.surfaceContainerHighest
                        : Colors.grey.shade100,
                    border: Border(
                      top: BorderSide(
                        color: colorScheme.outline,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Foto de perfil del dueño (usando un ícono en lugar de placeholder)
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colorScheme.primaryContainer,
                          border: Border.all(
                            color: colorScheme.primary,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          Icons.person,
                          size: 18,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Información del dueño
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.mascota.ownerUID ?? 'Dueño Anónimo',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Ícono de verificación del dueño
                      Icon(
                        Icons.verified_user,
                        size: 16,
                        color: colorScheme.primary.withOpacity(0.7),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}