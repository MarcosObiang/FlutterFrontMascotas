import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mascotas_citas/Modules/ChatModule/model/ChatModel.dart';
import 'package:mascotas_citas/Modules/ChatModule/state/ChatState.dart';
import 'package:mascotas_citas/Modules/MessagesModule/view/MessagesView.dart';
import 'package:mascotas_citas/dependencies/injector.dart';
import 'package:mascotas_citas/interfaces/data_handler_interface.dart';
import 'package:mascotas_citas/services/auth/AuthSesionDataService.dart';
import 'package:provider/provider.dart';

class ChatView extends StatefulWidget {
  const ChatView({super.key});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: getIt<ChatState>(),
      child: Material(
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Chat'),
          ),
          body: Consumer<ChatState>(
              builder: (BuildContext context, ChatState state, Widget? child) {
            if (state.status == Status.loading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state.status == Status.error) {
              return const Center(child: Text('Error loading chats'));
            } else if (state.status == Status.initial) {
              return const Center(child: Text('No chats available'));
            }
            return SizedBox.expand(
              child: ListView.builder(
                itemCount: state.chatList.length,
                itemBuilder: (context, index) {
                  final chat = state.chatList[index];
                  return chatTile(state, index, chat);
                },
              ),
            );
          }),
        ),
      ),
    );
  }

  Column chatTile(ChatState state, int index, ChatModel chat) {
    String? token = getIt<AuthDataService>().getToken();

    return Column(
      children: [
        ListTile(
          leading: Container(
            width: 180.w,
            height: 180.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child: CachedNetworkImage(
                imageUrl: chat.user1Picture,
                httpHeaders: {"Authorization": "Bearer $token"},
                fit: BoxFit
                    .cover, // Asegura que la imagen cubra todo el contenedor
                placeholder: (context, url) => SizedBox(
                    height: 100.h,
                    width: 100.w,
                    child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
            ),
          ),
          title: Text(chat.user1Name),
          subtitle: Text("chat.lastMessage"),
          onTap: () {
            // Handle chat tap
            // You can navigate to a chat detail page or perform any action
            print("Chat tapped: ${chat.user1Name}");
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              // Aquí puedes navegar a la vista de mensajes del chat
              // Asegúrate de que la vista de mensajes esté implementada
              return MessagesView(chatUID: chat.chatId);
            }));
          },
        ),
        const Divider(),
      ],
    );
  }
}
