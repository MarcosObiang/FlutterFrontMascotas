import 'package:mascotas_citas/Modules/SocialModule/repos/LikesRepository.dart';
import 'package:mascotas_citas/interfaces/usecase_interface.dart';

class CreateLikeUseCase implements UseCaseInterfacae {
  final LikesRepository likesRepository;

  CreateLikeUseCase({required this.likesRepository});

  @override
  Future<bool> execute([Map<String, dynamic>? likeData]) async {
    try {
      if (likeData == null) return false;
      return await likesRepository.createLike(likeData: likeData);
    } catch (e) {
      // Puedes loguear el error aquí si lo deseas
      return false;
    }
  }
}