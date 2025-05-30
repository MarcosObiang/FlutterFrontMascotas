import 'package:flutter/material.dart';
import 'package:mascotas_citas/Modules/SocialModule/State/social_provider.dart';
import 'package:provider/provider.dart';


class RepliesModal extends StatefulWidget {
  final String commentUID;
  final String postUID;

  const RepliesModal({
    super.key,
    required this.commentUID,
    required this.postUID,
  });

  @override
  State<RepliesModal> createState() => _RepliesModalState();
}

class _RepliesModalState extends State<RepliesModal> {
  late TextEditingController _replyController;

  @override
  void initState() {
    super.initState();
    _replyController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SocialProvider>(context, listen: false)
          .cargarReplies(widget.commentUID);
    });
  }

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final replies = Provider.of<SocialProvider>(context).replies;
    print('Replies cargadas: ${replies.length}');

    return AnimatedPadding(
      duration: const Duration(milliseconds: 150),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      curve: Curves.easeOut,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Respuestas (${replies.length})',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: replies.length,
                itemBuilder: (context, index) {
                  final reply = replies[index];
                  return ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.person)),
                    title: Text(reply.userUID ?? ''),
                    subtitle: Text(reply.replyText ?? ''),
                  );
                },
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _replyController,
                      decoration: const InputDecoration(
                        hintText: 'Escribe una respuesta...',
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.pink),
                    onPressed: () async {
                      if (_replyController.text.trim().isEmpty) return;

                      await Provider.of<SocialProvider>(context, listen: false)
                          .crearReply({
                        'commentUID': widget.commentUID,
                        'userUID': "miUsuarioId",
                        'replyText': _replyController.text,
                      });

                      _replyController.clear();

                      await Provider.of<SocialProvider>(context, listen: false)
                          .cargarReplies(widget.commentUID);

                      setState(() {});
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
