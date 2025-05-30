import 'dart:convert' show jsonEncode;

import 'package:dio/dio.dart';
import 'package:mascotas_citas/Modules/SocialModule/models/SocialModel.dart';
import 'package:mascotas_citas/services/ApiService.dart';

abstract class SocialRepository {
  Future<List<dynamic>> getAllPosts();
  Future<bool> createPost({required Map<String, dynamic> postData, postImage1});
  Future<bool> updatePost({required Map<String, dynamic> updateData});
  Future<bool> deletePost({required String id});
}

class SocialRepositoryImpl implements SocialRepository {

  final DioApiService dioApiService;
  SocialRepositoryImpl({required this.dioApiService});

@override
Future<bool> createPost({required Map<String, dynamic> postData, postImage1}) async {
  try {
    FormData formData = FormData.fromMap({
      'postJson': jsonEncode(postData), // <-- Envía los datos como JSON string
      if (postImage1 != null)
        'postImage1': await MultipartFile.fromFile(
          postImage1.path,
          filename: postImage1.path.split('/').last,
        ),
    });
    if (postImage1 != null) {
      final result = await dioApiService.post(
      path: "/orquestador/api/create-post",
      data: formData,
      
    );
    return result.statusCode == 200;
    } else {
      final result = await dioApiService.post(
      path: "/social/posts/create",
      data: postData,
    );
    return result.statusCode == 200;
    }
    
    
  } catch (e) {
    if (e is DioException) {
      print(e.response?.data);
    } else {
      print(e);
    }
    return false;
  }
}

  @override
  Future<bool> deletePost({required String id}) async {
    try {
      final result = await dioApiService.post(
        path: "/social/posts/delete/$id",
        data: {},
      );
      return result.statusCode == 200;
    } catch (e) {
      // Puedes loguear el error aquí si lo deseas
      return false;
    }
  }

  @override
Future<List<SocialModel>> getAllPosts() async {
  try {
    final result = await dioApiService.get(
      path: "/social/posts/get-all",
      queryParams: {},
    );
    print('DATA DEL BACKEND: ${result.data}');

    // Si el backend devuelve {data: [...]}
    final dataList = result.data is List
        ? result.data
        : (result.data['data'] ?? []);

    if (result.statusCode == 200 && dataList is List) {
      return dataList
          .map((item) => SocialModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } else {
      return [];
    }
  } catch (e, st) {
    print('Error en getAllPosts: $e\n$st');
    return [];
  }
}

  @override
  Future<bool> updatePost({required Map<String, dynamic> updateData}) async {
    try {
      final result = await dioApiService.post(
        path: "/social/posts/update",
        data: updateData,
      );
      return result.statusCode == 200;
    } catch (e) {
      // Puedes loguear el error aquí si lo deseas
      return false;
    }
  }
}