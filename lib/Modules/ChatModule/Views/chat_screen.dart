// screens/chat_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../State/mascota_provider.dart';
import '../../../Resources/Models/mascota.dart';
import 'conversacion_screen.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(242, 217, 208, 1),
        title: Text('Mis Chats', style: TextStyle(fontWeight: FontWeight.bold)),
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
                  Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No tienes conversaciones',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Haz match con mascotas para comenzar a chatear',
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
              
              // Encontrar match
              final match = mascotaProvider.matches.firstWhere(
                (m) => (m.mascotaId1 == '1' && m.mascotaId2 == mascota.id) || 
                       (m.mascotaId1 == mascota.id && m.mascotaId2 == '1')
              );
              
              // Obtener último mensaje
              final mensajes = mascotaProvider.obtenerMensajesDeMatch(match.id);
              final ultimoMensaje = mensajes.isNotEmpty ? mensajes.last : null;
              
              return _construirTarjetaChat(context, mascota, ultimoMensaje?.contenido, match.id);
            },
          );
        },
      ),
    );
  }
  
  Widget _construirTarjetaChat(BuildContext context, Mascota mascota, String? ultimoMensaje, String matchId) {
    return Card(
      elevation: 3,
      margin: EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ConversacionScreen(mascota: mascota, matchId: matchId),
            ),
          );
        },
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: AssetImage(mascota.fotos.first),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 15,
                      height: 15,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ],
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
                    SizedBox(height: 4),
                    Text(
                      ultimoMensaje ?? 'Comienza una conversación',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Hace 2h',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 4),
                  if (ultimoMensaje != null)
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.pink,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '1',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}