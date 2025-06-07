import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mascotas_citas/services/ApiService.dart';
import 'package:mascotas_citas/services/ApiServiceRD.dart';
import 'package:dio/dio.dart';

class SelectorFotos extends StatefulWidget {
  final List<String> imagenes;
  final int maxPhotos;
  final Function(List<String>) onImagesUpdated;
  final String entidadId;
  final String? userUID;
  final String tipo;
  final DioApiService apiService;

  const SelectorFotos({
    super.key,
    required this.imagenes,
    required this.maxPhotos,
    required this.onImagesUpdated,
    required this.entidadId,
    required this.apiService,
    required this.tipo,
    this.userUID,
  });

  @override
  State<SelectorFotos> createState() => _SelectorFotosState();
}

class _SelectorFotosState extends State<SelectorFotos> {
  late List<String> _imagenes;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();
  
  // Constantes para dimensiones uniformes
  final double _imageSize = 100;
  final double _imageHeight = 100;
  
  // Variable para forzar la reconstrucción de widgets
  int _rebuildCounter = 0;

  @override
  void initState() {
    super.initState();
    _imagenes = List.from(widget.imagenes);
    print("Inicializando SelectorFotos con imágenes: $_imagenes");
    _clearAllImageCaches();
  }

  @override
  void didUpdateWidget(SelectorFotos oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (!listEquals(oldWidget.imagenes, widget.imagenes)) {
      print("SelectorFotos actualizado con nuevas imágenes: ${widget.imagenes}");
      _clearAllImageCaches();
      setState(() {
        _imagenes = List.from(widget.imagenes);
        _rebuildCounter++; // Incrementar contador para forzar reconstrucción
      });
      
      // Forzar actualización completa después de un breve retraso
      _forceImageRefresh();
    }
  }
  
  // Método mejorado para limpiar todos los cachés de imágenes
  void _clearAllImageCaches() {
    imageCache.clear();
    imageCache.clearLiveImages();
    // También limpiar caché de red si es necesario
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
  }
  
  // Método para forzar la actualización de imágenes
  void _forceImageRefresh() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _rebuildCounter++;
        });
        _clearAllImageCaches();
      }
    });
  }
  
  // Función auxiliar para comparar listas
  bool listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          height: _imageHeight,
          child: ListView.builder(
            key: ValueKey('listview_$_rebuildCounter'), // Key única para forzar reconstrucción
            scrollDirection: Axis.horizontal,
            itemCount: _imagenes.length < widget.maxPhotos ? _imagenes.length + 1 : _imagenes.length,
            itemBuilder: (context, index) {
              // Botón para añadir una nueva foto (solo para mascotas)
              if (index == _imagenes.length && _imagenes.length < widget.maxPhotos && widget.tipo == 'mascota') {
                return Container(
                  width: _imageSize,
                  height: _imageHeight,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[400]!),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.add_photo_alternate, size: 40, color: Colors.grey[600]),
                    onPressed: _handleAddNewPhoto,
                  ),
                );
              }

              // Mostrar foto existente con key única
              return GestureDetector(
                key: ValueKey('image_container_${index}_$_rebuildCounter'),
                onTap: () => _showPhotoOptions(context, index),
                child: Stack(
                  children: [
                    Container(
                      width: _imageSize,
                      height: _imageHeight,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: index == 0 ? Colors.pink : Colors.grey[400]!,
                          width: 2,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: _buildImageWidget(_imagenes[index], index),
                      ),
                    ),
                    // Indicador de foto principal
                    if (index == 0)
                      Positioned(
                        top: 5,
                        right: 13,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.pink,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.star,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
        if (_isLoading)
          Container(
            height: _imageHeight,
            color: Colors.black.withOpacity(0.3),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }

  // Método para mostrar opciones al presionar una foto (SIN OPCIÓN DE ELIMINAR)
  void _showPhotoOptions(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(widget.tipo == 'usuario' 
              ? 'Foto de perfil' 
              : (index == 0 ? 'Foto principal' : 'Opciones de foto')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Para usuarios, solo permitir reemplazar la foto de perfil
              if (widget.tipo == 'usuario')
                ListTile(
                  leading: const Icon(Icons.photo_camera, color: Colors.blue),
                  title: const Text('Cambiar foto de perfil'),
                  onTap: () {
                    Navigator.pop(context);
                    _handleReplacePhoto(index);
                  },
                ),
              // Para mascotas, mostrar opciones (SIN ELIMINAR)
              if (widget.tipo == 'mascota') ...[
                if (index != 0)
                  ListTile(
                    leading: const Icon(Icons.star, color: Colors.pink),
                    title: const Text('Establecer como principal'),
                    onTap: () {
                      Navigator.pop(context);
                      _handleSetMainPhoto(index);
                    },
                  ),
                ListTile(
                  leading: const Icon(Icons.photo_camera, color: Colors.blue),
                  title: const Text('Reemplazar foto'),
                  onTap: () {
                    Navigator.pop(context);
                    _handleReplacePhoto(index);
                  },
                ),
                if (_imagenes.length < widget.maxPhotos)
                  ListTile(
                    leading: const Icon(Icons.add_photo_alternate, color: Colors.blue),
                    title: const Text('Subir nueva foto'),
                    onTap: () {
                      Navigator.pop(context);
                      _handleAddNewPhoto();
                    },
                  ),
              ],
              ListTile(
                leading: const Icon(Icons.cancel, color: Colors.grey),
                title: const Text('Cancelar'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Método para seleccionar una imagen directamente
  Future<File?> _selectImage() async {
    ImageSource? source = await showDialog<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Seleccionar imagen de'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.blue),
                title: const Text('Cámara'),
                onTap: () {
                  Navigator.pop(context, ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.green),
                title: const Text('Galería'),
                onTap: () {
                  Navigator.pop(context, ImageSource.gallery);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );

    if (source == null) return null;
    
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        print("Imagen seleccionada: ${pickedFile.path}");
        return File(pickedFile.path);
      }
    } catch (e) {
      print("Error al seleccionar imagen: $e");
      _showErrorSnackbar('Error al seleccionar imagen: $e');
    }
    
    return null;
  }
  
  // Método para añadir una nueva foto (solo para mascotas)
  Future<void> _handleAddNewPhoto() async {
    if (widget.tipo != 'mascota') return;
    
    try {
      final File? imageFile = await _selectImage();
      if (imageFile == null) {
        print("No se seleccionó ninguna imagen");
        return;
      }

      setState(() => _isLoading = true);
      print("Añadiendo nueva foto: ${imageFile.path}");

      // Encontrar el primer slot disponible
      int nextSlot = _imagenes.length + 1;
      if (nextSlot > widget.maxPhotos) {
        setState(() => _isLoading = false);
        _showErrorSnackbar('Ya has alcanzado el máximo de fotos permitidas');
        return;
      }

      try {
        if (widget.userUID == null) {
          throw Exception('userUID es requerido para actualizar mascota');
        }
        
        FormData formData = FormData();
        
        // CLAVE: Enviar el orden actual de imágenes
        formData.fields.add(MapEntry('currentImageOrder', _imagenes.join(',')));
        formData.fields.add(MapEntry('action', 'addNewPhoto'));
        formData.fields.add(MapEntry('newImagePosition', nextSlot.toString()));
        
        formData.files.add(MapEntry(
          'petImage$nextSlot',
          await MultipartFile.fromFile(
            imageFile.path,
            filename: 'pet_image_$nextSlot.${imageFile.path.split('.').last}',
          ),
        ));
        
       // widget.apiService.dioClient.options.headers['userUID'] = widget.userUID!;
        
        final String url = '/orquestador/api/pets/update/${widget.entidadId}';
        
        final response = await widget.apiService.put(
          path: url,
          data: formData,
        );
        
        print("Respuesta del servidor: ${response.statusCode} - ${response.data}");
        
        if (response.statusCode == 200 || response.statusCode == 201) {
          await _updateImageSuccessfully(imageFile.path, isAdd: true);
          _showSuccessSnackbar('Imagen añadida correctamente');
        } else {
          setState(() => _isLoading = false);
          _showErrorSnackbar('Error del servidor: ${response.statusCode}');
        }
      } catch (apiError) {
        print("Error en API al añadir imagen: $apiError");
        setState(() => _isLoading = false);
        _showErrorSnackbar('Error al comunicarse con el servidor: $apiError');
      }
      
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackbar('Error inesperado: $e');
      print("Error general añadiendo foto: $e");
    }
  }

  // Método actualizado para reemplazar una foto existente
  Future<void> _handleReplacePhoto(int index) async {
    try {
      final File? imageFile = await _selectImage();
      if (imageFile == null) {
        print("No se seleccionó ninguna imagen para reemplazar");
        return;
      }

      setState(() => _isLoading = true);
      print("Reemplazando foto en posición $index: ${_imagenes[index]} -> ${imageFile.path}");

      try {
        if (widget.tipo == 'usuario') {
          await _handleUserImageReplace(imageFile, index);
        } else if (widget.tipo == 'mascota') {
          await _handlePetImageReplace(imageFile, index);
        }
      } catch (apiError) {
        print("Error en API al reemplazar imagen: $apiError");
        setState(() => _isLoading = false);
        _showErrorSnackbar('Error al comunicarse con el servidor: $apiError');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackbar('Error: $e');
      print("Error general reemplazando foto: $e");
    }
  }
  
  // Método separado para manejar reemplazo de imagen de usuario
  Future<void> _handleUserImageReplace(File imageFile, int index) async {
    if (widget.userUID == null) {
      throw Exception('userUID es requerido para subir imagen de usuario');
    }
    
    FormData formData = FormData();
    
    formData.files.add(MapEntry(
      'userImage',
      await MultipartFile.fromFile(
        imageFile.path,
        filename: 'profile_image.${imageFile.path.split('.').last}',
      ),
    ));
    
    //widget.apiService.dioClient.options.headers['userUID'] = widget.userUID!;
    
    const String url = '/orquestador/api/users/update-image';
    
    final response = await widget.apiService.put(
      path: url,
      data: formData,
    );
    
    print("Respuesta del servidor: ${response.statusCode} - ${response.data}");
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      await _updateImageSuccessfully(imageFile.path, index: index);
      _showSuccessSnackbar('Imagen actualizada correctamente');
    } else {
      setState(() => _isLoading = false);
      _showErrorSnackbar('Error del servidor: ${response.statusCode}');
    }
  }
  
  // MÉTODO CORREGIDO - Separado para manejar reemplazo de imagen de mascota
  Future<void> _handlePetImageReplace(File imageFile, int index) async {
    if (widget.userUID == null) {
      throw Exception('userUID es requerido para actualizar mascota');
    }
    
    FormData formData = FormData();
    
    // CLAVE: Enviar información sobre el reemplazo específico
    formData.fields.add(MapEntry('action', 'replacePhoto'));
    formData.fields.add(MapEntry('replaceIndex', index.toString()));
    formData.fields.add(MapEntry('currentImageOrder', _imagenes.join(',')));
    
    // Mantener la numeración original para evitar confusiones
    int imageNumber = index + 1;
    formData.files.add(MapEntry(
      'petImage$imageNumber',
      await MultipartFile.fromFile(
        imageFile.path,
        filename: 'pet_image_${imageNumber}_replace.${imageFile.path.split('.').last}',
      ),
    ));
    
    // Información adicional para el servidor
    formData.fields.add(MapEntry('preserveMainPhoto', (index != 0).toString()));
    if (index != 0) {
      formData.fields.add(MapEntry('mainPhotoUrl', _imagenes[0]));
    }
    
   // widget.apiService.dioClient.options.headers['userUID'] = widget.userUID!;
    
    final String url = '/orquestador/api/pets/update/${widget.entidadId}';
    
    final response = await widget.apiService.put(
      path: url,
      data: formData,
    );
    
    print("Respuesta del servidor para reemplazo: ${response.statusCode} - ${response.data}");
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      await _updateImageSuccessfully(imageFile.path, index: index);
      _showSuccessSnackbar('Imagen reemplazada correctamente');
    } else {
      setState(() => _isLoading = false);
      _showErrorSnackbar('Error del servidor: ${response.statusCode}');
    }
  }
  
  // Método unificado para actualizar exitosamente una imagen
  Future<void> _updateImageSuccessfully(String imagePath, {int? index, bool isAdd = false}) async {
    // Limpiar todos los cachés antes de actualizar
    _clearAllImageCaches();
    
    // Crear URL única con timestamp para evitar caché
    String newImageUrl = '${imagePath}?t=${DateTime.now().millisecondsSinceEpoch}';
    
    setState(() {
      List<String> newImagenes = List.from(_imagenes);
      
      if (isAdd) {
        // Añadir nueva imagen
        newImagenes.add(newImageUrl);
      } else if (index != null) {
        // Reemplazar imagen existente SIN AFECTAR EL ORDEN
        newImagenes[index] = newImageUrl;
        print("🔄 Reemplazando imagen en índice $index");
        print("📋 Antes: $_imagenes");
        print("📋 Después: $newImagenes");
      }
      
      _imagenes = newImagenes;
      _rebuildCounter++; // Incrementar contador para forzar reconstrucción
      _isLoading = false;
    });
    
    // Notificar al widget padre
    widget.onImagesUpdated(_imagenes);
    print("Imagen actualizada con éxito: $newImageUrl");
    
    // Forzar actualización completa con múltiples estrategias
    await _forceCompleteRefresh();
  }
  
  // Método para forzar actualización completa
  Future<void> _forceCompleteRefresh() async {
    // Primera actualización inmediata
    if (mounted) {
      setState(() {
        _rebuildCounter++;
      });
      _clearAllImageCaches();
    }
    
    // Segunda actualización después de un breve retraso
    await Future.delayed(const Duration(milliseconds: 50));
    if (mounted) {
      setState(() {
        _rebuildCounter++;
      });
      _clearAllImageCaches();
    }
    
    // Tercera actualización para asegurar que todo se actualizó
    await Future.delayed(const Duration(milliseconds: 100));
    if (mounted) {
      setState(() {
        _rebuildCounter++;
      });
      _clearAllImageCaches();
    }
  }

  // MÉTODO PRINCIPAL CORREGIDO - Establecer foto como principal
  Future<void> _handleSetMainPhoto(int index) async {
    if (index == 0 || widget.tipo != 'mascota') return;

    try {
      setState(() => _isLoading = true);
      print("🔄 Estableciendo foto en posición $index como principal");
      print("📋 Estado actual de imágenes: $_imagenes");

      if (widget.userUID == null) {
        throw Exception('userUID es requerido para actualizar mascota');
      }

      // Preparar la lista reordenada LOCALMENTE
      List<String> reorderedImages = List.from(_imagenes);
      String newMainImage = reorderedImages[index];
      String oldMainImage = reorderedImages[0];
      
      // Intercambiar las imágenes
      reorderedImages[0] = newMainImage;
      reorderedImages[index] = oldMainImage;
      
      print("🔄 Nuevo orden que se enviará: $reorderedImages");

      // Crear FormData con información del cambio
      FormData formData = FormData();
      formData.fields.add(MapEntry('action', 'setMainPhoto'));
      formData.fields.add(MapEntry('newMainIndex', index.toString()));
      formData.fields.add(MapEntry('currentImageOrder', _imagenes.join(',')));
      formData.fields.add(MapEntry('newImageOrder', reorderedImages.join(',')));

     // widget.apiService.dioClient.options.headers['userUID'] = widget.userUID!;
      
      final String url = '/orquestador/api/pets/update/${widget.entidadId}';
      
      final response = await widget.apiService.put(
        path: url,
        data: formData,
      );
      
      print("📡 Respuesta del servidor: ${response.statusCode} - ${response.data}");
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        // CAMBIO CLAVE: Limpiar caché y actualizar INMEDIATAMENTE
        _clearAllImageCaches();
        
        // Actualizar el estado local con el nuevo orden
        setState(() {
          _imagenes = List.from(reorderedImages); // Nueva lista para evitar referencias
          _rebuildCounter++;
          _isLoading = false;
        });

        print("✅ Estado local actualizado: $_imagenes");
        
        // Notificar al widget padre INMEDIATAMENTE
        widget.onImagesUpdated(List.from(_imagenes));
        
        _showSuccessSnackbar('Foto principal actualizada correctamente');
        
        // Forzar múltiples actualizaciones para asegurar que todo se refleje
        await _forceCompleteRefresh();
        
        print("🎯 Foto establecida como principal completamente");
      } else {
        setState(() => _isLoading = false);
        _showErrorSnackbar('Error del servidor al cambiar foto principal: ${response.statusCode}');
      }
      
    } catch (apiError) {
      print("❌ Error en API al establecer foto principal: $apiError");
      setState(() => _isLoading = false);
      _showErrorSnackbar('Error al comunicarse con el servidor: $apiError');
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackbar('Error al establecer foto principal: $e');
      print("❌ Error estableciendo foto principal: $e");
    }
  }

  // Método mejorado para construir widget de imagen
  Widget _buildImageWidget(String imagePath, int index) {
    // Key única que incluye el índice, path, timestamp y contador de reconstrucción
    final uniqueKey = ValueKey<String>('image_${index}_${imagePath.hashCode}_${_rebuildCounter}_${DateTime.now().millisecondsSinceEpoch}');
    
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return _buildNetworkImage(imagePath, uniqueKey);
    } else {
      return _buildLocalImage(imagePath, uniqueKey);
    }
  }
  
  // Widget para imagen de red
  Widget _buildNetworkImage(String imagePath, Key uniqueKey) {
    print("Cargando imagen de red: $imagePath");
    
    // Añadir parámetros únicos para evitar caché
    final String cacheBustUrl = imagePath.contains('?') 
        ? '$imagePath&t=${DateTime.now().millisecondsSinceEpoch}&r=$_rebuildCounter' 
        : '$imagePath?t=${DateTime.now().millisecondsSinceEpoch}&r=$_rebuildCounter';
    
    return Image.network(
      cacheBustUrl,
      key: uniqueKey,
      fit: BoxFit.cover,
      width: _imageSize,
      height: _imageHeight,
      cacheWidth: null,
      cacheHeight: null,
      headers: {
        'Cache-Control': 'no-cache, no-store, must-revalidate',
        'Pragma': 'no-cache',
        'Expires': '0',
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded / 
                    loadingProgress.expectedTotalBytes!
                : null,
            strokeWidth: 2.0,
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        print("Error cargando imagen de red: $error");
        return Container(
          width: _imageSize,
          height: _imageHeight,
          color: Colors.grey[300],
          child: Icon(Icons.broken_image, color: Colors.grey[600]),
        );
      },
    );
  }
  
  // Widget para imagen local
  Widget _buildLocalImage(String imagePath, Key uniqueKey) {
    print("Cargando imagen local: $imagePath");
    
    try {
      String cleanPath = imagePath;
      if (cleanPath.startsWith('file://')) {
        cleanPath = cleanPath.substring(7);
      }
      
      // Remover parámetros de query si existen para la verificación del archivo
      final cleanPathForFile = cleanPath.split('?').first;
      final file = File(cleanPathForFile);
      
      if (!file.existsSync()) {
        print("El archivo no existe: $cleanPathForFile");
        return Container(
          width: _imageSize,
          height: _imageHeight,
          color: Colors.grey[300],
          child: Icon(Icons.image_not_supported, color: Colors.grey[600]),
        );
      }
      
      // Leer bytes del archivo cada vez para evitar caché
      return FutureBuilder<Uint8List>(
        key: uniqueKey,
        future: file.readAsBytes(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print("Error leyendo archivo: ${snapshot.error}");
            return Container(
              width: _imageSize,
              height: _imageHeight,
              color: Colors.grey[300],
              child: Icon(Icons.broken_image, color: Colors.grey[600]),
            );
          }
          
          if (!snapshot.hasData) {
            return Container(
              width: _imageSize,
              height: _imageHeight,
              color: Colors.grey[100],
              child: const Center(
                child: CircularProgressIndicator(strokeWidth: 2.0),
              ),
            );
          }
          
          return Image.memory(
            snapshot.data!,
            key: ValueKey('memory_image_${uniqueKey.toString()}_${snapshot.data!.length}'),
            fit: BoxFit.cover,
            width: _imageSize,
            height: _imageHeight,
            cacheWidth: null,
            cacheHeight: null,
            gaplessPlayback: false,
            errorBuilder: (context, error, stackTrace) {
              print("Error mostrando imagen desde memoria: $error");
             return Container(
               width: _imageSize,
               height: _imageHeight,
               color: Colors.grey[300],
               child: Icon(Icons.broken_image, color: Colors.grey[600]),
             );
           },
         );
       },
     );
   } catch (e) {
     print("Error procesando imagen local: $e");
     return Container(
       width: _imageSize,
       height: _imageHeight,
       color: Colors.grey[300],
       child: Icon(Icons.error, color: Colors.grey[600]),
     );
   }
 }

 // Método para mostrar mensaje de éxito
 void _showSuccessSnackbar(String message) {
   if (mounted) {
     ScaffoldMessenger.of(context).showSnackBar(
       SnackBar(
         content: Text(message),
         backgroundColor: Colors.green,
         duration: const Duration(seconds: 2),
       ),
     );
   }
 }

 // Método para mostrar mensaje de error
 void _showErrorSnackbar(String message) {
   if (mounted) {
     ScaffoldMessenger.of(context).showSnackBar(
       SnackBar(
         content: Text(message),
         backgroundColor: Colors.red,
         duration: const Duration(seconds: 3),
       ),
     );
   }
 }

 @override
 void dispose() {
   // Limpiar caché al destruir el widget
   _clearAllImageCaches();
   super.dispose();
 }
}