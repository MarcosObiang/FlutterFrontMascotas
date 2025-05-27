import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
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
  // Formateadores para la hora y la fecha
  final DateFormat _timeFormatter = DateFormat.Hm(); // HH:mm
  final DateFormat _dateFormatter = DateFormat('dd/MM'); // dd/MM

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

  String _getDateLabel(DateTime timestamp) {
    final now = DateTime.now();
    final localTimestamp = timestamp.toLocal();

    if (now.year == localTimestamp.year &&
        now.month == localTimestamp.month &&
        now.day == localTimestamp.day) {
      return "Hoy";
    } else {
      // Opcional: Podrías añadir lógica para "Ayer" aquí si lo deseas
      // final yesterday = now.subtract(const Duration(days: 1));
      // if (yesterday.year == localTimestamp.year &&
      //     yesterday.month == localTimestamp.month &&
      //     yesterday.day == localTimestamp.day) {
      //   return "Ayer";
      // }
      return _dateFormatter.format(localTimestamp);
    }
  }

  String _getTimeLabel(DateTime timestamp) {
    return _timeFormatter.format(timestamp.toLocal());
  }

  Column chatTile(ChatState state, int index, ChatModel chat) {
    String? token = getIt<AuthDataService>().getToken();

    return Column(
      children: [
        ListTile(
          leading: Container(
            width: 180.w,
            height: 180.w,
            decoration: const BoxDecoration(
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
                    child: const CircularProgressIndicator()),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
            ),
          ),
          title: Text(chat.user1Name),
          subtitle: Text(chat.lastMessage?.messageContent ?? ''),
          trailing: chat.lastMessage != null
              ? Column(
                  mainAxisSize: MainAxisSize.min, // Para que la columna no ocupe todo el alto
                  mainAxisAlignment: MainAxisAlignment.center, // Centrar verticalmente
                  crossAxisAlignment: CrossAxisAlignment.end, // Alinear texto a la derecha
                  children: <Widget>[
                    Text(
                      _getDateLabel(chat.lastMessage!.createdAt),
                      style: TextStyle(
                        fontSize: 35.sp, // Ligeramente más pequeño
                        color: Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(height: 2.h), // Pequeño espacio vertical
                    Text(
                      _getTimeLabel(chat.lastMessage!.createdAt),
                      style: TextStyle(fontSize: 30.sp), // Tamaño original de la hora
                    ),
                  ],
                )
              : const SizedBox.shrink(), // No mostrar nada si no hay último mensaje
          onTap: () {
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
