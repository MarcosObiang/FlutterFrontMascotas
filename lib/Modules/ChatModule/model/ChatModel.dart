import 'package:mascotas_citas/utils/GetUriFromString.dart';

class ChatModel {
  String chatId;
  String chatCreationTimestamp; // Consider using DateTime and parsing
  String user1Id;
  String user2Id;
  String user1Name;
  String user2Name;
  String user1Picture; // Nullable if it can be absent
  String user2Picture; // Nullable if it can be absent
  bool user1Blocked;
  bool user2Blocked;
  String? user1NotificationToken; // Nullable if it can be absent
  String? user2NotificationToken; // Nullable if it can be absent

  ChatModel({
    required this.chatId,
    required this.chatCreationTimestamp,
    required this.user1Id,
    required this.user2Id,
    required this.user1Name,
    required this.user2Name,
    required this.user1Picture,
    required this.user2Picture,
    required this.user1Blocked,
    required this.user2Blocked,
    this.user1NotificationToken,
    this.user2NotificationToken,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      chatId: json['chatId'] as String,
      chatCreationTimestamp: json['chatCreationTimestamp'] as String,
      user1Id: json['user1Id'] as String,
      user2Id: json['user2Id'] as String,
      user1Name: json['user1Name'] as String,
      user2Name: json['user2Name'] as String,
      user1Picture:
          Geturifromstring().getUriFromString(json['user1Picture'] as String),
      user2Picture:
          Geturifromstring().getUriFromString(json['user2Picture'] as String),
      user1Blocked: json['user1Blocked'] as bool,
      user2Blocked: json['user2Blocked'] as bool,
      user1NotificationToken: json['user1NotificationToken'] as String?,
      user2NotificationToken: json['user2NotificationToken'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chatId': chatId,
      'chatCreationTimestamp': chatCreationTimestamp,
      'user1Id': user1Id,
      'user2Id': user2Id,
      'user1Name': user1Name,
      'user2Name': user2Name,
      'user1Picture': user1Picture,
      'user2Picture': user2Picture,
      'user1Blocked': user1Blocked,
      'user2Blocked': user2Blocked,
      'user1NotificationToken': user1NotificationToken,
      'user2NotificationToken': user2NotificationToken,
    };
  }
}
