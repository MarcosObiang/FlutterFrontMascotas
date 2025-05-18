import 'package:logger/logger.dart';
import 'package:mascotas_citas/Modules/SocialModule/repos/SocialRepository.dart';
import 'package:mascotas_citas/interfaces/usecase_interface.dart';

class CreatePostUseCase implements UseCaseInterfacae {
  final SocialRepository socialRepository;
  CreatePostUseCase({required this.socialRepository});

  @override
  Future<bool> execute([Map<String, dynamic>? postData]) async {
    try {
      final result = await socialRepository.createPost(postData: postData ?? {});
      return result;
    } catch (e) {
      Logger().e(e.toString());
      return false;
    }
  }
}