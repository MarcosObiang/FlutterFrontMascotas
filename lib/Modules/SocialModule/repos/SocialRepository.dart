import 'package:mascotas_citas/services/ApiService.dart';

abstract class SocialRepository {
  Future<List<dynamic>> getAllPosts();
  Future<bool> createPost({required Map<String, dynamic> postData});
  Future<bool> updatePost({required Map<String, dynamic> updateData});
  Future<bool> deletePost({required String id});
}

class SocialRepositoryImpl implements SocialRepository {

  final DioApiService dioApiService;
  SocialRepositoryImpl({required this.dioApiService});

  @override
  Future<bool> createPost({required Map<String, dynamic> postData}) async {
    try {
      final result = await dioApiService.post(
        path: "social/posts/create",
        data: postData,
      );
      return result.statusCode == 200;
    } catch (e) {
      // Puedes loguear el error aquí si lo deseas
      return false;
    }
  }

  @override
  Future<bool> deletePost({required String id}) async {
    try {
      final result = await dioApiService.post(
        path: "social/posts/delete/$id",
        data: {},
      );
      return result.statusCode == 200;
    } catch (e) {
      // Puedes loguear el error aquí si lo deseas
      return false;
    }
  }

  @override
  Future<List<dynamic>> getAllPosts() async {
    try {
      final result = await dioApiService.get(
        path: "social/posts/get-all",
        queryParams: {},
      );
      if (result.statusCode == 200) {
        return result.data;
      } else {
        return [];
      }
    } catch (e) {
      // Puedes loguear el error aquí si lo deseas
      return [];
    }
  }

  @override
  Future<bool> updatePost({required Map<String, dynamic> updateData}) async {
    try {
      final result = await dioApiService.post(
        path: "social/posts/update",
        data: updateData,
      );
      return result.statusCode == 200;
    } catch (e) {
      // Puedes loguear el error aquí si lo deseas
      return false;
    }
  }
}