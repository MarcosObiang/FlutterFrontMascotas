import 'package:mascotas_citas/Modules/SocialModule/repos/SocialRepository.dart';
import 'package:mascotas_citas/interfaces/usecase_interface.dart';

class GetAllPostUseCase implements UseCaseInterfacae {
  final SocialRepository socialRepository;
  GetAllPostUseCase({required this.socialRepository});

  @override
  Future<List<dynamic>> execute([Map<String, dynamic>? params]) async {
    try {
      final posts = await socialRepository.getAllPosts();
      return posts;
    } catch (e) {
      // Manejo de errores
      return [];
    }
  }
}