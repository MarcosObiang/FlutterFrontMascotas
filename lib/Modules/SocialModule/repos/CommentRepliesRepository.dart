import 'package:mascotas_citas/Modules/SocialModule/models/CommentRepliesModel.dart';
import 'package:mascotas_citas/services/ApiService.dart';

abstract class CommentRepliesRepository {
  Future<CommentRepliesModel?> createReply({required Map<String, dynamic> replyData});
  Future<bool> deleteReply({required String replyUID, required String commentUID});
  Future<CommentRepliesModel?> updateReply({required String replyUID, required Map<String, dynamic> updateData});
  Future<List<CommentRepliesModel>> getRepliesByComment({required String commentUID});
}

class CommentRepliesRepositoryImpl implements CommentRepliesRepository {
  final DioApiService dioApiService;

  CommentRepliesRepositoryImpl({required this.dioApiService});

  @override
  Future<CommentRepliesModel?> createReply({required Map<String, dynamic> replyData}) async {
    try {
      final result = await dioApiService.post(
        path: "social/comments/replies/create",
        data: replyData,
      );
      if (result.statusCode == 200 && result.data != null) {
        return CommentRepliesModel.fromJson(result.data);
      }
      return null;
    } catch (e) {
      // Puedes loguear el error aquí si lo deseas
      return null;
    }
  }

  @override
  Future<bool> deleteReply({required String replyUID, required String commentUID}) async {
    try {
      final result = await dioApiService.post(
        path: "social/comments/replies/delete",
        data: {
          'replyUID': replyUID,
          'commentUID': commentUID,
        },
      );
      return result.statusCode == 200;
    } catch (e) {
      // Puedes loguear el error aquí si lo deseas
      return false;
    }
  }

  @override
  Future<CommentRepliesModel?> updateReply({required String replyUID, required Map<String, dynamic> updateData}) async {
    try {
      final result = await dioApiService.post(
        path: "social/comments/replies/update",
        data: {
          'replyUID': replyUID,
          ...updateData,
        },
      );
      if (result.statusCode == 200 && result.data != null) {
        return CommentRepliesModel.fromJson(result.data);
      }
      return null;
    } catch (e) {
      // Puedes loguear el error aquí si lo deseas
      return null;
    }
  }

  @override
  Future<List<CommentRepliesModel>> getRepliesByComment({required String commentUID}) async {
    try {
      final result = await dioApiService.get(
        path: "social/comments/replies/get/$commentUID",
        queryParams: {},
      );
      if (result.statusCode == 200 && result.data is List) {
        return (result.data as List)
            .map((json) => CommentRepliesModel.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      // Puedes loguear el error aquí si lo deseas
      return [];
    }
  }
}