// screens/conversacion_screen.dart
import 'package:flutter/material.dart';
import 'package:mascotas_citas/Resources/Models/mascota.dart';
import 'package:mascotas_citas/Resources/Models/mensaje.dart';
import 'package:mascotas_citas/Resources/widgets/burbuja_mensaje.dart';
import 'package:mascotas_citas/Modules/MatchesModule/Views/detalle_match_screen.dart';
// Remove the uuid import: import 'package:uuid/uuid.dart';

// Simple UUID generator class to replace the uuid package
class SimpleUuidGenerator {
  int _counter = 0;
  final String _deviceId = DateTime.now().millisecondsSinceEpoch.toString();
  
  String v4() {
    _counter++;
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '${_deviceId}_${timestamp}_$_counter';
  }
}

class ConversacionScreen extends StatefulWidget {
  final Mascota mascota;
  final String matchId;
  final List<Mensaje> mensajes;
  final Function(Mensaje) onMensajeEnviado;
  
  const ConversacionScreen({
    super.key, 
    required this.mascota,
    required this.matchId,
    required this.mensajes,
    required this.onMensajeEnviado,
  });
  
  @override
  _ConversacionScreenState createState() => _ConversacionScreenState();
}

class _ConversacionScreenState extends State<ConversacionScreen> {
  final TextEditingController _mensajeController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  // Replace uuid with our simple generator
  final SimpleUuidGenerator _uuidGenerator = SimpleUuidGenerator();
  
  // Lista local de mensajes
  late List<Mensaje> _mensajes;
  
  @override
  void initState() {
    super.initState();
    // Copiamos los mensajes recibidos por parámetro
    _mensajes = List.from(widget.mensajes);
    
    // Hacemos scroll hacia abajo cuando se carga la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients && _mensajes.isNotEmpty) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
  
  @override
  void dispose() {
    _mensajeController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
  
  void _enviarMensaje() {
    if (_mensajeController.text.trim().isEmpty) return;
    
    // Crear un nuevo mensaje
    final nuevoMensaje = Mensaje(
      id: _uuidGenerator.v4(), // Use our custom UUID generator
      matchId: widget.matchId,
      emisorId: '1', // ID de nuestra mascota
      contenido: _mensajeController.text,
      fechaEnvio: DateTime.now(),
      leido: false,
    );
    
    // Actualizar la lista local
    setState(() {
      _mensajes.add(nuevoMensaje);
      _mensajeController.clear();
    });
    
    // Notificar al padre
    widget.onMensajeEnviado(nuevoMensaje);
    
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
      body: Column(
        children: [
          Expanded(
            child: _mensajes.isEmpty
                ? _construirMensajeInicial()
                : _construirListaMensajes(),
          ),
          _construirInputMensaje(),
        ],
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
  
  Widget _construirListaMensajes() {
    // ID de nuestra mascota
    const String miMascotaId = '1';
    
    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      itemCount: _mensajes.length,
      itemBuilder: (context, index) {
        final mensaje = _mensajes[index];
        final esMio = mensaje.emisorId == miMascotaId;
        
        return BurbujaMensaje(
          mensaje: mensaje.contenido,
          esMio: esMio,
          fecha: mensaje.fechaEnvio,
        );
      },
    );
  }
  
  Widget _construirInputMensaje() {
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
              onPressed: _enviarMensaje,
            ),
          ),
        ],
      ),
    );
  }
}