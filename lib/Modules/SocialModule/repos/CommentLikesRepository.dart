import 'package:mascotas_citas/Modules/SocialModule/models/CommentLikesModel.dart';
import 'package:mascotas_citas/Modules/SocialModule/DTOs/CheckLikedCommentDTO.dart';
import 'package:mascotas_citas/services/ApiService.dart';

abstract class CommentLikesRepository {
  Future<bool> checkLiked({required CheckLikedCommentDTO request});
  Future<CommentLikesModel?> createLike({required Map<String, dynamic> likeData});
  Future<bool> deleteLike({required CheckLikedCommentDTO request});
}

class CommentLikesRepositoryImpl implements CommentLikesRepository {
  final DioApiService dioApiService;

  CommentLikesRepositoryImpl({required this.dioApiService});

  @override
  Future<bool> checkLiked({required CheckLikedCommentDTO request}) async {
    try {
      final result = await dioApiService.post(
        path: "social/comments/likes/check-liked",
        data: request.toJson(),
      );
      return result.statusCode == 200 && result.data == true;
    } catch (e) {
      // Puedes loguear el error aquí si lo deseas
      return false;
    }
  }

  @override
  Future<CommentLikesModel?> createLike({required Map<String, dynamic> likeData}) async {
    try {
      final result = await dioApiService.post(
        path: "social/comments/likes/create",
        data: likeData,
      );
      if (result.statusCode == 200 && result.data != null) {
        return CommentLikesModel.fromJson(result.data);
      }
      return null;
    } catch (e) {
      // Puedes loguear el error aquí si lo deseas
      return null;
    }
  }

  @override
  Future<bool> deleteLike({required CheckLikedCommentDTO request}) async {
    try {
      final result = await dioApiService.post(
        path: "social/comments/likes/delete",
        data: request.toJson(),
      );
      return result.statusCode == 200;
    } catch (e) {
      // Puedes loguear el error aquí si lo deseas
      return false;
    }
  }
}