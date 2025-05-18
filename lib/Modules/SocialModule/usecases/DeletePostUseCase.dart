import 'package:mascotas_citas/Modules/SocialModule/repos/SocialRepository.dart';
import 'package:mascotas_citas/interfaces/usecase_interface.dart';

class DeletePostUseCase implements UseCaseInterfacae {
  final SocialRepository socialRepository;
  DeletePostUseCase({required this.socialRepository});

  @override
  Future<bool> execute([Map<String, dynamic>? postData]) async {
    try {
      final id = postData?['id'];
      if (id == null) return false;
      final result = await socialRepository.deletePost(id: id);
      return result;
    } catch (e) {
      // Puedes loguear el error aquí si lo deseas
      return false;
    }
  }
}