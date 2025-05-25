import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:mascotas_citas/Exceptions/ModuleException.dart';
import 'package:mascotas_citas/Modules/ChatModule/state/ChatState.dart';
import 'package:mascotas_citas/Modules/LikesModule/DataHandlers/LikesDataHandlers.dart';
import 'package:mascotas_citas/Modules/LikesModule/DataHandlers/RealtimeDataHandlers.dart';
import 'package:mascotas_citas/Modules/LikesModule/model/LikeModel.dart';
import 'package:mascotas_citas/Modules/WebSocketModule/WebSocketDataContainer.dart';
import 'package:mascotas_citas/interfaces/data_handler_interface.dart';
import 'package:mascotas_citas/interfaces/i_list_item_manager.dart';
import 'package:mascotas_citas/interfaces/state/IState.dart';

enum Status { loading, initial, error, success }

class LikeModuleState extends ChangeNotifier
    implements ModuleState, IListItemManager<LikeModel> {
  late StreamController<Map<String, dynamic>>? onErrorData;
  List<LikeModel> likes = List.empty(growable: true);
  List<DataProcessingStrategy<LikeModel, dynamic, LikeModuleState>>
      dataProcessingStrategies = List.empty(growable: true);
  LastListAction _lastListAction = LastListAction.none;

  Status _status = Status.initial;
  Status get status => _status;

  LikeModuleState({required this.onErrorData});

  /// This is used to check if the last action was add or remove
  /// to the list of likes
  /// [add] if the last action was add
  /// [remove] if the last action was remove´

  LastListAction get lastListAction => _lastListAction;

  @override
  void initialize() {
    dataProcessingStrategies = List.empty(growable: true);
    addDataProcessingStrategy(LikeDataHandlers());
    addDataProcessingStrategy(RealTimeAddLikeHandler());
    addDataProcessingStrategy(RealTimeUpdateLikeHandler());
    addDataProcessingStrategy(RealTimeDeleteLikeHandler());
    setStatus(Status.initial);
    // Initialize likes as an empty list
    likes = List.empty();
    if (onErrorData != null) {
      onErrorData!.close();
      onErrorData = null;
      onErrorData = StreamController.broadcast();
    } else {
      onErrorData = StreamController.broadcast();
    }
  }

  void addDataProcessingStrategy(
      DataProcessingStrategy<LikeModel, dynamic, LikeModuleState> strategy) {
    dataProcessingStrategies.add(strategy);
  }

  @override
  void setData(data) {
    for (var strategy in dataProcessingStrategies) {
      if (strategy.canProcess(data, this)) {
        strategy.process(data, this);
        return;
      }
    }
  }

  @override
  void setError(ModuleException e) {
    
  }

  void setStatus(Status status) {
    _status = status;
    notifyListeners();
  }

  @override
  // TODO: implement items
  List<LikeModel> get items => this.likes;

  @override
  void setLastListAction({required LastListAction action}) {
    _lastListAction = action;

   WidgetsBinding.instance.scheduleFrameCallback((_) {
      notifyListeners();
    });

  }
}
