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
      print("Error initializing use cases: $e");
      // Handle the error as needed
      // For example, you might want to log it or show a message to the user
      // throw e; // Rethrow the error if you want to propagate it
    }
    return Future.value();
  }
}
