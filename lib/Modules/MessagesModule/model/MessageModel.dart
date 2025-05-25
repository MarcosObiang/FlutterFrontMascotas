import 'dart:convert';

import 'package:equatable/equatable.dart';

class MessageModel extends Equatable {
  String? id;
  String chatUID;
  DateTime createdAt;
  bool readByReciever;
  String senderId;
  String recieverId;
  String messageContent;
  String messageType;
  String messageId;

  MessageModel({
    this.id,
    required this.chatUID,
    required this.createdAt,
    required this.readByReciever,
    required this.senderId,
    required this.recieverId,
    required this.messageContent,
    required this.messageType,
    required this.messageId,
  });

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      id: map['id'] as String?,
      chatUID: map['chatUID'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      readByReciever: map['readByReciever'] as bool,
      senderId: map['senderId'] as String,
      recieverId: map['recieverId'] as String,
      messageContent: map['messageContent'] as String,
      messageType: map['messageType'] as String,
      messageId: map['messageId'] as String,
    );
  }



  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'chatUID': chatUID,
      'created_at': createdAt.toIso8601String(),
      'readByReciever': readByReciever,
      'senderId': senderId,
      'recieverId': recieverId,
      'messageContent': messageContent,
      'messageType': messageType,
      'messageId': messageId,
    };
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() {
    return 'MessageModel(id: $id, chatUID: $chatUID, createdAt: $createdAt, readByReciever: $readByReciever, senderId: $senderId, recieverId: $recieverId, messageContent: $messageContent, messageType: $messageType, messageId: $messageId)';
  }

  @override
  // TODO: implement props
  List<Object?> get props => [
        messageId,
      ];
}
