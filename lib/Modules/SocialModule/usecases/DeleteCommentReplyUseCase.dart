import 'package:mascotas_citas/Modules/SocialModule/repos/CommentRepliesRepository.dart';
import 'package:mascotas_citas/interfaces/usecase_interface.dart';

class DeleteCommentReplyUseCase implements UseCaseInterfacae {
  final CommentRepliesRepository commentRepliesRepository;

  DeleteCommentReplyUseCase({required this.commentRepliesRepository});

  @override
  Future<bool> execute([Map<String, dynamic>? params]) async {
    try {
      if (params == null) return false;
      final replyUID = params['replyUID'] as String?;
      final commentUID = params['commentUID'] as String?;
      if (replyUID == null || commentUID == null) return false;
      return await commentRepliesRepository.deleteReply(
        replyUID: replyUID,
        commentUID: commentUID,
      );
    } catch (e) {
      // Puedes loguear el error aquí si lo deseas
      return false;
    }
  }
}