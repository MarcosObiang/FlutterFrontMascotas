// Primero, necesitamos actualizar el SocialProvider para manejar publicaciones con imágenes
// providers/social_provider.dart

import 'package:flutter/material.dart';
import '../../../Resources/Models/publicacion.dart';
import '../../../Resources/Models/comentario.dart';

class SocialProvider extends ChangeNotifier {
  List<Publicacion> _publicaciones = [];
  
  List<Publicacion> get publicaciones => _publicaciones;
  
  SocialProvider() {
    _cargarDatosIniciales();
  }
  
  void _cargarDatosIniciales() {
    // Datos de ejemplo para el feed
    _publicaciones = [
      Publicacion(
        id: 'p1',
        usuarioId: 'u1',
        nombreUsuario: 'Luna',
        avatarUrl: 'https://images.unsplash.com/photo-1552053831-71594a27632d?q=80&w=200',
        contenido: '¡Hoy fue un día increíble en el parque! Conocí muchos amigos nuevos.',
        imagenUrl: 'https://images.unsplash.com/photo-1601758124510-52d02ddb7cbd?q=80&w=500',
        fechaPublicacion: DateTime.now().subtract(Duration(hours: 2)),
        likes: 12,
        comentarios: [
          Comentario(
            id: 'c1',
            usuarioId: 'u2',
            nombreUsuario: 'Michi',
            avatarUrl: 'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?q=80&w=200',
            contenido: '¡Qué divertido! A mi también me encanta el parque.',
            fechaComentario: DateTime.now().subtract(Duration(hours: 1)),
          ),
          Comentario(
            id: 'c2',
            usuarioId: 'u3',
            nombreUsuario: 'Max',
            avatarUrl: 'https://images.unsplash.com/photo-1530281700549-e82e7bf110d6?q=80&w=200',
            contenido: '¡La próxima vez vamos juntos!',
            fechaComentario: DateTime.now().subtract(Duration(minutes: 30)),
          ),
        ],
        usuarioDioLike: false,
      ),
      Publicacion(
        id: 'p2',
        usuarioId: 'u2',
        nombreUsuario: 'Michi',
        avatarUrl: 'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?q=80&w=200',
        contenido: 'Mi lugar favorito para tomar el sol... ¿Alguien más ama las ventanas?',
        imagenUrl: 'https://images.unsplash.com/photo-1526336024174-e58f5cdd8e13?q=80&w=500',
        fechaPublicacion: DateTime.now().subtract(Duration(days: 1)),
        likes: 8,
        comentarios: [],
        usuarioDioLike: true,
      ),
    ];
  }
  
  void agregarPublicacion(String usuarioId, String nombreUsuario, String avatarUrl, String contenido, String? imagenUrl) {
    final nuevaPublicacion = Publicacion(
      id: 'p${_publicaciones.length + 1}',
      usuarioId: usuarioId,
      nombreUsuario: nombreUsuario,
      avatarUrl: avatarUrl,
      contenido: contenido,
      imagenUrl: imagenUrl,
      fechaPublicacion: DateTime.now(),
      likes: 0,
      comentarios: [],
      usuarioDioLike: false,
    );
    
    _publicaciones.insert(0, nuevaPublicacion);
    notifyListeners();
  }
  
  void darLike(String publicacionId) {
    final publicacionIndex = _publicaciones.indexWhere((pub) => pub.id == publicacionId);
    if (publicacionIndex != -1) {
      final publicacion = _publicaciones[publicacionIndex];
      
      // Actualizar el estado de like y contador
      final nuevoEstadoLike = !publicacion.usuarioDioLike;
      final nuevosLikes = nuevoEstadoLike 
          ? publicacion.likes + 1 
          : publicacion.likes - 1;
      
      // Crear una nueva instancia con los valores actualizados
      _publicaciones[publicacionIndex] = Publicacion(
        id: publicacion.id,
        usuarioId: publicacion.usuarioId,
        nombreUsuario: publicacion.nombreUsuario,
        avatarUrl: publicacion.avatarUrl,
        contenido: publicacion.contenido,
        imagenUrl: publicacion.imagenUrl,
        fechaPublicacion: publicacion.fechaPublicacion,
        likes: nuevosLikes,
        comentarios: publicacion.comentarios,
        usuarioDioLike: nuevoEstadoLike,
      );
      
      notifyListeners();
    }
  }
  
  void agregarComentario(String publicacionId, String usuarioId, String nombreUsuario, String avatarUrl, String contenido) {
    final publicacionIndex = _publicaciones.indexWhere((pub) => pub.id == publicacionId);
    if (publicacionIndex != -1) {
      final publicacion = _publicaciones[publicacionIndex];
      
      // Crear un nuevo comentario
      final nuevoComentario = Comentario(
        id: 'c${publicacion.comentarios.length + 1}',
        usuarioId: usuarioId,
        nombreUsuario: nombreUsuario,
        avatarUrl: avatarUrl,
        contenido: contenido,
        fechaComentario: DateTime.now(),
      );
      
      // Crear una nueva lista de comentarios con el nuevo comentario
      final nuevosComentarios = List<Comentario>.from(publicacion.comentarios)..add(nuevoComentario);
      
      // Crear una nueva instancia de publicación con la lista actualizada
      _publicaciones[publicacionIndex] = Publicacion(
        id: publicacion.id,
        usuarioId: publicacion.usuarioId,
        nombreUsuario: publicacion.nombreUsuario,
        avatarUrl: publicacion.avatarUrl,
        contenido: publicacion.contenido,
        imagenUrl: publicacion.imagenUrl,
        fechaPublicacion: publicacion.fechaPublicacion,
        likes: publicacion.likes,
        comentarios: nuevosComentarios,
        usuarioDioLike: publicacion.usuarioDioLike,
      );
      
      notifyListeners();
    }
  }
}