import 'package:mascotas_citas/Exceptions/ModuleException.dart';
import 'package:mascotas_citas/Modules/ChatModule/model/ChatModel.dart';
import 'package:mascotas_citas/Modules/ChatModule/repo/ChatRepository.dart';
import 'package:mascotas_citas/Modules/ChatModule/state/ChatState.dart';
import 'package:mascotas_citas/interfaces/self_started_use_case_interface.dart';
import 'package:mascotas_citas/interfaces/usecase_interface.dart';

class GetChatsUseCase
    implements UseCaseInterfacae, ISelfStartedUseCaseInterface {
  ChatRepository chatRepository;
  ChatState chatState;

  GetChatsUseCase({required this.chatRepository, required this.chatState});
  @override
  Future execute() async {
    try {
      List<ChatModel> list = await chatRepository.getChats();
      chatState.setData(list);
    } catch (e) {
      chatState.setError(ModuleException(message: "message", title: "title"));
    }
  }

  @override
  Future<void> init() async {
    Future.value(execute());
  }
}
