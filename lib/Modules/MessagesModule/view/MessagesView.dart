import 'package:flutter/material.dart';
import 'package:mascotas_citas/Modules/MessagesModule/model/MessagesContainer.dart';
import 'package:mascotas_citas/Modules/MessagesModule/model/MessageModel.dart';
import 'package:mascotas_citas/Modules/MessagesModule/state/MessagesState.dart';
import 'package:mascotas_citas/Modules/MessagesModule/usecases/SendMessageUseCase.dart';
import 'package:mascotas_citas/dependencies/injector.dart';
import 'package:mascotas_citas/services/auth/AuthSesionDataService.dart';
import 'package:provider/provider.dart';

class MessagesView extends StatefulWidget {
  final String chatUID;
  const MessagesView({required this.chatUID, super.key});

  @override
  State<MessagesView> createState() => _MessagesViewState();
}

class _MessagesViewState extends State<MessagesView> {
  ScrollController scrollController = ScrollController();

  void initState() {
    super.initState();

    // Aquí podrías iniciar cualquier lógica necesaria, como escuchar cambios en el estado de los mensajes.
    // Por ejemplo, si tienes un UseCase que escucha mensajes, podrías iniciarlo aquí.
    // getIt<ListenToMessagesUseCase>().init();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: getIt<MessagesState>(),
      child: Consumer<MessagesState>(builder: (context, messagesState, child) {
        // Encuentra el MessagesContainer relevante aquí, dentro del builder del Consumer.
        // Esto asegura que siempre uses la data más actualizada de messagesState.
        // Es importante manejar el caso donde el contenedor no se encuentre.
        // firstWhere lanzará un error si no encuentra elementos.
        // Considera usar firstWhereOrNull (del paquete collection) o try-catch
        // si el contenedor podría no existir.
        final MessagesContainer selectedMessageContainer =
            messagesState.messagesContainers[widget.chatUID] ??
                MessagesContainer(chatUID: widget.chatUID, messages: []);

        // Programa el desplazamiento al final después de que el frame se haya construido
        // Esto se ejecutará después de cada reconstrucción del Consumer debido a cambios en messagesState.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          // Asegurarse de que hay clientes y mensajes antes de intentar scrollear.
          // Y que el scrollController todavía esté montado.
          if (scrollController.hasClients &&
              selectedMessageContainer.messages.isNotEmpty) {
            // Usar Future.delayed para asegurar que el scroll ocurra después
            // de que el layout se haya estabilizado completamente.
            Future.delayed(Duration.zero, () {
              if (scrollController.hasClients) {
                // Re-verificar por si acaso el widget se desmontó mientras esperaba
                double previousMaxScrollExtent = -1.0;
                double currentMaxScrollExtent;

                // Intentar scrollear al fondo. Repetir si el maxScrollExtent aumenta después de un salto.
                // El bucle se detendrá cuando maxScrollExtent deje de aumentar.
                while (true) {
                  currentMaxScrollExtent = scrollController.position.maxScrollExtent;
                  if (currentMaxScrollExtent > previousMaxScrollExtent) {
                    scrollController.position.jumpTo(currentMaxScrollExtent);
                    previousMaxScrollExtent = currentMaxScrollExtent; // Actualizar el valor de referencia.
                  } else {
                    // Si maxScrollExtent no aumentó, significa que ya estamos al final o se ha estabilizado.
                    break;
                  }
                }
              }
            });
          }
        });

        return Scaffold(
          appBar: AppBar(
            title: const Text('Messages'),
          ),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    addAutomaticKeepAlives: true,
                    cacheExtent: 1000.0, // Ajusta según tus necesidades

                    controller: scrollController,
                    reverse: false,
                    itemCount: selectedMessageContainer.messages.length,
                    itemBuilder: (context, index) {
                      final message = selectedMessageContainer.messages[index];
                      return MessageBubble(message: message);
                    },
                  ),
                ),
                MessageInputBar(
                  chatUID: widget.chatUID,
                  // Podrías pasar aquí el ID del receptor si es necesario para enviar el mensaje
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class MessageBubble extends StatefulWidget {
  final MessageModel message;

  const MessageBubble({
    Key? key,
    required this.message,
  }) : super(key: key);

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  @override
  Widget build(BuildContext context) {
    // Aquí puedes personalizar cómo se ve la burbuja del mensaje.
    // Por ahora, será un simple Container con el contenido del mensaje.
    // Podrías añadir lógica para alinearla a la izquierda o derecha
    // dependiendo de si es un mensaje enviado o recibido.

    // Ejemplo simple:
    bool isMyMessage = widget.message.senderId ==
        getIt<AuthDataService>().userUID; // Necesitarás una forma de saber esto

    return Align(
      alignment: isMyMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        decoration: BoxDecoration(
          color: isMyMessage ? Colors.blue[100] : Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment:
              isMyMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(widget.message.messageContent),
            Text(
              widget.message.createdAt.toLocal().toString().substring(11, 16),
              style: TextStyle(fontSize: 10, color: Colors.black54),
            ) // Hora del mensaje
          ],
        ),
      ),
    );
  }
}

class MessageInputBar extends StatefulWidget {
  final String chatUID;
  // final String receiverId; // Podrías necesitar esto para crear el MessageModel

  const MessageInputBar({
    Key? key,
    required this.chatUID,
    // required this.receiverId,
  }) : super(key: key);

  @override
  State<MessageInputBar> createState() => _MessageInputBarState();
}

class _MessageInputBarState extends State<MessageInputBar> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final SendMessageUseCase sendMessageUseCase = getIt<SendMessageUseCase>();

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    if (_textController.text.trim().isEmpty) {
      return; // No enviar mensajes vacíos
    }

    final authService = getIt<AuthDataService>();

    final newMessage = MessageModel(
      chatUID: widget.chatUID,
      createdAt: DateTime.now().toUtc(),
      readByReciever: false,
      senderId: authService.userUID!,
      recieverId: authService.userUID!, // Necesitarías pasar esto
      messageContent: _textController.text,
      messageType: 'TEXT', // O el tipo que corresponda
      messageId: "UID_DEL_MENSAJE", // Generar un ID único
    );
    sendMessageUseCase.execute(newMessage);

    print('Mensaje enviado: ${_textController.text}');
    _textController.clear();
    _focusNode
        .requestFocus(); // Para mantener el foco después de enviar, opcional
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              focusNode: _focusNode,
              decoration: const InputDecoration(
                hintText: 'Escribe un mensaje...',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) async =>
                  await _sendMessage(), // Enviar con la tecla Enter del teclado
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () async => await _sendMessage(),
          ),
        ],
      ),
    );
  }
}
