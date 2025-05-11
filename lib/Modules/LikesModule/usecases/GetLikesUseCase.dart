import 'package:logger/logger.dart';
import 'package:mascotas_citas/Exceptions/ModuleException.dart';
import 'package:mascotas_citas/Modules/LikesModule/model/LikeModel.dart';
import 'package:mascotas_citas/Modules/LikesModule/repo/LikesRepository.dart';
import 'package:mascotas_citas/Modules/LikesModule/state/LikeModuleState.dart';
import 'package:mascotas_citas/interfaces/self_started_use_case_interface.dart';
import 'package:mascotas_citas/interfaces/usecase_interface.dart';

class GetLikesUseCase
    implements UseCaseInterfacae, ISelfStartedUseCaseInterface {
  LikeRepository likeRepository;
  LikeModuleState likeModuleState;

  GetLikesUseCase(
      {required this.likeRepository, required this.likeModuleState});

  @override
  Future execute() async {
    try {
      List<LikeModel> likes = await likeRepository.getAllLikes();
      likeModuleState.setData(likes);
    } catch (e) {
      Logger().e(e.toString());
      likeModuleState
          .setError(ModuleException(message: e.toString(), title: "Error"));
    }
  }

  @override
  Future<void> init() {
    execute();
    return Future.value(true);
  }
}
