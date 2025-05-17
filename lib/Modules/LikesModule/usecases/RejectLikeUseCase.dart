import 'package:mascotas_citas/Exceptions/ModuleException.dart';
import 'package:mascotas_citas/Modules/LikesModule/repo/LikesRepository.dart';
import 'package:mascotas_citas/Modules/LikesModule/state/LikeModuleState.dart';
import 'package:mascotas_citas/interfaces/usecase_interface.dart';

class RejectLikeUseCase implements UseCaseInterfacae {
  LikeRepository likeRepository;
  LikeModuleState likeModuleState;
  RejectLikeUseCase(
      {required this.likeRepository, required this.likeModuleState});


  @override
  Future execute() async {
    try {
      await likeRepository.rejectLike(likeModuleState.likes.first.likeUID);
      likeModuleState.removeData(likeModuleState.likes.first);
    } catch (e) {
      print(e);
      likeModuleState.setError(ModuleException(
          message: "Error al rechazar el like", title: "Error"));
    }
  }
}
