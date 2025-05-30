import 'package:flutter/material.dart';
import 'package:mascotas_citas/Exceptions/ModuleException.dart';
import 'package:mascotas_citas/Modules/ChatModule/DataHandlers/ChatDataHandler.dart';
import 'package:mascotas_citas/Modules/ChatModule/DataHandlers/RealTimeChatDataHandler.dart';
import 'package:mascotas_citas/Modules/ChatModule/DataHandlers/RealTimeChatSortDataHandler.dart';
import 'package:mascotas_citas/Modules/ChatModule/model/ChatModel.dart';
// import 'package:mascotas_citas/Modules/LikesModule/model/LikeModel.dart'; // Import no utilizado
import 'package:mascotas_citas/Modules/WebSocketModule/WebSocketDataContainer.dart';
import 'package:mascotas_citas/interfaces/data_handler_interface.dart';
import 'package:mascotas_citas/interfaces/i_list_item_manager.dart';
import 'package:mascotas_citas/interfaces/state/IState.dart';



/// Gestiona el estado del módulo de chat.
///
/// Esta clase es responsable de mantener la lista de chats,
/// el estado actual de las operaciones (carga, éxito, error) y
/// la última acción realizada en la lista.
class ChatState extends ChangeNotifier
    implements ModuleState, IListItemManager<ChatModel> {
  /// Lista de modelos de chat.
  /// Se inicializa como una lista vacía que puede crecer.
  List<ChatModel> chatList = List.empty(growable: true);

  List<DataProcessingStrategy<ChatModel, dynamic, ChatState>>
      dataProcessingStrategies = List.empty(growable: true);

  void addDataProcessingStrategy(
      DataProcessingStrategy<ChatModel, dynamic, ChatState> strategy) {
    dataProcessingStrategies.add(strategy);
  }

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
    setStatus(Status.initial);
    dataProcessingStrategies = List.empty(growable: true);
    addDataProcessingStrategy(ChatDataHandler());
    addDataProcessingStrategy(SortChatByMessageDataHandler());
    addDataProcessingStrategy(RealTimeAddChatDataHandler());
    addDataProcessingStrategy(RealTimeUpdateChatDataHandler());
    addDataProcessingStrategy(RealTimeDeleteChatDataHandler());
    addDataProcessingStrategy(RealTimeSortChatByMessageDataHandlerStrategy());
  }

  /// Establece los datos en el estado.
  ///
  /// Puede procesar datos en tiempo real desde WebSockets o una lista inicial de chats.
  @override
  void setData(data) {
    // Verifica si hay alguna estrategia que pueda procesar los datos
    for (var strategy in dataProcessingStrategies) {
      if (strategy.canProcess(data, this)) {
        strategy.process(data, this);
        return;
      }
    }
  }

  /// Establece un error en el estado.
  ///
  /// Actualmente, esta función no realiza ninguna acción.
  /// TODO: Implementar la lógica de manejo de errores si es necesario.
  @override
  void setError(ModuleException e) {}

  // --- Métodos de gestión de estado ---

  void setStatus(Status status) {
    _status = status;
    notifyListeners();
  }

  @override
  // TODO: implement items
  List<ChatModel> get items => this.chatList;

  @override
  void setLastListAction({required LastListAction action}) {
    this.lastListAction = action;
    notifyListeners();
  }
}
