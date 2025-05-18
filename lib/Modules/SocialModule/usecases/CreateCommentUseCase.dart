import 'package:mascotas_citas/Modules/SocialModule/repos/CommentsRepository.dart';
import 'package:mascotas_citas/Modules/SocialModule/models/CommentsModel.dart';
import 'package:mascotas_citas/interfaces/usecase_interface.dart';

class CreateCommentUseCase implements UseCaseInterfacae {
  final CommentsRepository commentsRepository;

  CreateCommentUseCase({required this.commentsRepository});

  @override
  Future<CommentsModel?> execute([Map<String, dynamic>? commentData]) async {
    try {
      if (commentData == null) return null;
      return await commentsRepository.createComment(commentData: commentData);
    } catch (e) {
      // Puedes loguear el error aquí si lo deseas
      return null;
    }
  }
}