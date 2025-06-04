import 'package:flutter/material.dart';
import 'package:mascotas_citas/Modules/SocialModule/models/CommentRepliesModel.dart';

// Importa tus modelos reales
import '../models/SocialModel.dart';
import '../models/CommentsModel.dart';

// Importa todos los casos de uso del módulo social
import '../usecases/CheckCommentLikedUseCase.dart';
import '../usecases/CheckLikedUseCase.dart';
import '../usecases/CreateCommentLikeUseCase.dart';
import '../usecases/CreateCommentReplyUseCase.dart';
import '../usecases/CreateCommentUseCase.dart';
import '../usecases/CreateLikeUseCase.dart';
import '../usecases/CreatePostUseCase.dart';
import '../usecases/DeleteCommentLikeUseCase.dart';
import '../usecases/DeleteCommentReplyUseCase.dart';
import '../usecases/DeleteCommentUseCase.dart';
import '../usecases/DeleteLikeUseCase.dart';
import '../usecases/DeletePostUseCase.dart';
import '../usecases/GetAllPostUseCase.dart';
import '../usecases/GetCommentsByPostUseCase.dart';
import '../usecases/GetRepliesByCommentUseCase.dart';
import '../usecases/UpdateCommentReplyUseCase.dart';
import '../usecases/UpdateCommentUseCase.dart';
import '../usecases/UpdatePostUseCase.dart';

class SocialProvider extends ChangeNotifier {
  // Estado principal
  List<SocialModel> _publicaciones = [];
  List<CommentsModel> _comentarios = [];
  List<CommentRepliesModel> _replies = []; // Aquí puedes almacenar las respuestas a comentarios
  // Puedes agregar más listas para replies, likes, etc.

  // Getters
  List<SocialModel> get publicaciones => _publicaciones;
  List<CommentsModel> get comentarios => _comentarios;
  List<CommentRepliesModel> get replies => _replies; // Implementa según tu lógica

  // Casos de uso
  final CheckCommentLikedUseCase checkCommentLikedUseCase;
  final CheckLikedUseCase checkLikedUseCase;
  final CreateCommentLikeUseCase createCommentLikeUseCase;
  final CreateCommentReplyUseCase createCommentReplyUseCase;
  final CreateCommentUseCase createCommentUseCase;
  final CreateLikeUseCase createLikeUseCase;
  final CreatePostUseCase createPostUseCase;
  final DeleteCommentLikeUseCase deleteCommentLikeUseCase;
  final DeleteCommentReplyUseCase deleteCommentReplyUseCase;
  final DeleteCommentUseCase deleteCommentUseCase;
  final DeleteLikeUseCase deleteLikeUseCase;
  final DeletePostUseCase deletePostUseCase;
  final GetAllPostUseCase getAllPostUseCase;
  final GetCommentsByPostUseCase getCommentsByPostUseCase;
  final GetRepliesByCommentUseCase getRepliesByCommentUseCase;
  final UpdateCommentReplyUseCase updateCommentReplyUseCase;
  final UpdateCommentUseCase updateCommentUseCase;
  final UpdatePostUseCase updatePostUseCase;

  SocialProvider({
    required this.checkCommentLikedUseCase,
    required this.checkLikedUseCase,
    required this.createCommentLikeUseCase,
    required this.createCommentReplyUseCase,
    required this.createCommentUseCase,
    required this.createLikeUseCase,
    required this.createPostUseCase,
    required this.deleteCommentLikeUseCase,
    required this.deleteCommentReplyUseCase,
    required this.deleteCommentUseCase,
    required this.deleteLikeUseCase,
    required this.deletePostUseCase,
    required this.getAllPostUseCase,
    required this.getCommentsByPostUseCase,
    required this.getRepliesByCommentUseCase,
    required this.updateCommentReplyUseCase,
    required this.updateCommentUseCase,
    required this.updatePostUseCase,
  });

  // Métodos para interactuar con los casos de uso

  // Publicaciones
Future<void> cargarPublicaciones() async {
  final result = await getAllPostUseCase.execute();
  print('Resultado de getAllPostUseCase: $result'); // <-- Añade esto

  _publicaciones = result.map<SocialModel>((item) {
    if (item is SocialModel) return item;
    return SocialModel.fromJson(item as Map<String, dynamic>);
  }).toList();
  notifyListeners();
}

Future<void> crearPublicacion(Map<String, dynamic> data, {dynamic postImage1}) async {
  await createPostUseCase.execute({'postData': data, 'postImage1': postImage1});
  await cargarPublicaciones();
}

  Future<void> actualizarPublicacion(Map<String, dynamic> data) async {
    await updatePostUseCase.execute(data);
    await cargarPublicaciones();
  }

  Future<void> eliminarPublicacion(String postUID) async {
    await deletePostUseCase.execute({'postUID': postUID});
    await cargarPublicaciones();
  }

  // Comentarios
  Future<void> cargarComentarios(String postUID) async {
    _comentarios = await getCommentsByPostUseCase.execute({'postUID': postUID});
    notifyListeners();
  }

  Future<void> crearComentario(Map<String, dynamic> data) async {
    await createCommentUseCase.execute(data);
    await cargarComentarios(data['postUID']);
  }

  Future<void> actualizarComentario(Map<String, dynamic> data) async {
    await updateCommentUseCase.execute(data);
    await cargarComentarios(data['postUID']);
  }

  Future<void> eliminarComentario(String commentUID, String postUID) async {
    await deleteCommentUseCase.execute({'commentUID': commentUID, 'postUID': postUID});
    await cargarComentarios(postUID);
  }

  // Likes en publicaciones
  Future<void> darLike(Map<String, dynamic> data) async {
    await createLikeUseCase.execute(data);
    await cargarPublicaciones();
  }

  Future<void> quitarLike(Map<String, dynamic> data) async {
    await deleteLikeUseCase.execute(data);
    await cargarPublicaciones();
  }

  Future<bool> estaLikeado(Map<String, dynamic> data) async {
    return await checkLikedUseCase.execute(data);
  }

  // Likes en comentarios
  Future<void> darLikeComentario(Map<String, dynamic> data) async {
    await createCommentLikeUseCase.execute(data);
    await cargarComentarios(data['postUID']);
  }

  Future<void> quitarLikeComentario(Map<String, dynamic> data) async {
    await deleteCommentLikeUseCase.execute(data);
    await cargarComentarios(data['postUID']);
  }

  Future<bool> estaComentarioLikeado(Map<String, dynamic> data) async {
    return await checkCommentLikedUseCase.execute(data);
  }

  // Replies (respuestas a comentarios)
Future<List<CommentRepliesModel>> cargarReplies(String commentUID) async {
  _replies = await getRepliesByCommentUseCase.execute({'commentUID': commentUID});
  notifyListeners();
  return _replies; // ✅ Retorna las nuevas replies
}


  Future<void> crearReply(Map<String, dynamic> data) async {
    await createCommentReplyUseCase.execute(data);
    // Puedes recargar replies si lo necesitas
  }

  Future<void> actualizarReply(Map<String, dynamic> data) async {
    await updateCommentReplyUseCase.execute(data);
    // Puedes recargar replies si lo necesitas
  }

  Future<void> eliminarReply(String replyUID, String commentUID) async {
    await deleteCommentReplyUseCase.execute({'replyUID': replyUID, 'commentUID': commentUID});
    // Puedes recargar replies si lo necesitas
  }
}