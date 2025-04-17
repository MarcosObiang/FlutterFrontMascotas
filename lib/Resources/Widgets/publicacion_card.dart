
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'dart:io';
import '../models/publicacion.dart';
import '../../Modules/SocialModule/State/social_provider.dart';
import '../../Modules/HomeModule/State/mascota_provider.dart';
import './comentario_bottom_sheet.dart';

class PublicacionCard extends StatelessWidget {
  final Publicacion publicacion;

  const PublicacionCard({Key? key, required this.publicacion}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final socialProvider = Provider.of<SocialProvider>(context);
    final mascotaProvider = Provider.of<MascotaProvider>(context);
    
    // Inicializar el paquete timeago para español
    timeago.setLocaleMessages('es', timeago.EsMessages());
    final fechaRelativa = timeago.format(publicacion.fechaPublicacion, locale: 'es');

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado de la publicación
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(publicacion.avatarUrl),
                  radius: 22,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        publicacion.nombreUsuario,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        fechaRelativa,
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            // Contenido de la publicación
            if (publicacion.contenido.isNotEmpty)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  publicacion.contenido,
                  style: TextStyle(fontSize: 16),
                ),
              ),
            
            // Imagen de la publicación (si existe)
            if (publicacion.imagenUrl != null)
              Padding(
                padding: EdgeInsets.only(top: publicacion.contenido.isEmpty ? 12 : 0, bottom: 12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _buildImageWidget(publicacion.imagenUrl!),
                ),
              ),
            
            // Contadores y acciones
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Contador de likes
                Row(
                  children: [
                    Icon(
                      Icons.favorite,
                      size: 18,
                      color: 
Colors.pink
,
                    ),
                    SizedBox(width: 4),
                    Text(
                      '${publicacion.likes}',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
                
                // Contador de comentarios
                InkWell(
                  onTap: () {
                    // Mostrar el bottom sheet de comentarios
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => ComentarioBottomSheet(
                        publicacion: publicacion,
                        mascotaProvider: mascotaProvider,
                        socialProvider: socialProvider,
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 18,
                        color: Colors.grey.shade700,
                      ),
                      SizedBox(width: 4),
                      Text(
                        '${publicacion.comentarios.length}',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            Divider(height: 24),
            
            // Botones de acciones
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Botón de Like
                InkWell(
                  onTap: () {
                    socialProvider.darLike(
publicacion.id
);
                  },
                  child: Row(
                    children: [
                      Icon(
                        publicacion.usuarioDioLike ? Icons.favorite : Icons.favorite_border,
                        color: publicacion.usuarioDioLike ? 
Colors.pink
 : Colors.grey.shade700,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Me gusta',
                        style: TextStyle(
                          color: publicacion.usuarioDioLike ? 
Colors.pink
 : Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Botón de Comentar
                InkWell(
                  onTap: () {
                    // Mostrar el bottom sheet de comentarios
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => ComentarioBottomSheet(
                        publicacion: publicacion,
                        mascotaProvider: mascotaProvider,
                        socialProvider: socialProvider,
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        color: Colors.grey.shade700,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Comentar',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Método para determinar si mostrar una imagen local o de red
  Widget _buildImageWidget(String imagePath) {
    if (imagePath.startsWith('http')) {
      // Es una URL de imagen en línea
      return 
Image.network
(
        imagePath,
        height: 250,
        width: double.infinity,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            height: 250,
            width: double.infinity,
            color: Colors.grey.shade200,
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 250,
            width: double.infinity,
            color: Colors.grey.shade200,
            child: Center(
              child: Icon(Icons.broken_image, size: 40, color: Colors.grey),
            ),
          );
        },
      );
    } else {
      // Es una ruta de archivo local
      return Image.file(
        File(imagePath),
        height: 250,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 250,
            width: double.infinity,
            color: Colors.grey.shade200,
            child: Center(
              child: Icon(Icons.broken_image, size: 40, color: Colors.grey),
            ),
          );
        },
      );
    }
  }
} 