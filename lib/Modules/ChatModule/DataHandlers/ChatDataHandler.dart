import 'package:mascotas_citas/Modules/ChatModule/model/ChatModel.dart';
import 'package:mascotas_citas/Modules/ChatModule/state/ChatState.dart';
import 'package:mascotas_citas/interfaces/data_handler_interface.dart';

class ChatDataHandler
    implements DataProcessingStrategy<ChatModel, List<ChatModel>, ChatState> {
  @override
  bool canProcess(dynamic data, ChatState state) {
    if (data is! List) return false;
    return true;
  }

  @override
  void process(List<ChatModel> data, ChatState state) {
    state.chatList.addAll(data);
    state.setLastListAction(action: LastListAction.add);
    state.setStatus(Status.success);
  }
}
