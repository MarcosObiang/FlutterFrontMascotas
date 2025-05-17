import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:mascotas_citas/Exceptions/ModuleException.dart';
import 'package:mascotas_citas/Modules/LikesModule/model/LikeModel.dart';
import 'package:mascotas_citas/interfaces/state/IState.dart';

enum Status { loading, initial, error, success }

class LikeModuleState extends ChangeNotifier implements ModuleState {
  late StreamController<Map<String, dynamic>>? onErrorData;
  List<LikeModel> likes = List.empty(growable: true);
  String _lastListAction = "";

  Status _status = Status.initial;
  Status get status => _status;

  LikeModuleState({required this.onErrorData});

  void lastListActionAdd() {
    _lastListAction = "add";
  }

  void lastListActionRemove() {
    _lastListAction = "remove";
  }

  void lastListActionClear() {
    _lastListAction = "";
  }

  /// This is used to check if the last action was add or remove
  /// to the list of likes
  /// [add] if the last action was add
  /// [remove] if the last action was remove
  String get lastListAction => _lastListAction;

  @override
  void initialize() {
    setInitialStatus();
    likes = List.empty();
    if (onErrorData != null) {
      onErrorData!.close();
      onErrorData = null;
      onErrorData = StreamController.broadcast();
    } else {
      onErrorData = StreamController.broadcast();
    }
  }

  @override
  void setData(data) {
    if (data is LikeModel) {
      if (!likes.contains(data)) {
        likes = List.from(likes)..add(data);
        if (likes.isNotEmpty) {
          likes.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        }
        lastListActionAdd();
        notifyListeners();
        return;
      }

      _updateUpdateWithRevealedLike(data);
      notifyListeners();
      return;
    }

    if (data is List<LikeModel>) {
      likes = List.from(data);
      likes.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      notifyListeners();
    }
  }

  void _updateUpdateWithRevealedLike(LikeModel likeModel) {
    for (var i = 0; i < likes.length; i++) {
      if (likes[i] == likeModel) {
        likes[i] = likeModel;
        break;
      }
    }
  }

  void removeData(data) {
    if (data is LikeModel) {
      likes = List.of(likes)..remove(data);
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
