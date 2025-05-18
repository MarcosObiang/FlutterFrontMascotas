import 'package:mascotas_citas/Modules/SocialModule/repos/CommentRepliesRepository.dart';
import 'package:mascotas_citas/Modules/SocialModule/models/CommentRepliesModel.dart';
import 'package:mascotas_citas/interfaces/usecase_interface.dart';

class UpdateCommentReplyUseCase implements UseCaseInterfacae {
  final CommentRepliesRepository commentRepliesRepository;

  UpdateCommentReplyUseCase({required this.commentRepliesRepository});

  @override
  Future<CommentRepliesModel?> execute([Map<String, dynamic>? params]) async {
    try {
      if (params == null) return null;
      final replyUID = params['replyUID'] as String?;
      final updateData = params['updateData'] as Map<String, dynamic>?;
      if (replyUID == null || updateData == null) return null;
      return await commentRepliesRepository.updateReply(
        replyUID: replyUID,
        updateData: updateData,
      );
    } catch (e) {
      // Puedes loguear el error aquí si lo deseas
      return null;
    }
  }
}