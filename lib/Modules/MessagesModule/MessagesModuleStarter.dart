


import 'package:mascotas_citas/Modules/MessagesModule/state/MessagesState.dart';
import 'package:mascotas_citas/interfaces/self_started_use_case_interface.dart';
import 'package:mascotas_citas/interfaces/starter_interface.dart';

class MessagesModuleStarter implements IStarterInterface {
  MessagesState messagesState;
  List<ISelfStartedUseCaseInterface> selfStartedUseCases = [];
  MessagesModuleStarter({required this.selfStartedUseCases, required this.messagesState});
  @override
  Future<void> init() async {
    // This is where you would initialize the Messages module.
    // For example, you might set up repositories, use cases, etc.
    // This is just a placeholder for the actual implementation.
    messagesState.initialize();
    for (var useCase in selfStartedUseCases) {
      await useCase.init();
    }
    print("MessagesModuleStarter initialized");
  }
  
  @override
  Future<void> dispose() {
    // TODO: implement dispose
    throw UnimplementedError();
  }
}