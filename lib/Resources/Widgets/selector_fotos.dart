// widgets/selector_fotos.dart
import 'package:flutter/material.dart';

class SelectorFotos extends StatelessWidget {
  final List<String> fotos;
  final int maxFotos;
  final Function(String) onFotoPrincipalChanged;

  const SelectorFotos({
    Key? key,
    required this.fotos,
    required this.maxFotos,
    required this.onFotoPrincipalChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: fotos.length < maxFotos ? fotos.length + 1 : fotos.length,
        itemBuilder: (context, index) {
          // Botón para añadir una nueva foto
          if (index == fotos.length && fotos.length < maxFotos) {
            return Container(
              width: 100,
              margin: EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[400]!),
              ),
              child: IconButton(
                icon: Icon(Icons.add_photo_alternate, size: 40, color: Colors.grey[600]),
                onPressed: () {
                  // Aquí iría la lógica para añadir una nueva foto
                  // Por ejemplo, mostrando un diálogo para seleccionar una imagen
                  _mostrarDialogoSeleccionarFoto(context);
                },
              ),
            );
          }
          
          // Mostrar foto existente
          return GestureDetector(
            onTap: () => onFotoPrincipalChanged(fotos[index]),
            child: Stack(
              children: [
                Container(
                  width: 100,
                  margin: EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: index == 0 ? Colors.pink : Colors.grey[400]!,
                      width: 2,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.network(
                      fotos[index],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: Icon(Icons.broken_image, color: Colors.grey[600]),
                        );
                      },
                    ),
                  ),
                ),
                // Indicador de foto principal
                if (index == 0)
                  Positioned(
                    top: 5,
                    right: 13,
                    child: Container(
                      padding: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.pink,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.star,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                // Botón para eliminar foto
                Positioned(
                  top: 5,
                  right: index == 0 ? null : 13,
                  left: index == 0 ? 13 : null,
                  child: GestureDetector(
                    onTap: () {
                      // Lógica para eliminar la foto
                      // Por simplicidad, no implementamos aquí
                    },
                    child: Container(
                      padding: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close,
                        size: 14,
                        color: Colors.white,
                      ),
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

  void _mostrarDialogoSeleccionarFoto(BuildContext context) {
    // Este método sería para implementar la selección de fotos
    // Por simplicidad, no lo implementamos completamente
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Seleccionar foto'),
        content: Text('Aquí irían opciones para seleccionar una imagen'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
        ],
      ),
    );
  }
}