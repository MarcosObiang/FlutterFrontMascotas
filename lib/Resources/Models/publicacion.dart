// Modelo de Publicación actualizado según tu requisito
class Publicacion {
  final String id;
  final String usuarioId;
  final String nombreUsuario;
  final String avatarUrl;
  final String contenido;
  final String? imagenUrl;
  final DateTime fechaPublicacion;
  final List comentarios;
  final int likes;
  bool usuarioDioLike;

  Publicacion({
    required this.id,
    required this.usuarioId,
    required this.nombreUsuario,
    required this.avatarUrl,
    required this.contenido,
    this.imagenUrl,
    required this.fechaPublicacion,
    List? comentarios,
    this.likes = 0,
    this.usuarioDioLike = false,
  }) : this.comentarios = comentarios ?? [];
}