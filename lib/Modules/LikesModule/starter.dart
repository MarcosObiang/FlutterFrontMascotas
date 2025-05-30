import 'package:mascotas_citas/Modules/LikesModule/state/LikeModuleState.dart';
import 'package:mascotas_citas/interfaces/self_started_use_case_interface.dart';
import 'package:mascotas_citas/interfaces/starter_interface.dart';

class LikeModuleStarter implements IStarterInterface {
  List<ISelfStartedUseCaseInterface> _useCases = List.empty();
  late LikeModuleState _likeModuleState;
  LikeModuleStarter(
      {required List<ISelfStartedUseCaseInterface> useCases,
      required LikeModuleState likeModuleState}) {
    this._useCases = useCases;
    this._likeModuleState = likeModuleState;
  }
  @override
  Future<void> dispose() {
    // TODO: implement dispose
    throw UnimplementedError();
  }

  @override
  Future<void> init() {
    _likeModuleState.initialize();
    _useCases.forEach((data) {
      data.init();
    });
    return Future.value();
  }
}