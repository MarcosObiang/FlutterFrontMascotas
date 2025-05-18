import 'package:mascotas_citas/Modules/SocialModule/repos/CommentsRepository.dart';
import 'package:mascotas_citas/Modules/SocialModule/models/CommentsModel.dart';
import 'package:mascotas_citas/interfaces/usecase_interface.dart';

class UpdateCommentUseCase implements UseCaseInterfacae {
  final CommentsRepository commentsRepository;

  UpdateCommentUseCase({required this.commentsRepository});

  @override
  Future<CommentsModel?> execute([Map<String, dynamic>? params]) async {
    try {
      if (params == null) return null;
      final commentUID = params['commentUID'] as String?;
      final updateData = params['updateData'] as Map<String, dynamic>?;
      if (commentUID == null || updateData == null) return null;
      return await commentsRepository.updateComment(
        commentUID: commentUID,
        updateData: updateData,
      );
    } catch (e) {
      // Puedes loguear el error aquí si lo deseas
      return null;
    }
  }
}