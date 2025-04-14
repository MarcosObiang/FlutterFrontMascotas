// presentation/dialogs/presentation_dialogs.dart

import 'package:flutter/material.dart';
import 'DialogOptions.dart';
import 'GenericDialog.dart';
import 'NetworkErrorDialog.dart';

/// Clase encargada de mostrar diferentes tipos de diálogos (pop-ups) comunes
/// en toda la app. Esta clase sigue un patrón singleton mediante factory.
class PresentationDialogs {
  /// Instancia singleton de PresentationDialogs
  static final PresentationDialogs _instance = PresentationDialogs._internal();

  /// Constructor factory que retorna la instancia única
  factory PresentationDialogs() => _instance;

  /// Constructor privado
  PresentationDialogs._internal();

  /// Muestra un diálogo de error genérico con un título y contenido.
  void showErrorDialog({
    required String title,
    required String content,
    required BuildContext? context,
  }) {
    if (context != null) {
      showDialog(
        context: context,
        builder: (context) => GenericDialog(
          title: title,
          content: content,
          dialogType: DialogType.error,
        ),
      );
    }
  }

  /// Muestra un diálogo de error de red personalizado.
  void showNetworkErrorDialog({required BuildContext? context}) {
    if (context != null) {
      showDialog(
        context: context,
        builder: (context) => const NetworKErrorWidget(),
      );
    }
  }

  /// Muestra un diálogo simple de consentimiento de anuncios.
  void showAdConsentDialog() {
    // Aquí se puede implementar lógica para mostrar consentimiento de anuncios.
    debugPrint("Mostrando consentimiento de anuncios");
  }

  /// Muestra un diálogo con opciones personalizadas como botones.
  void showErrorDialogWithOptions({
    required BuildContext? context,
    required List<DialogOptions> dialogOptionsList,
    required String dialogTitle,
    required String dialogText,
  }) {
    List<Widget> buttons = [];

    // Ordena los botones: negativo primero, luego positivo.
    dialogOptionsList.sort((a, b) {
      if (a is PositiveDialogOptions && b is NegativeDialogOptions) {
        return 1;
      } else if (a is NegativeDialogOptions && b is PositiveDialogOptions) {
        return -1;
      } else {
        return 0;
      }
    });

    for (var element in dialogOptionsList) {
      buttons.add(
        TextButton(
          child: Text(element.text),
          onPressed: element.function,
        ),
      );
    }

    if (context != null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(dialogTitle),
          content: Text(dialogText),
          actions: buttons,
        ),
      );
    }
  }
}
