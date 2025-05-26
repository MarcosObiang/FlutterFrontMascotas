import 'package:mascotas_citas/Modules/MessagesModule/model/MessageModel.dart';
import 'package:mascotas_citas/Modules/MessagesModule/model/MessagesContainer.dart';
import 'package:mascotas_citas/Modules/MessagesModule/state/MessagesState.dart';
import 'package:mascotas_citas/Modules/WebSocketModule/WebSocketDataContainer.dart';
import 'package:mascotas_citas/interfaces/data_handler_interface.dart';

class MessagesRealTimeAddDataHandlerStrategy
    implements
        DataProcessingStrategy<MessagesContainer,
            WebSocketDataContainer<MessageModel>, MessagesState> {
  @override
  bool canProcess(dynamic data, MessagesState state) {
    if (data == null) {
      return false;
    }
    if (data is! WebSocketDataContainer<MessageModel>) {
      return false;
    }

    return data.eventType == ReealtimeEventType.CREATE;
  }

  @override
  void process(WebSocketDataContainer<MessageModel> data, MessagesState state) {
    if (data.body == null) {
      return;
    }

    // Agrega el mensaje a la lista de mensajes
    // Si no existe el contenedor de mensajes para el chatUID, lo crea
    state.messagesContainers[data.body!.chatUID] ??=
        MessagesContainer(chatUID: data.body!.chatUID, messages: []);

    // Verifica si el mensaje ya existe
    int messageIndex = state.messagesContainers[data.body!.chatUID]!.messages
        .indexWhere((message) => message.messageId == data.body!.messageId);
    if (messageIndex != -1) {
      // Si el mensaje ya existe, no lo agrega
      return;
    }
    // Agrega el mensaje a la lista de mensajes
    state.messagesContainers[data.body!.chatUID]!.messages.add(data.body!);
    // Ordena los mensajes por timestamp
    state.messagesContainers[data.body!.chatUID]!.messages.sort(
      (a, b) => a.createdAt.compareTo(b.createdAt),
    );
    state.setLastListAction(action: LastListAction.add);
  }
}
