import 'package:mascotas_citas/interfaces/self_started_use_case_interface.dart';
import 'package:mascotas_citas/interfaces/starter_interface.dart';

class AuthStarter implements IStarterInterface {
  List<ISelfStartedUseCaseInterface> useCases = [];
  AuthStarter({required this.useCases});

  @override
  Future<void> dispose() {
    // TODO: implement dispose
    throw UnimplementedError();
  }

  @override
  Future<void> init() {
    try {
      for (var useCase in useCases) {
        useCase.init();
      }
    } catch (e) {
      print("Error initializing AuthStarter: $e");
    }
    return Future.value();
  }
}
