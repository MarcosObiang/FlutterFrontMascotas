import 'package:mascotas_citas/Modules/SocialModule/repos/CommentLikesRepository.dart';
import 'package:mascotas_citas/Modules/SocialModule/models/CommentLikesModel.dart';
import 'package:mascotas_citas/interfaces/usecase_interface.dart';

class CreateCommentLikeUseCase implements UseCaseInterfacae {
  final CommentLikesRepository commentLikesRepository;

  CreateCommentLikeUseCase({required this.commentLikesRepository});

  @override
  Future<CommentLikesModel?> execute([Map<String, dynamic>? likeData]) async {
    try {
      if (likeData == null) return null;
      return await commentLikesRepository.createLike(likeData: likeData);
    } catch (e) {
      // Puedes loguear el error aquí si lo deseas
      return null;
    }
  }
}