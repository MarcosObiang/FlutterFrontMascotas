import 'package:mascotas_citas/Modules/SocialModule/repos/CommentRepliesRepository.dart';
import 'package:mascotas_citas/Modules/SocialModule/models/CommentRepliesModel.dart';
import 'package:mascotas_citas/interfaces/usecase_interface.dart';

class CreateCommentReplyUseCase implements UseCaseInterfacae {
  final CommentRepliesRepository commentRepliesRepository;

  CreateCommentReplyUseCase({required this.commentRepliesRepository});

  @override
  Future<CommentRepliesModel?> execute([Map<String, dynamic>? replyData]) async {
    try {
      if (replyData == null) return null;
      return await commentRepliesRepository.createReply(replyData: replyData);
    } catch (e) {
      // Puedes loguear el error aquí si lo deseas
      return null;
    }
  }
}