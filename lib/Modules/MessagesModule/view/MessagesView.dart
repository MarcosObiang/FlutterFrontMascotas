import 'package:flutter/material.dart';
import 'package:mascotas_citas/Modules/MessagesModule/model/MessagesContainer.dart';
import 'package:mascotas_citas/Modules/MessagesModule/state/MessagesState.dart';
import 'package:mascotas_citas/dependencies/injector.dart';
import 'package:provider/provider.dart';

class MessagesView extends StatefulWidget {
  final String chatUID;
  const MessagesView({required this.chatUID, super.key});

  @override
  State<MessagesView> createState() => _MessagesViewState();
}

class _MessagesViewState extends State<MessagesView> {
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
        final MessagesContainer selectedMessageContainer = messagesState.messagesContainers[widget.chatUID] 
            ?? MessagesContainer(chatUID: widget.chatUID, messages: []);
            

        return Scaffold(
          appBar: AppBar(
            title: const Text('Messages'),
          ),
          body: ListView.builder(
            itemCount: selectedMessageContainer.messages.length,
            itemBuilder: (context, index) {
              return Text(selectedMessageContainer.messages[index].messageContent);
            },
          ),
        );
      }),
    );
  }
}
