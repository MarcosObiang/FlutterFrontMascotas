import 'package:mascotas_citas/Modules/ChatModule/model/ChatModel.dart';
import 'package:mascotas_citas/Modules/ChatModule/state/ChatState.dart';
import 'package:mascotas_citas/Modules/MessagesModule/model/MessageModel.dart';
import 'package:mascotas_citas/Modules/MessagesModule/model/MessagesContainer.dart';
import 'package:mascotas_citas/interfaces/data_handler_interface.dart';

class ChatDataHandler
    implements DataProcessingStrategy<ChatModel, List<ChatModel>, ChatState> {
  @override
  bool canProcess(dynamic data, ChatState state) {
    if (data is! List<ChatModel>) return false;
    return true;
  }

  @override
  void process(List<ChatModel> data, ChatState state) {
    state.chatList.addAll(data);
    state.setLastListAction(action: LastListAction.add);
    state.setStatus(Status.success);
  }
}

class SortChatByMessageDataHandler
    implements DataProcessingStrategy<ChatModel, List<dynamic>, ChatState> {
  @override
  bool canProcess(dynamic data, ChatState state) {
    if (data is! List<MessagesContainer>) return false;


    return true;
  }

  @override
  void process(List<dynamic> data, ChatState state) {
    if (data.isEmpty) {
      return;
    }

    if (data is! List<MessagesContainer>) {
      return;
    }

    List<MessagesContainer> messages = data.cast<MessagesContainer>();

    for (int i = 0; i < messages.length; i++) {
      MessageModel message = messages[i].messages.last;
      int chatIndex =
          state.chatList.indexWhere((chat) => chat.chatId == message.chatUID);
      if (chatIndex != -1) {
        // Update the last message of the existing chat
        state.chatList[chatIndex].lastMessage = message;
      }
    }

    state.chatList.sort(
        (a, b) => a.lastMessage!.createdAt.compareTo(b.lastMessage!.createdAt));

    state.setLastListAction(action: LastListAction.update);
  }
}
