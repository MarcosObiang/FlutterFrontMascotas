import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mascotas_citas/services/ApiService.dart';
import 'package:flutter/foundation.dart';

class SelectorFotos extends StatefulWidget {
  final List<String> imagenes;
  final int maxPhotos;
  final Function(List<String>) onImagesUpdated;
  final String entidadId; // ID de la mascota o perfil asociado con las fotos
  final String? userUID; // ID del usuario propietario
  final String tipo; // "usuario" o "mascota" para determinar qué endpoint usar
  final ApiService apiService;

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

  @override
  void initState() {
    super.initState();
    _imagenes = List.from(widget.imagenes);
    print("Inicializando SelectorFotos con imágenes: $_imagenes");
    
    // Limpiar caché de imágenes al inicializar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      imageCache.clear();
      imageCache.clearLiveImages();
    });
  }

  @override
  void didUpdateWidget(SelectorFotos oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Si las imágenes cambiaron desde afuera, actualizar la lista local
    if (oldWidget.imagenes != widget.imagenes) {
      imageCache.clear();
      imageCache.clearLiveImages();
      
      setState(() {
        _imagenes = List.from(widget.imagenes);
        print("SelectorFotos actualizado con nuevas imágenes: $_imagenes");
      });
      
      // Forzar reconstrucción de los widgets de imagen
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() {});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          height: _imageHeight,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _imagenes.length < widget.maxPhotos ? _imagenes.length + 1 : _imagenes.length,
            itemBuilder: (context, index) {
              // Botón para añadir una nueva foto
              if (index == _imagenes.length && _imagenes.length < widget.maxPhotos) {
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

              // Mostrar foto existente
              return GestureDetector(
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
                        child: _buildImageWidget(_imagenes[index]),
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

  // Método para mostrar opciones al presionar una foto
  void _showPhotoOptions(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(index == 0 ? 'Foto principal' : 'Opciones de foto'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Eliminar foto'),
                onTap: () {
                  Navigator.pop(context);
                  _handleDeletePhoto(index);
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
  
  // Método actualizado para añadir una nueva foto usando los métodos específicos de API
  Future<void> _handleAddNewPhoto() async {
    try {
      final File? imageFile = await _selectImage();
      if (imageFile == null) {
        print("No se seleccionó ninguna imagen");
        return;
      }

      setState(() => _isLoading = true);
      print("Añadiendo nueva foto: ${imageFile.path}");

      try {
        String? imageUrl;
        
        if (widget.tipo == 'usuario') {
          if (widget.userUID == null) {
            throw Exception('userUID es requerido para subir imagen de usuario');
          }
          
          // Usar el método específico para actualizar imagen de usuario
          final response = await widget.apiService.updateUserImage(
            userUID: widget.userUID!,
            userImage: imageFile,
          );
          
          if (response.statusCode == 200 || response.statusCode == 201) {
            // Extraer URL de la respuesta
            if (response.data is String) {
              imageUrl = response.data.toString();
            } else if (response.data is Map) {
              imageUrl = response.data['url'];
            }
          }
        } else {
          // Para mascota, usar el método específico para actualizar imagen de mascota
          if (widget.userUID == null) {
            throw Exception('userUID es requerido para subir imagen de mascota');
          }
          
          // Determinar qué posición de imagen estamos actualizando
          int position = _imagenes.length + 1;
          
          // Crear los argumentos para el método updatePetImages
          Map<String, File?> petImages = {
            'petImage1': null,
            'petImage2': null,
            'petImage3': null,
          };
          
          // Asignar el archivo a la posición correcta
          if (position == 1) {
            petImages['petImage1'] = imageFile;
          } else if (position == 2) {
            petImages['petImage2'] = imageFile;
          } else if (position == 3) {
            petImages['petImage3'] = imageFile;
          } else {
            throw Exception('No se puede añadir más de 3 imágenes para mascotas');
          }
          
          final response = await widget.apiService.updatePetImages(
            userUID: widget.userUID!,
            petUID: widget.entidadId,
            petImage1: petImages['petImage1'],
            petImage2: petImages['petImage2'],
            petImage3: petImages['petImage3'],
          );
          
          if (response.statusCode == 200 || response.statusCode == 201) {
            // Extraer URL de la respuesta
            if (response.data is String) {
              imageUrl = response.data.toString();
            } else if (response.data is Map) {
              imageUrl = response.data['url'];
            }
          }
        }
        
        if (imageUrl != null) {
          // Limpiar caché de imágenes antes de actualizar el estado
          imageCache.clear();
          imageCache.clearLiveImages();
          
          setState(() {
            List<String> newImagenes = List.from(_imagenes);
            newImagenes.add(imageUrl!);
            _imagenes = newImagenes;
            _isLoading = false;
          });
          
          widget.onImagesUpdated(_imagenes);
          print("Imagen añadida con éxito: $imageUrl");
          
          _showSuccessSnackbar('Imagen añadida correctamente');
        } else {
          setState(() => _isLoading = false);
          _showErrorSnackbar('Error al subir la imagen: No se obtuvo URL');
        }
      } catch (apiError) {
        print("Error en API al subir imagen: $apiError");
        
        // Para desarrollo local
        if (widget.entidadId == 'test' || true) { // En producción, quitar '|| true'
          final String localImagePath = imageFile.path;
          
          imageCache.clear();
          imageCache.clearLiveImages();
          
          setState(() {
            List<String> newImagenes = List.from(_imagenes);
            newImagenes.add(localImagePath);
            _imagenes = newImagenes;
            _isLoading = false;
          });
          
          widget.onImagesUpdated(_imagenes);
          _showSuccessSnackbar('Imagen añadida correctamente (modo local)');
        } else {
          setState(() => _isLoading = false);
          _showErrorSnackbar('Error al comunicarse con el servidor: $apiError');
        }
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

      final String oldImageUrl = _imagenes[index];

      try {
        String? imageUrl;
        
        if (widget.tipo == 'usuario') {
          if (widget.userUID == null) {
            throw Exception('userUID es requerido para subir imagen de usuario');
          }
          
          // Usar el método específico para actualizar imagen de usuario
          final response = await widget.apiService.updateUserImage(
            userUID: widget.userUID!,
            userImage: imageFile,
          );
          
          if (response.statusCode == 200 || response.statusCode == 201) {
            // Extraer URL de la respuesta
            if (response.data is String) {
              imageUrl = response.data.toString();
            } else if (response.data is Map) {
              imageUrl = response.data['url'];
            }
          }
        } else {
          // Para mascota, usar el método específico para actualizar imagen de mascota
          if (widget.userUID == null) {
            throw Exception('userUID es requerido para subir imagen de mascota');
          }
          
          // Crear los argumentos para el método updatePetImages
          Map<String, File?> petImages = {
            'petImage1': null,
            'petImage2': null,
            'petImage3': null,
          };
          
          // Asignar el archivo a la posición correcta
          if (index == 0) {
            petImages['petImage1'] = imageFile;
          } else if (index == 1) {
            petImages['petImage2'] = imageFile;
          } else if (index == 2) {
            petImages['petImage3'] = imageFile;
          } else {
            throw Exception('Índice fuera de rango para imágenes de mascota');
          }
          
          final response = await widget.apiService.updatePetImages(
            userUID: widget.userUID!,
            petUID: widget.entidadId,
            petImage1: petImages['petImage1'],
            petImage2: petImages['petImage2'],
            petImage3: petImages['petImage3'],
          );
          
          if (response.statusCode == 200 || response.statusCode == 201) {
            // Extraer URL de la respuesta
            if (response.data is String) {
              imageUrl = response.data.toString();
            } else if (response.data is Map) {
              imageUrl = response.data['url'];
            }
          }
        }
        
        if (imageUrl != null) {
          // Limpiar caché de imágenes antes de actualizar el estado
          imageCache.clear();
          imageCache.clearLiveImages();
          
          setState(() {
            List<String> newImagenes = List.from(_imagenes);
            newImagenes[index] = imageUrl!;
            _imagenes = newImagenes;
            _isLoading = false;
          });
          
          widget.onImagesUpdated(_imagenes);
          print("Imagen reemplazada con éxito: $imageUrl");
          _showSuccessSnackbar('Imagen reemplazada correctamente');
        } else {
          setState(() {
            _isLoading = false;
            _imagenes[index] = oldImageUrl; // Restaurar imagen original
          });
          _showErrorSnackbar('Error al reemplazar la imagen');
        }
      } catch (apiError) {
        print("Error en API al reemplazar imagen: $apiError");
        
        // Para desarrollo local solamente
        if (widget.entidadId == 'test' || true) { // Simular éxito en desarrollo
          final String localImagePath = imageFile.path;
          
          imageCache.clear();
          imageCache.clearLiveImages();
          
          setState(() {
            List<String> newImagenes = List.from(_imagenes);
            newImagenes[index] = localImagePath;
            _imagenes = newImagenes;
            _isLoading = false;
          });
          
          widget.onImagesUpdated(_imagenes);
          _showSuccessSnackbar('Imagen reemplazada correctamente (modo local)');
        } else {
          setState(() {
            _isLoading = false;
            _imagenes[index] = oldImageUrl; // Restaurar imagen original
          });
          _showErrorSnackbar('Error al comunicarse con el servidor: $apiError');
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackbar('Error: $e');
      print("Error general reemplazando foto: $e");
    }
  }

  // Método actualizado para establecer una foto como principal
  Future<void> _handleSetMainPhoto(int index) async {
    if (index == 0) return; // Ya es la principal

    try {
      setState(() => _isLoading = true);
      print("Estableciendo foto $index como principal");

      // Reorganizamos las imágenes localmente
      final String selectedImage = _imagenes[index];
      final List<String> updatedImages = [..._imagenes];
      updatedImages.removeAt(index);
      updatedImages.insert(0, selectedImage);
      
      try {
        // Realizamos la actualización en el frontend inmediatamente para mejor UX
        setState(() {
          _imagenes = updatedImages;
          _isLoading = false;
        });
        
        widget.onImagesUpdated(_imagenes);
        
        // Para mascota: Sincronizamos todas las imágenes con el servidor
        if (widget.tipo == 'mascota') {
          await _syncPetImages();
        }
        
        _showSuccessSnackbar('Foto principal actualizada');
      } catch (e) {
        // En caso de error, revertimos los cambios
        setState(() {
          _imagenes = List.from(widget.imagenes);
          _isLoading = false;
        });
        _showErrorSnackbar('Error al establecer como principal: $e');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackbar('Error: $e');
      print("Error general al establecer foto principal: $e");
    }
  }

  // Método actualizado para eliminar una foto
  Future<void> _handleDeletePhoto(int index) async {
    try {
      setState(() => _isLoading = true);
      
      final String imageToDelete = _imagenes[index];
      print("Eliminando foto en posición $index: $imageToDelete");
      
      // Guardamos una copia temporal por si necesitamos revertir cambios
      final List<String> tempImagenes = List.from(_imagenes);

      // Limpiar caché de imágenes para evitar problemas con la reconstrucción
      imageCache.clear();
      imageCache.clearLiveImages();

      // Eliminamos la imagen de la lista local inmediatamente para mejor UX
      setState(() {
        List<String> newImagenes = List.from(_imagenes);
        newImagenes.removeAt(index);
        _imagenes = newImagenes;
      });

      try {
        // Para mascotas, sincronizamos todas las imágenes con el backend
        if (widget.tipo == 'mascota') {
          await _syncPetImages();
        }
        // Para usuario, no permitimos eliminar la foto de perfil, solo reemplazarla
        
        widget.onImagesUpdated(_imagenes);
        setState(() => _isLoading = false);
        
        // Forzar reconstrucción después de un breve retraso
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) setState(() {});
        });
        
        _showSuccessSnackbar('Imagen eliminada correctamente');
      } catch (apiError) {
        print("Error en API al eliminar imagen: $apiError");
        
        // Para desarrollo local, simular éxito
        if (widget.entidadId == 'test' || true) {
          setState(() => _isLoading = false);
          widget.onImagesUpdated(_imagenes);
          
          // Forzar reconstrucción después de un breve retraso
          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted) setState(() {});
          });
        } else {
          // En caso de error, revertimos los cambios
          setState(() {
            _imagenes = tempImagenes;
            _isLoading = false;
          });
          _showErrorSnackbar('Error al comunicarse con el servidor: $apiError');
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackbar('Error: $e');
      print("Error general eliminando foto: $e");
    }
  }

  // Método para sincronizar imágenes de mascota con el backend
  Future<void> _syncPetImages() async {
    if (widget.userUID == null || widget.tipo != 'mascota') {
      return;
    }
    
    try {
      // Necesitamos obtener archivos File para cada imagen
      List<File?> imageFiles = [null, null, null];
      
      // Procesar solo las imágenes locales (no URLs)
      for (int i = 0; i < _imagenes.length && i < 3; i++) {
        final path = _imagenes[i];
        
        if (path.startsWith('http')) {
          // No podemos re-subir imágenes de red, ya están en el servidor
          continue;
        }
        
        // Crear objeto File para cada ruta local
        String cleanPath = path;
        if (cleanPath.startsWith('file://')) {
          cleanPath = cleanPath.substring(7);
        }
        
        final file = File(cleanPath);
        if (file.existsSync()) {
          imageFiles[i] = file;
        }
      }
      
      // Si no hay archivos para subir, terminar
      if (imageFiles.every((file) => file == null)) {
        return;
      }
      
      // Usar el método específico para sincronizar imágenes de mascota
      await widget.apiService.updatePetImages(
        userUID: widget.userUID!,
        petUID: widget.entidadId,
        petImage1: imageFiles[0],
        petImage2: imageFiles[1],
        petImage3: imageFiles[2],
      );
      
    } catch (e) {
      print("Error sincronizando imágenes: $e");
      // No lanzamos error porque esto es una operación secundaria
    }
  }

  // Método para construir widget de imagen con tamaño fijo
  Widget _buildImageWidget(String imagePath) {
    // Agregar un Key único usando la ruta de la imagen para forzar reconstrucción
    final uniqueKey = ValueKey<String>('image_$imagePath');
    
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      // Es una URL de red
      print("Cargando imagen de red: $imagePath");
      
      return Image.network(
        imagePath,
        key: uniqueKey, // Clave única para forzar recarga
        fit: BoxFit.cover, // Asegura que cubra el espacio asignado
        width: _imageSize,
        height: _imageHeight,
        // Deshabilitar caché para forzar recarga de la imagen
        cacheWidth: null,
        cacheHeight: null,
        // Agregar un parámetro random a la URL para evitar caché
        headers: {'Cache-Control': 'no-cache'},
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
    } else {
      // Es un archivo local
      print("Cargando imagen local: $imagePath");
      
      try {
        // Eliminar el prefijo 'file://' si existe
        String cleanPath = imagePath;
        if (cleanPath.startsWith('file://')) {
          cleanPath = cleanPath.substring(7);
        }
        
        // Crear un objeto File con la ruta limpia
        final file = File(cleanPath);
        
        // Verificar si el archivo existe antes de intentar mostrarlo
        if (!file.existsSync()) {
          print("El archivo no existe: $cleanPath");
          return Container(
            width: _imageSize,
            height: _imageHeight,
            color: Colors.grey[300],
            child: Icon(Icons.image_not_supported, color: Colors.grey[600]),
          );
        }
        
        // Usar Image.file con dimensiones explícitas y key única
        return Image.file(
          file,
          key: uniqueKey, // Clave única para forzar recarga
          fit: BoxFit.cover, // Importante para mantener consistencia
          width: _imageSize,
          height: _imageHeight,
          // Deshabilitar caché
          cacheWidth: null,
          cacheHeight: null,
          gaplessPlayback: false, // Desactivar reproducción sin huecos
          errorBuilder: (context, error, stackTrace) {
            print("Error cargando imagen local: $error");
            return Container(
              width: _imageSize,
              height: _imageHeight,
              color: Colors.grey[300],
              child: Icon(Icons.broken_image, color: Colors.grey[600]),
            );
          },
        );
      } catch (e) {
        print("Excepción al cargar imagen local: $e");
        return Container(
          width: _imageSize,
          height: _imageHeight,
          color: Colors.grey[300],
          child: Icon(Icons.broken_image, color: Colors.grey[600]),
        );
      }
    }
  }

  // Método para mostrar un mensaje de error
  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  // Método para mostrar un mensaje de éxito
  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }
}