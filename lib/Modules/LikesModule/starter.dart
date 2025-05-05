import 'package:mascotas_citas/interfaces/self_started_use_case_interface.dart';
import 'package:mascotas_citas/interfaces/starter_interface.dart';

class LikeModuleStarter implements IStarterInterface {
  List<ISelfStartedUseCaseInterface> _useCases=List.empty();
  LikeModuleStarter({required List<ISelfStartedUseCaseInterface> useCases}){
    this._useCases = useCases;

  }
  @override
  Future<void> dispose() {
    // TODO: implement dispose
    throw UnimplementedError();
  }

  @override
  Future<void> init() {
    _useCases.forEach((data) {
      data.init();
    });
    return Future.value();
  }
}
