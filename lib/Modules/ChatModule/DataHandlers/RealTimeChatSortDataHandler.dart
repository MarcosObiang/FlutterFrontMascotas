import 'package:mascotas_citas/Modules/ChatModule/model/ChatModel.dart';
import 'package:mascotas_citas/Modules/ChatModule/state/ChatState.dart';
import 'package:mascotas_citas/Modules/MessagesModule/model/MessageModel.dart';
import 'package:mascotas_citas/Modules/WebSocketModule/WebSocketDataContainer.dart';
import 'package:mascotas_citas/interfaces/data_handler_interface.dart';

class RealTimeSortChatByMessageDataHandlerStrategy
    implements
        DataProcessingStrategy<ChatModel, WebSocketDataContainer<ChatModel>,
            ChatState> {
  @override
  bool canProcess(dynamic data, ChatState state) {
    if (data == null) {
      return false;
    }

    if (data is! WebSocketDataContainer<MessageModel>) {
      return false;
    }

    return data.eventType == ReealtimeEventType.CREATE;
  }

  @override
  void process(WebSocketDataContainer<dynamic> data, ChatState state) {
    if (data.body == null) {
      return;
    }

    if (data.body is MessageModel) {
      // If the data is a MessageModel, we need to find the corresponding chat
      // and update its last message.
      final message = data.body as MessageModel;
      final chatIndex =
          state.chatList.indexWhere((chat) => chat.chatId == message.chatUID);
      if (chatIndex != -1) {
        // Update the last message of the existing chat
        state.chatList[chatIndex].lastMessage = message;
        // Optionally, you can sort the list after updating
        state.chatList.sort((a, b) =>
            a.chatCreationTimestamp.compareTo(b.chatCreationTimestamp));
      }
      state.setLastListAction(action: LastListAction.update);

      return;
    }
  }
}
