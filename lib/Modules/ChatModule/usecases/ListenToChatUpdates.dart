import 'package:logger/web.dart';
import 'package:mascotas_citas/Modules/ChatModule/repo/ChatRepository.dart';
import 'package:mascotas_citas/Modules/ChatModule/state/ChatState.dart';
import 'package:mascotas_citas/interfaces/self_started_use_case_interface.dart';
import 'package:mascotas_citas/interfaces/usecase_interface.dart';

class ListenToChatUpdates
    implements ISelfStartedUseCaseInterface, UseCaseInterfacae {
  ChatRepository chatRepository;
  ChatState chatState;

  ListenToChatUpdates({required this.chatRepository, required this.chatState});

  @override
  Future execute() {
    chatRepository.onMessageReceived.listen((data) {
      chatState.setData(data);
    }, onError: (error) {
      chatState.setErrorStatus();
      Logger().e(error);
    });
    return Future.value(true);
  }

  @override
  Future<void> init() async {
    Future.value(execute());
  }
}
