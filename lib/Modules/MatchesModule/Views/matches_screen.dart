// screens/matches_screen.dart
import 'package:flutter/material.dart';
import 'package:mascotas_citas/Resources/Models/mascota.dart';
import 'detalle_match_screen.dart';

class MatchesScreen extends StatelessWidget {
  const MatchesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Datos simulados de mascotas con match
    final List<Mascota> mascotasMatch = [
      Mascota(
        id: 'm1',
        nombre: 'Luna',
        edad: '3',
        especie: 'Perro',
        raza: 'Labrador',
        descripcion: 'Soy juguetona y me encanta nadar',
        fotos: ['assets/images/mascotas/luna.jpg', 'assets/images/mascotas/luna2.jpg'],
        propietarioNombre: 'Carlos Rodríguez',
        propietarioFoto: 'assets/images/usuarios/carlos.jpg',
        ubicacion: 'Madrid',
        intereses: ['Jugar en el parque', 'Nadar', 'Pasear'],
        enAdopcion: false,
        propietarioId: 'u2',
      ),
      Mascota(
        id: 'm2',
        nombre: 'Max',
        edad: '2',
        especie: 'Gato',
        raza: 'Siamés',
        descripcion: 'Soy tranquilo y me gusta dormir al sol',
        fotos: ['assets/images/mascotas/max.jpg', 'assets/images/mascotas/max2.jpg'],
        propietarioNombre: 'Ana Martínez',
        propietarioFoto: 'assets/images/usuarios/ana.jpg',
        ubicacion: 'Barcelona',
        intereses: ['Dormir', 'Jugar con lana', 'Cazar juguetes'],
        enAdopcion: false,
        propietarioId: 'u3',
      ),
      Mascota(
        id: 'm3',
        nombre: 'Rocky',
        edad: '4',
        especie: 'Perro',
        raza: 'Bulldog',
        descripcion: 'Soy cariñoso y me gusta jugar con otros perros',
        fotos: ['assets/images/mascotas/rocky.jpg', 'assets/images/mascotas/rocky2.jpg'],
        propietarioNombre: 'Laura González',
        propietarioFoto: 'assets/images/usuarios/laura.jpg',
        ubicacion: 'Valencia',
        intereses: ['Correr', 'Jugar con pelotas', 'Pasear por la playa'],
        enAdopcion: false,
        propietarioId: 'u4',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(242, 217, 208, 1),
        title: Text('Mis Matches', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      backgroundColor: Color.fromRGBO(242, 217, 208, 1),
      body: mascotasMatch.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.pets, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Aún no tienes matches',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Sigue explorando para encontrar\namigos para tu mascota',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: mascotasMatch.length,
              itemBuilder: (context, index) {
                final mascota = mascotasMatch[index];
                return _construirTarjetaMatch(context, mascota);
              },
            ),
    );
  }
  
  Widget _construirTarjetaMatch(BuildContext context, Mascota mascota) {
    return Card(
      elevation: 3,
      margin: EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetalleMatchScreen(mascota: mascota),
            ),
          );
        },
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: AssetImage(mascota.fotos.first),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mascota.nombre,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      '${mascota.raza}, ${mascota.edad} años',
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 4),
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
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}