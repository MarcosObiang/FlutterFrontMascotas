import 'package:flutter/material.dart';

class DetalleMascotaScreen extends StatelessWidget {
  final Map<String, dynamic> mascota;

  const DetalleMascotaScreen({Key? key, required this.mascota}) : super(key: key);

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
                      _buildAdoptarButton(context),
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
                  _buildContactInfoSection(),
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

  Widget _buildContactInfoSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Información de contacto',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildContactRow(Icons.location_on, 'Centro de Adopción Principal'),
            const SizedBox(height: 8),
            _buildContactRow(Icons.phone, '+34 912 345 678'),
            const SizedBox(height: 8),
            _buildContactRow(Icons.email, 'adopciones@centromascotas.com'),
          ],
        ),
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue),
        const SizedBox(width: 12),
        Text(
          text,
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildAdoptarButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        _mostrarDialogoAdopcion(context);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      ),
      child: const Text(
        'Adoptar',
        style: TextStyle(fontSize: 16),
      ),
    );
  }

  void _mostrarDialogoAdopcion(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Solicitud de adopción'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('¿Deseas iniciar el proceso de adopción para ${mascota['nombre']}?'),
              const SizedBox(height: 16),
              const Text(
                'Nos pondremos en contacto contigo para coordinar una visita al centro.',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                // Aquí se implementaría la lógica para procesar la solicitud
                Navigator.of(context).pop();
                _mostrarConfirmacion(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }

  void _mostrarConfirmacion(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Solicitud de adopción para ${mascota['nombre']} enviada correctamente'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}