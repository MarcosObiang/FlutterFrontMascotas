import 'package:flutter/foundation.dart';
import 'package:mascotas_citas/Modules/ChatModule/state/ChatState.dart';
import 'package:mascotas_citas/Modules/MessagesModule/model/MessageModel.dart';
import 'package:mascotas_citas/Modules/MessagesModule/model/MessagesContainer.dart';
import 'package:mascotas_citas/Modules/MessagesModule/repo/messages_repository.dart';
import 'package:mascotas_citas/Modules/MessagesModule/state/MessagesState.dart';
import 'package:mascotas_citas/interfaces/self_started_use_case_interface.dart';
import 'package:mascotas_citas/interfaces/usecase_interface.dart';

// Esta función se ejecutará en un Isolate separado gracias a `compute`.
// Debe ser una función de alto nivel (fuera de cualquier clase) o un método estático.
List<MessagesContainer> _parseAllMessagesInBackground(List<dynamic> rawMessages) {
  // Paso 1: Convertir la lista dinámica a List<MessageModel>
  List<MessageModel> parsedMessages = [];
  for (var messageData in rawMessages) {
    // Asegurarse de que messageData es un Map<String, dynamic> antes de pasarlo a fromJson
    if (messageData is Map<String, dynamic>) {
      parsedMessages.add(MessageModel.fromMap(messageData));
    } else {
      // Opcional: registrar un aviso si algún dato no tiene el formato esperado
      // Considera un logging más robusto si esto es crítico.
      debugPrint('Advertencia: Se omitió un dato de mensaje debido a un formato inesperado: $messageData');
    }
  }

  // Paso 2: Agrupar MessageModel en MessagesContainer
  Map<String, MessagesContainer> messagesMap = {};
  for (int i = 0; i < parsedMessages.length; i++) {
    final message = parsedMessages[i];
    messagesMap[message.chatUID] ??= MessagesContainer(
      chatUID: message.chatUID,
      messages: [],
    );
    messagesMap[message.chatUID]!.messages.add(message);
  }
  return messagesMap.values.toList();
}

class GetMessagesUseCase
    implements UseCaseInterfacae, ISelfStartedUseCaseInterface {
  MessagesRepository messagesRepository;
  MessagesState messagesState;
  ChatState chatState;
  GetMessagesUseCase({required this.messagesRepository, required this.messagesState, required this.chatState});

  @override
  Future<List<MessagesContainer>> execute() async {
    try {
      List<dynamic> rawMessages = await messagesRepository.getMessages();
      if (rawMessages.isEmpty) {
        return [];
      }
      // Ejecutar el parseo en un Isolate separado
      List<MessagesContainer> parsedMessages =
      await compute(_parseAllMessagesInBackground, rawMessages,
          debugLabel: 'GetMessagesUseCase - parseAllMessagesInBackground');

      messagesState.setData(parsedMessages);
      chatState.setData(parsedMessages);


      return parsedMessages;
    } catch (e) {
      // Considera un manejo de errores más específico o logging.
      // Por ahora, relanzamos el error para que el llamador lo maneje.
      debugPrint('Error en GetMessagesUseCase execute: $e');
      rethrow;
    }
  }

  @override
  Future<void> init() async {
    // Si este caso de uso debe realizar una carga inicial al arrancar.
    // El resultado de execute() no se usa directamente aquí, pero podría
    // poblar un caché o un stream que otras partes de la app observen.
    try {
      await execute();
    } catch (e) {
      debugPrint('Error durante la inicialización de GetMessagesUseCase: $e');
      // Manejar el error como sea apropiado para una tarea de auto-inicio.
    }
  }
}
