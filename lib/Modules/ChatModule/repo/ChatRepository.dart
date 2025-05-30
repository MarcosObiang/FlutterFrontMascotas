import 'package:dio/dio.dart';
import 'package:mascotas_citas/Exceptions/ModuleException.dart';
import 'package:mascotas_citas/Modules/ChatModule/model/ChatModel.dart';
import 'package:mascotas_citas/Modules/WebSocketModule/WebSocketDataContainer.dart';
import 'package:mascotas_citas/services/ApiService.dart';
import 'package:mascotas_citas/services/WebSocketService.dart';

abstract class ChatRepository {
  Future<List<ChatModel>> getChats();
  Future<void> deleteChat({required String chatUID});
  Stream<WebSocketDataContainer<dynamic>> get onMessageReceived;
}

class ChatRepositoryImpl implements ChatRepository {
  WebSocketService webSocketService;

  DioApiService dioApiService;

  ChatRepositoryImpl(
      {required this.webSocketService, required this.dioApiService});

  @override
  Future<List<ChatModel>> getChats() async {
    try {
      final result = await dioApiService
          .get(path: "/chat-service/api/chats", queryParams: {});
      if (result.statusCode == 200) {
        List<dynamic> data = result.data;
        List<ChatModel> likes = data.map((e) => ChatModel.fromJson(e)).toList();
        return likes;
      }
      return [];
    } on Exception catch (e) {
      if (e is DioException) {
        throw ModuleException(
            message: "Error al obtener los chats ",
            title: "Error - ${e.response?.statusCode}");
      }
      throw ModuleException(
          message: "Error al obtener los chats ",
          title: "Error - ${e.toString()}");
    }  }

  @override
  Future<void> deleteChat({required String chatUID}) async {
    try {
      final result = await dioApiService
          .delete(path: "/chat-service/delete/$chatUID", data: {});

      if (result.statusCode == 200) {
        return;
      } else {
        return Future.error(Exception(result.statusMessage));
      }
    } catch (e) {
      if (e is DioException) {
        throw ModuleException(
            message: "Error al obtener los likes ",
            title: "Error - ${e.response?.statusCode}");
      }
      throw ModuleException(
          message: "Error al obtener los likes ",
          title: "Error - ${e.toString()}");
    }
  }

  @override
  Stream<WebSocketDataContainer<dynamic>> get onMessageReceived =>
      webSocketService.onMessageReceived.stream
          .where((jsonData) => jsonData["dataType"] == "chat")
          .map((event) {
        WebSocketDataContainer eventData =
            WebSocketDataContainer.fromJson(event);
        ChatModel chatModel = ChatModel.fromJson(eventData.body);
        WebSocketDataContainer<ChatModel> newChatModel =
            WebSocketDataContainer<ChatModel>(
                body: chatModel,
                eventType: eventData.eventType,
                resourceUID: eventData.resourceUID,
                dataType: eventData.dataType,
                receiverUID: eventData.receiverUID);

        return newChatModel;
      });
}
