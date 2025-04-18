// widgets/comentario_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../Models/publicacion.dart';
import '../../Modules/SocialModule/State/social_provider.dart';
import '../../Modules/HomeModule/State/mascota_provider.dart';

class ComentarioBottomSheet extends StatefulWidget {
  final Publicacion publicacion;
  final MascotaProvider mascotaProvider;
  final SocialProvider socialProvider;

  const ComentarioBottomSheet({
    Key? key,
    required this.publicacion,
    required this.mascotaProvider,
    required this.socialProvider,
  }) : super(key: key);

  @override
  _ComentarioBottomSheetState createState() => _ComentarioBottomSheetState();
}

class _ComentarioBottomSheetState extends State<ComentarioBottomSheet> {
  final TextEditingController _comentarioController = TextEditingController();
  bool _isComposing = false;

  @override
  void dispose() {
    _comentarioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Inicializar el paquete timeago para español
    timeago.setLocaleMessages('es', timeago.EsMessages());

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Barra de título
          Container(
            padding: EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Center(
              child: Text(
                'Comentarios',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Lista de comentarios
          Expanded(
            child: widget.publicacion.comentarios.isEmpty
                ? Center(child: Text('Aún no hay comentarios. ¡Sé el primero!'))
                : ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: widget.publicacion.comentarios.length,
                    itemBuilder: (context, index) {
                      final comentario = widget.publicacion.comentarios[index];
                      final fechaRelativa = timeago.format(comentario.fechaComentario, locale: 'es');

                      return Padding(
                        padding: EdgeInsets.only(bottom: 16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundImage: NetworkImage(comentario.avatarUrl),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        comentario.nombreUsuario,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(width: 6),
                                      Text(
                                        fechaRelativa,
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    comentario.contenido,
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),

          // Campo para escribir nuevo comentario
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: Offset(0, -1),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundImage: NetworkImage(
                      widget.mascotaProvider.miMascota?.fotoPerfil ?? 'https://via.placeholder.com/150',
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _comentarioController,
                      decoration: InputDecoration(
                        hintText: 'Escribe un comentario...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      ),
                      onChanged: (text) {
                        setState(() {
                          _isComposing = text.isNotEmpty;
                        });
                      },
                      maxLines: null,
                    ),
                  ),
                  SizedBox(width: 10),
                  IconButton(
                    icon: Icon(Icons.send),
                    color: _isComposing ? Colors.pink : Colors.grey,
                    onPressed: _isComposing
                        ? () {
                            widget.socialProvider.agregarComentario(
                              widget.publicacion.id,
                              'miUsuario', // En implementación real, obtener del usuario actual
                              widget.mascotaProvider.miMascota?.nombre ?? 'Mi Mascota',
                              widget.mascotaProvider.miMascota?.fotoPerfil ?? 'https://via.placeholder.com/150',
                              _comentarioController.text,
                            );
                            _comentarioController.clear();
                            setState(() {
                              _isComposing = false;
                            });
                            FocusScope.of(context).unfocus();
                          }
                        : null,
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