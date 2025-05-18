import 'package:mascotas_citas/Modules/SocialModule/repos/CommentLikesRepository.dart';
import 'package:mascotas_citas/Modules/SocialModule/DTOs/CheckLikedCommentDTO.dart';
import 'package:mascotas_citas/interfaces/usecase_interface.dart';

class DeleteCommentLikeUseCase implements UseCaseInterfacae {
  final CommentLikesRepository commentLikesRepository;

  DeleteCommentLikeUseCase({required this.commentLikesRepository});

  @override
  Future<bool> execute([Map<String, dynamic>? params]) async {
    try {
      if (params == null) return false;
      final commentUID = params['commentUID'] as String?;
      final userUID = params['userUID'] as String?;
      if (commentUID == null || userUID == null) return false;
      final request = CheckLikedCommentDTO(
        commentUID: commentUID,
        userUID: userUID,
      );
      return await commentLikesRepository.deleteLike(request: request);
    } catch (e) {
      // Puedes loguear el error aquí si lo deseas
      return false;
    }
  }
}