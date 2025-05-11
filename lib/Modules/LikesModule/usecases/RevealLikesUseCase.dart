import 'package:mascotas_citas/Exceptions/ModuleException.dart';
import 'package:mascotas_citas/Modules/LikesModule/repo/LikesRepository.dart';
import 'package:mascotas_citas/Modules/LikesModule/state/LikeModuleState.dart';
import 'package:mascotas_citas/interfaces/usecase_interface.dart';

class RevealLikeUseCase implements UseCaseInterfacae {
  LikeRepository likeRepository;
  LikeModuleState likeModuleState;
  RevealLikeUseCase(
      {required this.likeRepository, required this.likeModuleState});
  @override
  Future execute() async {
    try {
      await likeRepository.revealReaction(likeModuleState.likes.first);
    } catch (e) {
      likeModuleState
          .setError(ModuleException(title: "Error", message: e.toString()));
    }
  }
}
