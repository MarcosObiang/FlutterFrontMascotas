import 'package:mascotas_citas/Modules/SocialModule/repos/CommentsRepository.dart';
import 'package:mascotas_citas/Modules/SocialModule/models/CommentsModel.dart';
import 'package:mascotas_citas/interfaces/usecase_interface.dart';

class GetCommentsByPostUseCase implements UseCaseInterfacae {
  final CommentsRepository commentsRepository;

  GetCommentsByPostUseCase({required this.commentsRepository});

  @override
  Future<List<CommentsModel>> execute([Map<String, dynamic>? params]) async {
    try {
      if (params == null) return [];
      final postUID = params['postUID'] as String?;
      if (postUID == null) return [];
      return await commentsRepository.getCommentsByPost(postUID: postUID);
    } catch (e) {
      // Puedes loguear el error aquí si lo deseas
      return [];
    }
  }
}