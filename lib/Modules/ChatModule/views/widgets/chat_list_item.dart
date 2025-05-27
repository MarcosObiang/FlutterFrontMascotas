import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:mascotas_citas/Modules/ChatModule/model/ChatModel.dart';
import 'package:mascotas_citas/Modules/MessagesModule/view/MessagesView.dart';
import 'package:mascotas_citas/dependencies/injector.dart';
import 'package:mascotas_citas/services/auth/AuthSesionDataService.dart';

class ChatListItem extends StatelessWidget {
  final ChatModel chat;

  const ChatListItem({super.key, required this.chat});

  String _getDateLabel(DateTime timestamp) {
    final now = DateTime.now();
    final localTimestamp = timestamp.toLocal();

    if (now.year == localTimestamp.year &&
        now.month == localTimestamp.month &&
        now.day == localTimestamp.day) {
      return "Hoy";
    } else {
      // Considerar "Ayer" si se desea:
      // final yesterday = now.subtract(const Duration(days: 1));
      // if (yesterday.year == localTimestamp.year &&
      //     yesterday.month == localTimestamp.month &&
      //     yesterday.day == localTimestamp.day) {
      //   return "Ayer";
      // }
      return DateFormat('dd/MM').format(localTimestamp);
    }
  }

  String _getTimeLabel(DateTime timestamp) {
    return DateFormat.Hm().format(timestamp.toLocal());
  }

  @override
  Widget build(BuildContext context) {
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
                httpHeaders: token != null ? {"Authorization": "Bearer $token"} : null,
                fit: BoxFit.cover,
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
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      _getDateLabel(chat.lastMessage!.createdAt),
                      style: TextStyle(
                        fontSize: 26.sp, // Ligeramente más pequeño
                        color: Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(height: 2.h), // Pequeño espacio vertical
                    Text(
                      _getTimeLabel(chat.lastMessage!.createdAt),
                      style: TextStyle(fontSize: 30.sp),
                    ),
                  ],
                )
              : const SizedBox.shrink(), // No mostrar nada si no hay último mensaje
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return MessagesView(chatUID: chat.chatId);
            }));
          },
        ),
        const Divider(),
      ],
    );
  }
}