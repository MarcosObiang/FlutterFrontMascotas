import 'package:mascotas_citas/Modules/ChatModule/model/ChatModel.dart';
import 'package:mascotas_citas/Modules/ChatModule/state/ChatState.dart';
import 'package:mascotas_citas/Modules/WebSocketModule/WebSocketDataContainer.dart';
import 'package:mascotas_citas/interfaces/data_handler_interface.dart';

class RealTimeAddChatDataHandler
    implements
        DataProcessingStrategy<ChatModel, WebSocketDataContainer<ChatModel>,
            ChatState> {
  @override
  bool canProcess(dynamic data, ChatState state) {
    if (data == null) {
      return false;
    }

    if (data is! WebSocketDataContainer<ChatModel>) {
      return false;
    }

    return data.eventType == ReealtimeEventType.CREATE;
  }

  @override
  void process(WebSocketDataContainer<ChatModel> data, ChatState state) {
    if (data.body == null) {
      return;
    }

    // Verifica si el chat ya existe en la lista
    if (state.chatList.any((chat) => chat.chatId == data.body!.chatId)) {
      // Si ya existe, no lo añade
      return;
    }
    state.chatList.add(data.body!);
    // Consider sorting the list if a specific order is required, e.g., by timestamp:
    // state.chatList.sort((a, b) => a.chatCreationTimestamp.compareTo(b.chatCreationTimestamp));
    // This requires chatCreationTimestamp to be a DateTime object and parsed correctly in ChatModel.

    state.setLastListAction(action: LastListAction.add);
  }
}

class RealTimeUpdateChatDataHandler
    implements
        DataProcessingStrategy<ChatModel, WebSocketDataContainer<ChatModel>,
            ChatState> {
  @override
  bool canProcess(WebSocketDataContainer<ChatModel> data, ChatState state) {
    return data.eventType == ReealtimeEventType.UPDATE;
  }

  @override
  void process(WebSocketDataContainer<ChatModel> data, ChatState state) {
    if (data.body == null) {
      return;
    }

    // Busca el índice del chat a actualizar
    int index =
        state.chatList.indexWhere((chat) => chat.chatId == data.body!.chatId);

    // Si el chat no existe, no se hace nada
    if (index == -1) {
      return;
    }

    // Actualiza el chat en la lista
    state.chatList[index] = data.body!;
    state.setLastListAction(action: LastListAction.update);
  }
}

class RealTimeDeleteChatDataHandler
    implements
        DataProcessingStrategy<ChatModel, WebSocketDataContainer<ChatModel>,
            ChatState> {
  @override
  bool canProcess(WebSocketDataContainer<ChatModel> data, ChatState state) {
    return data.eventType == ReealtimeEventType.DELETED;
  }

  @override
  void process(WebSocketDataContainer<ChatModel> data, ChatState state) {
    if (data.body == null) {
      return;
    }

    // Busca el índice del chat a eliminar
    int index = state.chatList.indexWhere((chat) => chat.chatId == data.resourceUID);

    // Si el chat no existe, no se hace nada
    if (index == -1) {
      return;
    }

    // Elimina el chat de la lista
    state.chatList.removeAt(index);
    state.setLastListAction(action: LastListAction.remove);
  }
}
