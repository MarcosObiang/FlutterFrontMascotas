import 'package:dio/dio.dart';
import 'package:mascotas_citas/Exceptions/ModuleException.dart';
import 'package:mascotas_citas/Modules/MessagesModule/model/MessageModel.dart';
import 'package:mascotas_citas/Modules/WebSocketModule/WebSocketDataContainer.dart';
import 'package:mascotas_citas/services/ApiService.dart';
import 'package:mascotas_citas/services/WebSocketService.dart';

abstract class MessagesRepository {
  Future<List<dynamic>> getMessages();
  Future<void> sendMessage({required MessageModel message});
  Future<void> setMessagesOnRead({required List<String> messageUIDs});
  Stream<WebSocketDataContainer<dynamic>> get onMessageReceived;
}

class MessagesRepositoryImpl implements MessagesRepository {
  WebSocketService webSocketService;

  DioApiService dioApiService;

  MessagesRepositoryImpl(
      {required this.webSocketService, required this.dioApiService});
  @override
  Future<List<dynamic>> getMessages() async {
    try {
      final result = await dioApiService
          .get(path: "/messages-service/api/messages/by-user", queryParams: {});
      if (result.statusCode == 200) {
        if (result.data is! List) {
          throw ModuleException(
              message: "Error al obtener los mensajes",
              title: "Error - Formato de datos inesperado");
        }
        if (result.data.isEmpty) {
          return [];
        }
        return result.data;
      }
      return [];
    } on Exception catch (e) {
      if (e is DioException) {
        throw ModuleException(
            message: "Error al obtener los mensajes ",
            title: "Error - ${e.response?.statusCode}");
      }
      throw ModuleException(
          message: "Error al obtener los mensajes ",
          title: "Error - ${e.toString()}");
    }
  }

  @override
  Future<void> sendMessage({required MessageModel message}) async {
    try {
      dynamic messageParsed=message.toJson();
      print(messageParsed);
      final result = await dioApiService.post(
          path: "/messages-service/api/messages", data: message.toJson());
      if (result.statusCode != 201) {
        throw ModuleException(
            message: "Error al enviar el mensaje",
            title: "Error - ${result.statusMessage}");
      }

      return;
    } on Exception catch (e) {
      if (e is DioException) {
        throw ModuleException(
            message: "Error al enviar los mensajes ",
            title: "Error - ${e.response?.statusCode}");
      }
      rethrow;
    }
  }

  @override
  Future<void> setMessagesOnRead({required List<String> messageUIDs}) async {
    try {
      final result = await dioApiService.put(
          path: "/messages-service/api/messages/read", data: messageUIDs);
      if (result.statusCode != 200) {
        throw ModuleException(
            message: "Error al marcar los mensajes como leídos",
            title: "Error - ${result.statusMessage}");
      }

      return;
    } on Exception catch (e) {
      if (e is DioException) {
        throw ModuleException(
            message: "Error al marcar los mensajes como leídos",
            title: "Error - ${e.response?.statusCode}");
      }
      rethrow;
    }
  }

  @override
  Stream<WebSocketDataContainer<dynamic>> get onMessageReceived =>
      webSocketService.onMessageReceived.stream
          .where((jsonData) => jsonData["dataType"] == "message")
          .map((event) {
        WebSocketDataContainer eventData =
            WebSocketDataContainer.fromJson(event);
        MessageModel chatModel = MessageModel.fromMap(eventData.body);
        WebSocketDataContainer<MessageModel> newChatModel =
            WebSocketDataContainer<MessageModel>(
                body: chatModel,
                eventType: eventData.eventType,
                resourceUID: eventData.resourceUID,
                dataType: eventData.dataType,
                receiverUID: eventData.receiverUID);

        return newChatModel;
      });
}
