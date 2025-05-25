import 'package:mascotas_citas/Modules/ChatModule/state/ChatState.dart';
import 'package:mascotas_citas/interfaces/self_started_use_case_interface.dart';
import 'package:mascotas_citas/interfaces/starter_interface.dart';

class ChatModuleStarter implements IStarterInterface {
  List<ISelfStartedUseCaseInterface> _useCases = List.empty();
  late ChatState _chatState;
  ChatModuleStarter(
      {required List<ISelfStartedUseCaseInterface> useCases,
      required ChatState chatState}) {
    this._chatState = chatState;
    this._useCases = useCases;
  }

  @override
  Future<void> dispose() {
    // TODO: implement dispose
    throw UnimplementedError();
  }

  @override
  Future<void> init() {
    _chatState.initialize();
    _useCases.forEach((data) {
      data.init();
    });
    return Future.value();
  }
}
