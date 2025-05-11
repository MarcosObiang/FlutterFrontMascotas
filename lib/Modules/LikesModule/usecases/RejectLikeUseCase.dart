import 'package:mascotas_citas/Exceptions/ModuleException.dart';
import 'package:mascotas_citas/Modules/LikesModule/repo/LikesRepository.dart';
import 'package:mascotas_citas/Modules/LikesModule/state/LikeModuleState.dart';
import 'package:mascotas_citas/interfaces/usecase_interface.dart';

class RejectLikeUseCase implements UseCaseInterfacae {
  late LikeRepository _likeRepository;
  late LikeModuleState _likeModuleState;
  RejectLikeUseCase(
      {required LikeRepository likeRepository,
      required LikeModuleState likeModuleState}) {
    _likeRepository = likeRepository;
    _likeModuleState = likeModuleState;
  }
  @override
  Future execute() async {
    try {
      await _likeRepository.rejectLike(_likeModuleState.likes.first.likeUID);
      _likeModuleState.removeData(_likeModuleState.likes.first);
    } catch (e) {
      print(e);
      _likeModuleState.setError(ModuleException(
          message: "Error al rechazar el like", title: "Error"));
    }
  }
}
