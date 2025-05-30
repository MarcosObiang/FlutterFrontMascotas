import 'package:mascotas_citas/Modules/MessagesModule/model/MessageModel.dart';
import 'package:mascotas_citas/Modules/MessagesModule/model/MessagesContainer.dart';
import 'package:mascotas_citas/Modules/MessagesModule/state/MessagesState.dart';
import 'package:mascotas_citas/interfaces/data_handler_interface.dart';

class MesasgesDataHandler
    implements
        DataProcessingStrategy<MessagesContainer, List<MessagesContainer>,
            MessagesState> {
  @override
  bool canProcess(dynamic data, MessagesState state) {
    if (data is! List) return false;
    return true;
  }

  @override
  void process(List<MessagesContainer> data, MessagesState state) {
    for (var container in data) {
      state.messagesContainers.putIfAbsent(container.chatUID, () => container);
    }
    state.setLastListAction(action: LastListAction.add);
    state.setStatus(Status.success);
  }
}
