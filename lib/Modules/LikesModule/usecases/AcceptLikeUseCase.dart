import 'package:mascotas_citas/Exceptions/ModuleException.dart';
import 'package:mascotas_citas/Modules/LikesModule/repo/LikesRepository.dart';
import 'package:mascotas_citas/Modules/LikesModule/state/LikeModuleState.dart';
import 'package:mascotas_citas/interfaces/usecase_interface.dart';

class AcceptLikeUseCase implements UseCaseInterfacae {
  LikeModuleState likeModuleState;
  LikeRepository likeRepository;

  AcceptLikeUseCase(
      {required this.likeModuleState, required this.likeRepository});
  @override
  Future execute() async {
    try {
      await likeRepository.acceptLike(likeModuleState.likes.first.likeUID);
    } catch (e) {
      likeModuleState.setError(
          ModuleException(message: "Error al aceptar like", title: "Error"));
    }
  }
}
