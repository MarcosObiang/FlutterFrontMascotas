import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:mascotas_citas/Exceptions/ModuleException.dart';
import 'package:mascotas_citas/Modules/LikesModule/model/LikeModel.dart';
import 'package:mascotas_citas/interfaces/state/IState.dart';

enum Status { loading, initial, error, success }

class LikeModuleState extends ChangeNotifier implements ModuleState {
  late StreamController<Map<String, dynamic>>? onErrorData;
  List<LikeModel> likes = List.empty(growable: true);
  StreamController<String>? listUpdateInfo = StreamController.broadcast();

  Status _status = Status.initial;
  Status get status => _status;

  LikeModuleState({required this.onErrorData});

  @override
  void initialize() {
    setInitialStatus();
    likes = List.empty();
    if (onErrorData != null) {
      onErrorData!.close();
      onErrorData = null;
      onErrorData = StreamController.broadcast();
      listUpdateInfo = null;
      listUpdateInfo!.close();
      listUpdateInfo = StreamController.broadcast();
    } else {
      onErrorData = StreamController.broadcast();
      listUpdateInfo = StreamController.broadcast();
    }
  }

  @override
  void setData(data) {
    if (data is LikeModel) {
      likes = List.from(likes)..add(data);
      listUpdateInfo!.add("add");
      notifyListeners();
    }
  }

  void removeData(data) {
    if (data is LikeModel) {
      likes = List.of(likes)..remove(data);
      listUpdateInfo!.add("remove");
      notifyListeners();
    }
  }

  @override
  void setError(ModuleException e) {}

  void setSuccessStatus() {
    _status = Status.success;
    notifyListeners();
  }

  void setLoadingStatus() {
    _status = Status.loading;
    notifyListeners();
  }

  void setInitialStatus() {
    _status = Status.initial;
    notifyListeners();
  }

  void setErrorStatus() {
    _status = Status.error;
    notifyListeners();
  }
}
