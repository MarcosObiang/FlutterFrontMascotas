import 'package:mascotas_citas/Modules/SocialModule/models/CommentsModel.dart';
import 'package:mascotas_citas/Modules/SocialModule/DTOs/DeleteCommentDTO.dart';
import 'package:mascotas_citas/services/ApiService.dart';

abstract class CommentsRepository {
  Future<CommentsModel?> createComment({required Map<String, dynamic> commentData});
  Future<bool> deleteComment({required DeleteCommentDTO deleteCommentDTO});
  Future<CommentsModel?> updateComment({required String commentUID, required Map<String, dynamic> updateData});
  Future<List<CommentsModel>> getCommentsByPost({required String postUID});
}

class CommentsRepositoryImpl implements CommentsRepository {
  final DioApiService dioApiService;

  CommentsRepositoryImpl({required this.dioApiService});

  @override
  Future<CommentsModel?> createComment({required Map<String, dynamic> commentData}) async {
    try {
      final result = await dioApiService.post(
        path: "social/comments/create",
        data: commentData,
      );
      if (result.statusCode == 200 && result.data != null) {
        return CommentsModel.fromJson(result.data);
      }
      return null;
    } catch (e) {
      // Puedes loguear el error aquí si lo deseas
      return null;
    }
  }

  @override
  Future<bool> deleteComment({required DeleteCommentDTO deleteCommentDTO}) async {
    try {
      final result = await dioApiService.post(
        path: "social/comments/delete",
        data: deleteCommentDTO.toJson(),
      );
      return result.statusCode == 200;
    } catch (e) {
      // Puedes loguear el error aquí si lo deseas
      return false;
    }
  }

  @override
  Future<CommentsModel?> updateComment({required String commentUID, required Map<String, dynamic> updateData}) async {
    try {
      final result = await dioApiService.post(
        path: "social/comments/update/$commentUID",
        data: updateData,
      );
      if (result.statusCode == 200 && result.data != null) {
        return CommentsModel.fromJson(result.data);
      }
      return null;
    } catch (e) {
      // Puedes loguear el error aquí si lo deseas
      return null;
    }
  }

  @override
  Future<List<CommentsModel>> getCommentsByPost({required String postUID}) async {
    try {
      final result = await dioApiService.get(
        path: "social/comments/get/$postUID",
        queryParams: {},
      );
      if (result.statusCode == 200 && result.data is List) {
        return (result.data as List)
            .map((json) => CommentsModel.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      // Puedes loguear el error aquí si lo deseas
      return [];
    }
  }
}