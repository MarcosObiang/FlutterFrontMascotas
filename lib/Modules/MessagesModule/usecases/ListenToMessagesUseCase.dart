
import 'package:logger/logger.dart';
import 'package:mascotas_citas/Modules/MessagesModule/repo/messages_repository.dart';
import 'package:mascotas_citas/Modules/MessagesModule/state/MessagesState.dart';
import 'package:mascotas_citas/interfaces/data_handler_interface.dart';
import 'package:mascotas_citas/interfaces/self_started_use_case_interface.dart';
import 'package:mascotas_citas/interfaces/usecase_interface.dart';

class ListenToMessagesUseCase
    implements ISelfStartedUseCaseInterface, UseCaseInterfacae {
  MessagesRepository messagesRepository;
  MessagesState messagesState;

  ListenToMessagesUseCase({required this.messagesRepository, required this.messagesState});

  @override
  Future execute() {
    messagesRepository.onMessageReceived.listen((data) {
      messagesState.setData(data);
    }, onError: (error) {
      messagesState.setStatus(Status.error);
      Logger().e(error);
    });
    return Future.value(true);
  }

  @override
  Future<void> init() async {
    Future.value(execute());
  }
}
