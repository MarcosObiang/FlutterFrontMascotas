
import 'comentario.dart';

class Publicacion {
  final String id;
  final String usuarioId;
  final String nombreUsuario;
  final String avatarUrl;
  final String contenido;
  final String? imagenUrl;
  final DateTime fechaPublicacion;
  final List<Comentario> comentarios;
  final int likes;
  final bool usuarioDioLike;

  Publicacion({
    required this.id,
    required this.usuarioId,
    required this.nombreUsuario,
    required this.avatarUrl,
    required this.contenido,
    this.imagenUrl,
    required this.fechaPublicacion,
    List<Comentario>? comentarios,
    this.likes = 0,
    this.usuarioDioLike = false,
  }) : this.comentarios = comentarios ?? [];
}