import 'package:mascotas_citas/Modules/MessagesModule/model/MessageModel.dart';
import 'package:mascotas_citas/Modules/MessagesModule/repo/messages_repository.dart';

class SendMessageUseCase {
  final MessagesRepository _messagesRepository;

  SendMessageUseCase(this._messagesRepository);

  Future<void> execute(MessageModel message) async {
    try {
      await _messagesRepository.sendMessage(message: message);
    } catch (e) {
      // Aquí podrías manejar errores específicos si es necesario
      // Por ejemplo, lanzar una excepción personalizada o registrar el error
      throw Exception("Error al enviar el mensaje: ${e.toString()}");
    }
  }
}
