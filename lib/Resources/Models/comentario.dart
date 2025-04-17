

class Comentario {
  final String id;
  final String usuarioId;
  final String nombreUsuario;
  final String avatarUrl;
  final String contenido;
  final DateTime fechaComentario;

  Comentario({
    required this.id,
    required this.usuarioId,
    required this.nombreUsuario,
    required this.avatarUrl,
    required this.contenido,
    required this.fechaComentario,
  });
}