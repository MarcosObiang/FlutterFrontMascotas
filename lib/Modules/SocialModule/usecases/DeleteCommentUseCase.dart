import 'package:mascotas_citas/Modules/SocialModule/repos/CommentsRepository.dart';
import 'package:mascotas_citas/Modules/SocialModule/DTOs/DeleteCommentDTO.dart';
import 'package:mascotas_citas/interfaces/usecase_interface.dart';

class DeleteCommentUseCase implements UseCaseInterfacae {
  final CommentsRepository commentsRepository;

  DeleteCommentUseCase({required this.commentsRepository});

  @override
  Future<bool> execute([Map<String, dynamic>? params]) async {
    try {
      if (params == null) return false;
      final commentUID = params['commentUID'] as String?;
      final postUID = params['postUID'] as String?;
      if (commentUID == null || postUID == null) return false;
      final deleteCommentDTO = DeleteCommentDTO(
        commentUID: commentUID,
        postUID: postUID,
      );
      return await commentsRepository.deleteComment(
        deleteCommentDTO: deleteCommentDTO,
      );
    } catch (e) {
      // Puedes loguear el error aquí si lo deseas
      return false;
    }
  }
}