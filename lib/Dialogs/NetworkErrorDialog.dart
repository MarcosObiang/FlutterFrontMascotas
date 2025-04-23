import 'package:flutter/material.dart';

class NetworKErrorWidget extends StatelessWidget {
  const NetworKErrorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Sin conexión a internet"),
      content: Text("Por favor, revisa tu conexión a internet."),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text("Entendido"),
        )
      ],
    );
  }
}
