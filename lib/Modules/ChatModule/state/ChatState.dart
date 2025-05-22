import 'package:flutter/material.dart';
import 'package:mascotas_citas/Exceptions/ModuleException.dart';
import 'package:mascotas_citas/Modules/ChatModule/model/ChatModel.dart';
// import 'package:mascotas_citas/Modules/LikesModule/model/LikeModel.dart'; // Import no utilizado
import 'package:mascotas_citas/Modules/WebSocketModule/WebSocketDataContainer.dart';
import 'package:mascotas_citas/interfaces/state/IState.dart';

/// Enum que representa los posibles estados de una operación o del módulo.
enum Status { loading, initial, error, success }

/// Enum que representa la última acción realizada sobre la lista de chats.
enum LastListAction { add, remove, update, none }

/// Gestiona el estado del módulo de chat.
///
/// Esta clase es responsable de mantener la lista de chats,
/// el estado actual de las operaciones (carga, éxito, error) y
/// la última acción realizada en la lista.
class ChatState extends ChangeNotifier implements ModuleState {
  /// Lista de modelos de chat.
  /// Se inicializa como una lista vacía que puede crecer.
  List<ChatModel> chatList = List.empty(growable: true);

  /// Estado actual del módulo. Privado para controlar su modificación.
  Status _status = Status.initial;

  /// Última acción realizada en [chatList].
  LastListAction lastListAction = LastListAction.none;

  /// Constructor por defecto.
  ChatState();

  /// Obtiene el estado actual del módulo.
  Status get status => _status;

  // --- Implementación de ModuleState ---
  @override
  void initialize() {
    setInitialStatus();
    lastListActionNone();
  }

  /// Establece los datos en el estado.
  ///
  /// Puede procesar datos en tiempo real desde WebSockets o una lista inicial de chats.
  @override
  void setData(data) {
    if (data is WebSocketDataContainer<ChatModel>) {
      _processRealtimeData(data);
    } else if (data is List<ChatModel>) {
      _addChats(data);
    }
  }

  /// Establece un error en el estado.
  ///
  /// Actualmente, esta función no realiza ninguna acción.
  /// TODO: Implementar la lógica de manejo de errores si es necesario.
  @override
  void setError(ModuleException e) {}

  // --- Métodos de gestión de estado ---

  /// Establece el estado a [Status.success] y notifica a los oyentes.
  void setSuccessStatus() {
    _status = Status.success;
    notifyListeners();
  }

  /// Establece el estado a [Status.loading] y notifica a los oyentes.
  void setLoadingStatus() {
    _status = Status.loading;
    notifyListeners();
  }

  /// Establece el estado a [Status.initial] y notifica a los oyentes.
  void setInitialStatus() {
    _status = Status.initial;
    notifyListeners();
  }

  /// Establece el estado a [Status.error] y notifica a los oyentes.
  void setErrorStatus() {
    _status = Status.error;
    notifyListeners();
  }

  // --- Métodos de manipulación de datos ---

  /// Elimina datos de [chatList].
  ///
  /// Puede eliminar un [ChatModel] específico o un chat por su ID (String).
  void removeData(data) {
    if (data is ChatModel) {
      chatList = List.of(chatList)..remove(data);
      lastListActionRemove();
      notifyListeners();
    }

    if (data is String) {
      // Podría ser 'else if' para mayor claridad si solo uno puede ser verdadero
      chatList = List.of(chatList)
        ..removeWhere((element) => element.chatId == data);
      lastListActionRemove();
      notifyListeners();
    }
  }

  // --- Métodos de gestión de LastListAction ---

  /// Establece [lastListAction] a [LastListAction.add].
  void lastListActionAdd() {
    lastListAction = LastListAction.add;
    // Considerar notificar oyentes si la UI reacciona directamente a este cambio.
  }

  /// Establece [lastListAction] a [LastListAction.remove].
  void lastListActionRemove() {
    lastListAction = LastListAction.remove;
    // Considerar notificar oyentes.
  }

  /// Establece [lastListAction] a [LastListAction.update].
  void lastListActionUpdate() {
    lastListAction = LastListAction.update;
    // Considerar notificar oyentes.
  }

  /// Establece [lastListAction] a [LastListAction.none].
  void lastListActionNone() {
    lastListAction = LastListAction.none;
    // Considerar notificar oyentes.
  }

  // --- Métodos privados de ayuda ---

  /// Procesa los datos recibidos en tiempo real (por ejemplo, desde WebSockets).
  void _processRealtimeData(WebSocketDataContainer<ChatModel> data) {
    if (data.eventType == ReealtimeEventType.CREATE) {


      if(chatList.contains(data.body!)){
        return;
      }
      chatList = List.from(chatList)..add(data.body!);
      chatList.sort(
          (a, b) => a.chatCreationTimestamp.compareTo(b.chatCreationTimestamp));
      lastListActionAdd();
      notifyListeners();

      if (this.status != Status.success) {
        setSuccessStatus();
      }
    } else if (data.eventType == ReealtimeEventType.DELETED) {
      removeData(data
          .resourceUID); // removeData ya llama a notifyListeners y lastListActionRemove
    }
    // else if (data.eventType == ReealtimeEventType.UPDATE) {
    //   // TODO: Implementar lógica de actualización si es necesario.
    //   // _updateUpdateWithRevealedLike(data.body!);
    //   // notifyListeners();
    // }
  }

  /// Añade una lista de chats a [chatList] y la ordena.
  void _addChats(List<ChatModel> data) {
    chatList = List.from(data);
    chatList.sort(
        (a, b) => a.chatCreationTimestamp.compareTo(b.chatCreationTimestamp));
    setSuccessStatus();
  }
}
