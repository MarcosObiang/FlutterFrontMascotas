// lib/Resources/Widgets/tarjeta_mascota.dart

import 'package:flutter/material.dart';
import '../Models/mascota_api.dart';

class TarjetaMascota extends StatelessWidget {
  final Mascota mascota;
  
  const TarjetaMascota({
    super.key,
    required this.mascota,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Imagen principal de la mascota
          Expanded(
            flex: 3,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Imagen principal
                mascota.fotos.isNotEmpty
                    ? Image.network(
                        mascota.fotos[0],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            'assets/images/placeholder_pet.jpg',
                            fit: BoxFit.cover,
                          );
                        },
                      )
                    : Image.asset(
                        'assets/images/placeholder_pet.png',
                        fit: BoxFit.cover,
                      ),
                
                // Gradiente
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.8),
                        ],
                      ),
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
                          Text(
                            mascota.nombre,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            mascota.edad,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            mascota.especie.toLowerCase() == 'perro' || mascota.especie.toLowerCase() == 'dog'
                                ? Icons.pets
                                : Icons.emoji_nature,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            mascota.raza,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.location_on,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            mascota.ubicacion,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Etiqueta de adopción si aplica
                if (mascota.enAdopcion)
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.pink,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Adopción',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          // Información del propietario/centro
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Descripción de la mascota
                  Text(
                    mascota.descripcion,
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  
                  // Información del propietario/centro
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundImage: NetworkImage(
                          mascota.propietarioFoto ?? mascota.centroFoto ?? 'https://via.placeholder.com/40',
                        ),
                        onBackgroundImageError: (exception, stackTrace) => 
                            const AssetImage('assets/images/placeholder_user.png'),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              mascota.propietarioNombre ?? mascota.centroNombre ?? 'Desconocido',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              mascota.centroAdopcionId != null
                                  ? 'Centro de adopción'
                                  : 'Propietario',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Intereses o características
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: mascota.intereses.map((interes) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          interes,
                          style: const TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}