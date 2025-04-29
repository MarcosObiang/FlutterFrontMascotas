import 'dart:io';
import 'package:flutter/material.dart';

class SelectorFotos extends StatelessWidget {
  final List<String> imagenes;
  final int maxPhotos;
  final Function(int) onSetMainPhoto;
  final VoidCallback onAddNewPhoto;
  final Function(int) onDeletePhoto;
  final Function(int) onReplacePhoto;

  const SelectorFotos({
    super.key,
    required this.imagenes,
    required this.onSetMainPhoto,
    required this.onAddNewPhoto,
    required this.maxPhotos,
    required this.onDeletePhoto,
    required this.onReplacePhoto,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: imagenes.length < maxPhotos ? imagenes.length + 1 : imagenes.length,
        itemBuilder: (context, index) {
          // Botón para añadir una nueva foto
          if (index == imagenes.length && imagenes.length < maxPhotos) {
            return Container(
              width: 100,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[400]!),
              ),
              child: IconButton(
                icon: Icon(Icons.add_photo_alternate, size: 40, color: Colors.grey[600]),
                onPressed: onAddNewPhoto,
              ),
            );
          }

          // Mostrar foto existente
          return GestureDetector(
            onTap: () => _showPhotoOptions(context, index),
            child: Stack(
              children: [
                Container(
                  width: 100,
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
                    child: _buildImageWidget(imagenes[index]),
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
                    onSetMainPhoto(index);
                  },
                ),
              // Opción para reemplazar la foto actual
              ListTile(
                leading: const Icon(Icons.photo_camera, color: Colors.blue),
                title: const Text('Reemplazar foto'),
                onTap: () {
                  Navigator.pop(context);
                  onReplacePhoto(index);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Eliminar foto'),
                onTap: () {
                  Navigator.pop(context);
                  onDeletePhoto(index);
                },
              ),
              // Añadir nueva opción para subir foto
              if (imagenes.length < maxPhotos)
                ListTile(
                  leading: const Icon(Icons.add_photo_alternate, color: Colors.blue),
                  title: const Text('Subir nueva foto'),
                  onTap: () {
                    Navigator.pop(context);
                    onAddNewPhoto();
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

  // Método para manejar diferentes tipos de imágenes (URL o archivos locales)
  Widget _buildImageWidget(String imagePath) {
    if (imagePath.startsWith('file://')) {
      // Es un archivo local
      return Image.file(
        File(imagePath.replaceFirst('file://', '')),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[300],
            child: Icon(Icons.broken_image, color: Colors.grey[600]),
          );
        },
      );
    } else {
      // Es una URL de red
      return Image.network(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[300],
            child: Icon(Icons.broken_image, color: Colors.grey[600]),
          );
        },
      );
    }
  }
}