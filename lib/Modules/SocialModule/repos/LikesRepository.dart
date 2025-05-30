import 'package:mascotas_citas/Modules/SocialModule/DTOs/CheckLikedRequestDTO.dart';
import 'package:mascotas_citas/services/ApiService.dart';

abstract class LikesRepository {
  Future<bool> checkLiked({required CheckLikedRequestDTO request});
  Future<bool> createLike({required Map<String, dynamic> likeData});
  Future<bool> deleteLike({required CheckLikedRequestDTO request});
}

class LikesRepositoryImpl implements LikesRepository {
  final DioApiService dioApiService;

  LikesRepositoryImpl({required this.dioApiService});

  @override
  Future<bool> checkLiked({required CheckLikedRequestDTO request}) async {
    try {
      final result = await dioApiService.post(
        path: "/social/posts/likes/check-liked",
        data: request.toJson(),
      );
      return result.statusCode == 200 && result.data == true;
    } catch (e) {
      // Puedes loguear el error aquí si lo deseas
      return false;
    }
  }

  @override
  Future<bool> createLike({required Map<String, dynamic> likeData}) async {
    try {
      final result = await dioApiService.post(
        path: "/social/posts/likes/create",
        data: likeData,
      );
      return result.statusCode == 200;
    } catch (e) {
      // Puedes loguear el error aquí si lo deseas
      return false;
    }
  }

  @override
  Future<bool> deleteLike({required CheckLikedRequestDTO request}) async {
    try {
      final result = await dioApiService.post(
        path: "/social/posts/likes/delete",
        data: request.toJson(),
      );
      return result.statusCode == 200;
    } catch (e) {
      // Puedes loguear el error aquí si lo deseas
      return false;
    }
  }
}