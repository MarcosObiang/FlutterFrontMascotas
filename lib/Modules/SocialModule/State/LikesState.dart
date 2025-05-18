import 'package:flutter/material.dart';
import 'package:mascotas_citas/Modules/SocialModule/models/PostLikesModel.dart';
import 'package:mascotas_citas/Exceptions/ModuleException.dart';
import 'package:mascotas_citas/interfaces/state/IState.dart';

enum LikesStatus {
  initial,
  loading,
  loaded,
  error,
}

class LikesState extends ChangeNotifier implements ModuleState {
  List<LikesModel> likes = [];
  LikesStatus status = LikesStatus.initial;
  ModuleException? error;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initialize() {
    likes = [];
    status = LikesStatus.initial;
    error = null;
    notifyListeners();
  }

  @override
  void setData(data) {
    if (data is List<LikesModel>) {
      likes = data;
      status = LikesStatus.loaded;
      notifyListeners();
    }
  }

  @override
  void setError(ModuleException e) {
    error = e;
    status = LikesStatus.error;
    notifyListeners();
  }

  void setInitialState() {
    status = LikesStatus.initial;
    notifyListeners();
  }

  void setLoadingState() {
    status = LikesStatus.loading;
    notifyListeners();
  }

  void setLoadedState() {
    status = LikesStatus.loaded;
    notifyListeners();
  }

  void setErrorState() {
    status = LikesStatus.error;
    notifyListeners();
  }
}