// screens/matches_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../Resources/Models/mascota.dart';
import '../../HomeModule/State/mascota_provider.dart';
import 'detalle_match_screen.dart';

class MatchesScreen extends StatelessWidget {
  const MatchesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(242, 217, 208, 1),
        title: Text('Mis Matches', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      backgroundColor: Color.fromRGBO(242, 217, 208, 1),
      body: Consumer<MascotaProvider>(
        builder: (context, mascotaProvider, child) {
          final mascotasMatch = mascotaProvider.obtenerMascotasConMatch();
          
          if (mascotasMatch.isEmpty) {
            return Center(
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
            );
          }
          
          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: mascotasMatch.length,
            itemBuilder: (context, index) {
              final mascota = mascotasMatch[index];
              return _construirTarjetaMatch(context, mascota);
            },
          );
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