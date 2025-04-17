// screens/conversacion_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../Resources/Models/mascota.dart';
import '../../../Resources/Models/mensaje.dart';
import '../State/mascota_provider.dart';
import '../../../Resources/Widgets/burbuja_mensaje.dart';
import '../../MatchesModule/Views/detalle_match_screen.dart';

class ConversacionScreen extends StatefulWidget {
  final Mascota mascota;
  final String matchId;
  
  const ConversacionScreen({super.key, 
    required this.mascota,
    required this.matchId,
  });
  
  @override
  _ConversacionScreenState createState() => _ConversacionScreenState();
}

class _ConversacionScreenState extends State<ConversacionScreen> {
  final TextEditingController _mensajeController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  @override
  void dispose() {
    _mensajeController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
  
  void _enviarMensaje(MascotaProvider provider) {
    if (_mensajeController.text.trim().isEmpty) return;
    
    provider.enviarMensaje(widget.matchId, _mensajeController.text);
    _mensajeController.clear();
    
    // Scroll hacia abajo después de enviar un mensaje
    Future.delayed(Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(      
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(242, 217, 208, 1),
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundImage: AssetImage(widget.mascota.fotos.first),
            ),
            SizedBox(width: 8),
            Text(
              widget.mascota.nombre,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetalleMatchScreen(mascota: widget.mascota),
                ),
              );
            },
          ),
        ],
      ),
      backgroundColor: Color.fromRGBO(242, 217, 208, 1),      
      body: Consumer<MascotaProvider>(
        builder: (context, mascotaProvider, child) {
          final mensajes = mascotaProvider.obtenerMensajesDeMatch(widget.matchId);
          
          return Column(
            children: [
              Expanded(
                child: mensajes.isEmpty
                    ? _construirMensajeInicial()
                    : _construirListaMensajes(mensajes),
              ),
              _construirInputMensaje(mascotaProvider),
            ],
          );
        },
      ),
    );
  }
  
  Widget _construirMensajeInicial() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: AssetImage(widget.mascota.fotos.first),
          ),
          SizedBox(height: 16),
          Text(
            '¡Has hecho match con ${widget.mascota.nombre}!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Envía el primer mensaje para comenzar una conversación',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
  
  Widget _construirListaMensajes(List<Mensaje> mensajes) {
    // ID de nuestra mascota (simulado)
    const String miMascotaId = '1';
    
    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      itemCount: mensajes.length,
      itemBuilder: (context, index) {
        final mensaje = mensajes[index];
        final esMio = mensaje.emisorId == miMascotaId;
        
        return BurbujaMensaje(
          mensaje: mensaje.contenido,
          esMio: esMio,
          fecha: mensaje.fechaEnvio,
        );
      },
    );
  }
  
  Widget _construirInputMensaje(MascotaProvider provider) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.photo_camera, color: Colors.grey),
            onPressed: () {
              // Funcionalidad para enviar foto
            },
          ),
          Expanded(
            child: TextField(
              controller: _mensajeController,
              decoration: InputDecoration(
                hintText: 'Escribe un mensaje...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
          ),
          SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: Colors.pink,
            child: IconButton(
              icon: Icon(Icons.send, color: Colors.white, size: 18),
              onPressed: () => _enviarMensaje(provider),
            ),
          ),
        ],
      ),
    );
  }
}