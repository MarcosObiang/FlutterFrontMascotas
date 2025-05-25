import 'package:flutter/material.dart';
import 'package:mascotas_citas/Exceptions/ModuleException.dart';
import 'package:mascotas_citas/Modules/MessagesModule/DataHandlers/MessagesDataHandler.dart';
import 'package:mascotas_citas/Modules/MessagesModule/model/MessagesContainer.dart';
import 'package:mascotas_citas/interfaces/data_handler_interface.dart';
import 'package:mascotas_citas/interfaces/i_list_item_manager.dart';
import 'package:mascotas_citas/interfaces/state/IState.dart';

class MessagesState extends ChangeNotifier
    implements ModuleState, IListItemManager<MessagesContainer> {
  LastListAction? lastListAction = LastListAction.none;
  List<DataProcessingStrategy<MessagesContainer, dynamic, MessagesState>>
      dataProcessingStrategies = List.empty(growable: true);
  Status _status = Status.initial;
  Status get status => _status;

  Map<String, MessagesContainer> messagesContainers = {};

  @override
  void initialize() {
    setStatus(Status.initial);
    dataProcessingStrategies = List.empty(growable: true);
    addDataProcessingStrategy(MesasgesDataHandler());
  }

  void addDataProcessingStrategy(
      DataProcessingStrategy<MessagesContainer, dynamic, MessagesState>
          strategy) {
    dataProcessingStrategies.add(strategy);
  }

  void setStatus(Status status) {
    _status = status;
    notifyListeners();
  }

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

  @override
  void setError(ModuleException e) {
    // TODO: implement setError
  }

  @override
  // TODO: implement items
  List<MessagesContainer> get items => messagesContainers.values.toList();

  @override
  void setLastListAction({required LastListAction action}) {
    // TODO: implement setLastListAction
  }
}
