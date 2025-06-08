import 'package:flutter/material.dart';

class DetalleMascotaScreen extends StatelessWidget {
  final Map<String, dynamic> mascota;

  const DetalleMascotaScreen({super.key, required this.mascota});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(mascota['nombre']),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen de la mascota
            Container(
              width: double.infinity,
              height: 250,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(mascota['imagen']),
                  fit: BoxFit.cover,
                  onError: (exception, stackTrace) {
                    // Manejo de error si la imagen no existe
                  },
                ),
              ),
              child: mascota['imagen'] == null
                  ? Center(child: Icon(Icons.pets, size: 80, color: Colors.grey))
                  : null,
            ),
            
            // Información de la mascota
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        mascota['nombre'],
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildInfoCard(),
                  const SizedBox(height: 20),
                  const Text(
                    'Descripción',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    mascota['descripcion'] ?? 'No hay descripción disponible',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildInfoRow('Especie', mascota['especie'] ?? 'No especificado'),
            const Divider(),
            _buildInfoRow('Raza', mascota['raza'] ?? 'No especificado'),
            const Divider(),
            _buildInfoRow('Edad', '${mascota['edad'] ?? 'No especificado'} años'),
            const Divider(),
            _buildInfoRow('Sexo', mascota['sexo'] ?? 'No especificado'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }








}