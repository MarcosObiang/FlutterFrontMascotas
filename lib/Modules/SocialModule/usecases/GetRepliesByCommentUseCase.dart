import 'package:mascotas_citas/Modules/SocialModule/repos/CommentRepliesRepository.dart';
import 'package:mascotas_citas/Modules/SocialModule/models/CommentRepliesModel.dart';
import 'package:mascotas_citas/interfaces/usecase_interface.dart';

class GetRepliesByCommentUseCase implements UseCaseInterfacae {
  final CommentRepliesRepository commentRepliesRepository;

  GetRepliesByCommentUseCase({required this.commentRepliesRepository});

  @override
  Future<List<CommentRepliesModel>> execute([Map<String, dynamic>? params]) async {
    try {
      if (params == null) return [];
      final commentUID = params['commentUID'] as String?;
      if (commentUID == null) return [];
      return await commentRepliesRepository.getRepliesByComment(commentUID: commentUID);
    } catch (e) {
      // Puedes loguear el error aquí si lo deseas
      return [];
    }
  }
}