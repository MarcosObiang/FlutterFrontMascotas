import 'package:flutter/material.dart';
import 'package:mascotas_citas/Resources/Models/mascota_api.dart';
import '../../../Resources/Services/api_service.dart';
import 'detalle_match_screen.dart';

class MatchesScreen extends StatefulWidget {
  const MatchesScreen({super.key});

  @override
  State<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen> {
  List<Mascota> matches = [];
  bool isLoading = true;
  String? error;
  
  // Usuario actual (esto debería venir de un servicio de autenticación)
  final usuarioActual = {"id": "usuarioActualId"};
  
  // Instancia del servicio API
  final apiService = ApiService();
  
  @override
  void initState() {
    super.initState();
    cargarMatches();
  }
  
  // Para obtener y mostrar mascotas con match
  void cargarMatches() async {
    setState(() {
      isLoading = true;
      error = null;
    });
    
    try {
      final mascotasConMatch = await apiService.getMatchesWithDetails(usuarioActual["id"]!);
      setState(() {
        matches = mascotasConMatch.cast<Mascota>();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Error al cargar matches: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // backgroundColor: Color.fromRGBO(242, 217, 208, 1),
        title: Text('Mis Matches', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: cargarMatches,
            tooltip: 'Recargar matches',
          ),
        ],
      ),
      // backgroundColor: Color.fromRGBO(242, 217, 208, 1),
      body: isLoading 
        ? Center(child: CircularProgressIndicator())
        : error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(error!, style: TextStyle(color: Colors.red)),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: cargarMatches,
                    child: Text('Reintentar'),
                  ),
                ],
              ),
            )
        : matches.isEmpty
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
              itemCount: matches.length,
              itemBuilder: (context, index) {
                final mascota = matches[index];
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
                backgroundImage: NetworkImage(mascota.fotos.first),
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