import 'package:mascotas_citas/Modules/SocialModule/repos/SocialRepository.dart';
import 'package:mascotas_citas/interfaces/usecase_interface.dart';

class UpdatePostUseCase implements UseCaseInterfacae {
  final SocialRepository socialRepository;
  UpdatePostUseCase({required this.socialRepository});

  @override
  Future<bool> execute([Map<String, dynamic>? postData]) async {
    try {
      final result = await socialRepository.updatePost(updateData: postData ?? {});
      return result;
    } catch (e) {
      // Puedes loguear el error aquí si lo deseas
      return false;
    }
  }
}