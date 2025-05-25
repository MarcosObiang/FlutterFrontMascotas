import 'package:logger/web.dart';
import 'package:mascotas_citas/Modules/LikesModule/model/LikeModel.dart';
import 'package:mascotas_citas/Modules/LikesModule/repo/LikesRepository.dart';
import 'package:mascotas_citas/Modules/LikesModule/state/LikeModuleState.dart';
import 'package:mascotas_citas/interfaces/self_started_use_case_interface.dart';
import 'package:mascotas_citas/interfaces/usecase_interface.dart';

class Listentolikesusecase
    implements UseCaseInterfacae, ISelfStartedUseCaseInterface {
  LikeRepository likeRepository;
  LikeModuleState likeModuleState;

  Listentolikesusecase(
      {required this.likeRepository, required this.likeModuleState});
  @override
  Future execute() {
    likeRepository.onMessageReceived.listen((data) {

      
      likeModuleState.setData(data);
    }, onError: (error) {
      likeModuleState.setStatus(Status.error);
      Logger().e(error);
    });
    return Future.value(true);
  }

  @override
  Future<void> init() async {
    Future.value(execute());
  }
}
