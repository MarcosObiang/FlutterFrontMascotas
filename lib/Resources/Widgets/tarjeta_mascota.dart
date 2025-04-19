// Modificación 2: tarjeta_mascota.dart
// Añade manejo de errores para la foto del propietario
import 'package:flutter/material.dart';
import '../../../Resources/Models/mascota.dart';
import 'foto_slider.dart';
import 'interes_chip.dart';

class TarjetaMascota extends StatelessWidget {
  final Mascota mascota;
  
  const TarjetaMascota({super.key, required this.mascota});
  
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: FotoSlider(fotos: mascota.fotos),
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${mascota.nombre}, ${mascota.edad} años',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              mascota.raza,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 16, color: Colors.grey),
                          SizedBox(width: 4),
                          Text(
                            mascota.ubicacion,
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Text(
                    mascota.descripcion,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 14),
                  ),
                  SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: mascota.intereses
                        .map((interes) => InteresChip(texto: interes))
                        .toList(),
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      // Modificamos el CircleAvatar para manejar errores de imagen
                      CircleAvatar(
                        radius: 15,
                        backgroundImage: AssetImage(mascota.propietarioFoto),
                        onBackgroundImageError: (exception, stackTrace) {
                          print("Error al cargar foto del propietario: ${mascota.propietarioFoto}");
                        },
                        backgroundColor: Colors.grey[300],
                        child: mascota.propietarioFoto.isEmpty ? Icon(Icons.person, size: 15) : null,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Dueño: ${mascota.propietarioNombre}',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
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
    );
  }
}