import 'package:mascotas_citas/Modules/SocialModule/repos/LikesRepository.dart';
import 'package:mascotas_citas/Modules/SocialModule/DTOs/CheckLikedRequestDTO.dart';
import 'package:mascotas_citas/interfaces/usecase_interface.dart';

class DeleteLikeUseCase implements UseCaseInterfacae {
  final LikesRepository likesRepository;

  DeleteLikeUseCase({required this.likesRepository});

  @override
  Future<bool> execute([Map<String, dynamic>? params]) async {
    try {
      if (params == null) return false;
      final request = CheckLikedRequestDTO(
        postUID: params['postUID'] as String,
        userUID: params['userUID'] as String,
      );
      return await likesRepository.deleteLike(request: request);
    } catch (e) {
      // Puedes loguear el error aquí si lo deseas
      return false;
    }
  }
}