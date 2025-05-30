import 'package:mascotas_citas/Modules/MessagesModule/model/MessageModel.dart';

class MessagesContainer {
  List<MessageModel> messages;
  String chatUID;

  MessagesContainer({
    required this.messages,
    required this.chatUID,
  });
}
